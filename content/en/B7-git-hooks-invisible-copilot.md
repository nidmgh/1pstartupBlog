---
title: "Git Hooks: Your Invisible Co-Pilot"
date: 2026-04-21
lang: en
slug: git-hooks-invisible-copilot
series: vibecoding
episode: 7
author: MaiMai
---

<!-- Image placeholder: git hook / guardrail illustration -->

Most projects that need git hooks in 2026 reach for a framework: [Husky](https://typicode.github.io/husky/) for the Node ecosystem, [Lefthook](https://lefthook.dev/) for polyglot projects that want parallel execution, the [pre-commit framework](https://pre-commit.com/) for Python-centric stacks. They're all good. They all add a dependency.

FIRE51 uses none of them. The entire pre-commit system is one bash script, checked into `scripts/hooks/`, symlinked into `.git/hooks/` by `setup.sh`. Thirty lines, zero dependencies, written by Claude in one pass, running silently for months. For a solo vibe-coding project, that's the right level of tool.

This post explains the mechanics, shows the actual script, and covers when to upgrade to a framework.

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

The doc-sync reminder is soft — it exits `0` and the commit always proceeds. The tax validation is hard — it exits `1` and blocks the commit. This split is deliberate.

**Hard is right when** the violation is objectively breaking something: a test fails, a lint error surfaces, a secret is detected in the diff. The cost of a bad commit outweighs the friction of blocking.

**Soft is right when** the check is a practice reminder, not a correctness gate. Making doc updates a hard block would generate `git commit --no-verify` habits within a week. A visible reminder at the right moment changes behavior without creating resistance.

You can see both in the FIRE51 hook: doc sync is a nudge, tax engine correctness is a wall. The tax engine is the one module that, if wrong, silently compounds errors into meaningless retirement projections. It earns the wall.

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

Three standard workarounds:

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
