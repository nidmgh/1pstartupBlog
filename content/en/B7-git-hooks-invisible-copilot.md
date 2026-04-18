---
title: "Git Hooks: Your Invisible Co-Pilot"
date: 2026-04-21
published: true
lang: en
slug: git-hooks-invisible-copilot
series: vibecoding
episode: 7
author: MaiMai
---

![](/blog/assets/B7-Hero-InvisibleCoPilot.png)

Most projects that need git hooks in 2026 reach for a framework: [Husky](https://typicode.github.io/husky/) for the Node ecosystem, [Lefthook](https://lefthook.dev/) for polyglot projects that want parallel execution, the [pre-commit framework](https://pre-commit.com/) for Python-centric stacks. They're all good. They all add a dependency.

FIRE51 doesn't reach for any of the heavier frameworks. It's a solo vibe-coding project — a git hook is enough to hold the engineering discipline. The entire pre-commit system is one bash script, checked into `scripts/hooks/`, symlinked into `.git/hooks/` by `setup.sh`. Thirty lines, zero dependencies, written by Claude in one pass.

Below: the mechanics, the actual script, and when to upgrade to a framework.

## The Mechanism

Git hooks are shell scripts that git runs automatically at specific points in the workflow. They live in `.git/hooks/` and git calls them by name — no configuration required.

```
.git/hooks/
  pre-commit     ← fires before the commit is created
  commit-msg     ← fires after you write the commit message
  pre-push       ← fires before git sends to the remote
  post-commit    ← fires after commit completes (can't abort)
```

When you run `git commit`, git looks for `.git/hooks/pre-commit`. If it exists and is executable (`chmod +x`), git runs it:

- Exit `0` → commit proceeds
- Exit non-zero → commit aborted

That's the entire mechanism. Everything else is just shell script.

## The Actual FIRE51 Hook

Here is the complete `pre-commit` script, unchanged:

```bash
#!/bin/bash
# FIRE51 pre-commit hook
# Reminds about doc sync and VIBECODING.md diary when code changes without docs.
# Soft warning only — does not block the commit.

STAGED=$(git diff --cached --name-only)

CODE_CHANGED=$(echo "$STAGED" | grep -E "^src/|^public/" | grep -v "\.map$" | head -1)
DOC_CHANGED=$(echo "$STAGED" | grep -E "\.md$" | head -1)

if [ -n "$CODE_CHANGED" ] && [ -z "$DOC_CHANGED" ]; then
  echo ""
  echo "  ┌─────────────────────────────────────────────────────────┐"
  echo "  │  Doc sync reminder                                      │"
  echo "  │                                                         │"
  echo "  │  Code changed but no .md files staged.                  │"
  echo "  │                                                         │"
  echo "  │  → Did the relevant design doc get updated?             │"
  echo "  │  → Anything worth adding to VIBECODING.md Raw Notes?    │"
  echo "  │                                                         │"
  echo "  │  Committing anyway — update docs in a follow-up if so.  │"
  echo "  └─────────────────────────────────────────────────────────┘"
  echo ""
fi

# Hard gate: tax engine must pass validation before commit
if echo "$STAGED" | grep -q "TaxEngine.ts"; then
  echo "pre-commit: TaxEngine.ts changed — running PolicyEngine validation..."
  npm test -- --testPathPattern="tests/validation" --silent 2>&1
  if [ $? -ne 0 ]; then
    echo "pre-commit: PolicyEngine validation FAILED. Fix before committing."
    exit 1
  fi
  echo "pre-commit: validation passed."
fi

exit 0
```

Two behaviors, two philosophies, one file.

## Soft vs. Hard Enforcement

The previous post, [Code and Docs in Sync](/blog/en/code-and-docs-in-sync), closed with "soft over hard" — here's where that philosophy lives in code. The FIRE51 hook is deliberately mixed: doc sync is a nudge (`exit 0`), tax validation is a wall (`exit 1`). The rule: **hard-block only when the violation is objectively broken** — failing tests, lint errors, a detected secret. Everything else is a reminder. The tax engine earns the wall because a silent error there compounds into a meaningless retirement projection; doc drift is recoverable, a wrong tax calculation isn't.

## Keep Hooks Efficient

A slow hook is a bypassed hook. My budget: **pre-commit under ~2 seconds, pre-push under ~10.** Past that, the `--no-verify` habit sets in within a week and the guardrail quietly disappears.

What doesn't belong in pre-commit:

- The full test suite — run a targeted subset; leave the rest for CI.
- Network calls — dependency scans, remote linters, anything that can stall on a flaky connection.
- Anything that requires a clean build from scratch.

Notice what FIRE51's tax-engine gate actually runs: `npm test -- --testPathPattern="tests/validation"`. It's the validation subset, not the full suite. Full tests run in CI. The hook guards only the one class of error that's both likely and catastrophic — bad tax math — and does it fast enough that it never tempts a bypass.

## The Hook Subset: PolicyEngine as a Case Study

![](/blog/assets/B7-PolicyEngine-AnswerKey.png)

The previous section mentioned that the hook runs a "validation subset" rather than the full suite. What is that subset, exactly — and why is it shaped the way it is?

**Why an external baseline is needed.** AI-written financial code has a large gap between "plausible" and "actually correct." In a retirement projection, a 5% tax error compounded over 45 years becomes a meaningless number. Worse, an AI can happily "fix" a failing tax-engine test by tweaking the inputs — the test turns green, the logic stays wrong, and the bug ships. The only real fix is to bring in an independent baseline the AI can't talk its way around.

[PolicyEngine](https://policyengine.org/) is an open-source tax microsimulation model used by policy researchers. FIRE51 treats it as independent ground truth for the tax engine: same inputs, both engines compute independently, and the result passes only if the deltas fall within tolerance (federal ±$100, state ±$300, NIIT ±$50, SS taxable ±$50).

**Why PolicyEngine's source can't simply be embedded in the product.** PolicyEngine is licensed under AGPL. Running it locally on a dev machine for offline comparison is fine, but bundling it as a library inside the app binary — or exposing it through a public API — triggers AGPL's copyleft obligation, forcing all of FIRE51's closed-source code to be opened along with it. So PolicyEngine lives only on the offline-validation side and never shares a process with production code.

**Why the full PolicyEngine validation isn't in the hook.** The full pipeline (`npm run validate:pe`) batch-calls an external Python service across many tax years and scenarios; one run takes ten-plus minutes and will grow as the project grows. Putting that in pre-commit would immediately trigger the `--no-verify` habit from the previous section — the guardrail would quietly disappear.

**How it's actually triggered.** On the dev machine, a full PolicyEngine pass runs once and snapshots the results into reference-value files under `tests/validation/`. The `npm test` line in the hook compares the current tax engine's output against those snapshots — seconds, not minutes — and only when `TaxEngine.ts` is staged. When do we re-run the full PolicyEngine validation? After any major tax-logic change — a new tax type, a year-parameter update, an IRS rule change — we run it by hand, refresh the snapshots, and then return to normal commits.

## Quick Reference

| Hook | When | Non-zero exit |
|------|------|---------------|
| `pre-commit` | Before commit created | Aborts commit |
| `commit-msg` | After message written | Aborts commit |
| `pre-push` | Before push to remote | Aborts push |
| `post-commit` | After commit completes | (can't abort) |
| `pre-rebase` | Before rebase starts | Aborts rebase |

FIRE51 uses `pre-commit` and `pre-push`. Pre-commit catches problems before they're recorded in git history. Pre-push is the last line of defense before they reach the remote — it re-runs the tax engine validation in case someone bypassed pre-commit with `--no-verify`.

## The Limitation You Need to Know

`.git/hooks/` is excluded from git tracking by design. A fresh `git clone` gets an empty hooks folder. Other collaborators don't automatically get your hooks.

Four standard workarounds:

1. **Commit the hooks to `scripts/hooks/`, let `setup.sh` symlink them into `.git/hooks/`** — what FIRE51 does. Zero dependencies, one line of setup, works on any machine with bash.
2. **[Husky](https://typicode.github.io/husky/)** — the Node ecosystem default. Manages hooks as part of `package.json`. Ideal if you're already doing `npm install`.
3. **[Lefthook](https://lefthook.dev/)** — a Go binary, YAML config, runs hooks in parallel. Worth it for polyglot projects or when pre-commit time is measurable.
4. **[pre-commit framework](https://pre-commit.com/)** — Python-based, massive library of pre-built hooks, language-agnostic. The heavyweight option.

For a solo project, option 1 is usually enough. For a team, option 2 or 3 is the right next step — the difference between Husky and Lefthook is mostly about whether you want to pay the cost of Node.js for your hook tooling, and whether hook speed matters.

## Why This Works Well for Vibe Coding

AI moves fast. Without gates, bad habits accumulate across sessions before you notice them. With hooks, quality checks happen at the natural moment of attention — when you're about to commit, before it's done.

The hooks themselves can be written by the AI. In FIRE51, the pre-commit hook was written by Claude in a single session — I asked for a soft reminder when code changed without docs, a hard block on tax engine validation failure, and got the 30-line script above. Committed to `scripts/hooks/`, symlinked by `setup.sh`, running silently ever since. Zero maintenance cost. Permanent guardrail.

The best kind of co-pilot is the one you forget is there.

---

*FIRE51 is a retirement planning tool built entirely via vibe coding. This is the seventh post in the Vibe Coding series.*
