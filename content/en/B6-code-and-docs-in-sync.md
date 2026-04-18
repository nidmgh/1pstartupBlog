---
title: "Code and Docs in Sync: A Three-Layer System"
date: 2026-04-18
published: true
lang: en
slug: code-and-docs-in-sync
series: vibecoding
episode: 6
author: MaiMai
---

![](/blog/assets/B6-Code-Doc-inSync.png)

There's an emerging industry term for what happens when AI agents write code without a forcing function: [**AI architecture drift**](https://techdebt.best/ai-architecture-drift/). Agents ignore previously documented decisions, re-introduce deprecated patterns, violate layer boundaries, and invent new conventions mid-project. The industry's 2026 response has been heavy: automated Architecture Decision Record (ADR) generators, LLM-powered doc-linters, PR bots that enforce architectural conformance.

FIRE51 uses a much lighter system. Three layers. No new tools. No dependencies. It works because it sits at the exact points where attention naturally lands — the start of a session, the moment of a commit — and it puts the rules in writing where they survive.

## The Drift Problem

![](/blog/assets/B6-StaleVSReal.png)

After a few sessions of vibe coding, the architecture document describes a system that no longer exists. New sessions start from a stale map. Design decisions get re-litigated because nobody recorded why they were made. Bugs that were already fixed quietly come back.

The root cause isn't laziness. It's that there's no natural enforcement mechanism. In a team, code review catches drift. In a solo vibe coding session, nothing does — unless you build it in deliberately.

I saw this directly on FIRE51. Before the system below existed, the same design decision — whether the engine should handle Roth conversions before or after RMD calculations — got re-litigated in three consecutive sessions. The answer was the same every time. Nobody wrote it down. The AI had no memory of the previous discussion. I'd forget I'd decided it. Wasted hours, three times.

## Layer 1 — AI Standing Instructions (`CLAUDE.md`)

`CLAUDE.md` is read at the start of every session. It's the highest-leverage layer because it costs nothing at commit time and shapes every session automatically.

FIRE51's `CLAUDE.md` contains a doc sync table — a direct mapping from the kind of code that changed to the design doc that needs updating in the same commit:

| Code changed | Doc to update |
|---|---|
| Engine logic, year-loop, tax, RMD | `MODULE2_DESIGN.md` or `TAX_ENGINE_DESIGN.md` |
| Chat steps, parsers, builder | `MODULE1_DESIGN.md` |
| Report, charts, PDF, transform | `MODULE3_DESIGN.md` |
| Auth, OTP, mailer, server routes | `GOLIVE_DESIGN.md` |
| Mobile / Capacitor | `CAPACITOR_DESIGN.md` |
| Deployment, infra, nginx, VM | `GOLIVE_DESIGN.md` |
| Architecture / module boundaries | `ARCHITECTURE.md` |
| Any of the above | Consider a line in `VIBECODING.md` Raw Notes if it was hard, surprising, or instructive |

When the AI makes a code change in one of these rows, it updates the corresponding document as part of the same task. No reminder needed at commit time, because the work was done at authoring time.

Also in `CLAUDE.md` is a four-question pre-commit checklist:

1. Did the relevant design doc get updated?
2. Does `npm test` pass?
3. Is `dist/` in sync with source (`npm run build`)?
4. Any lesson worth adding to `VIBECODING.md`?

The AI runs through this before announcing a commit is ready. Four questions, ~10 seconds, catches most drift before it ships.

## Layer 2 — Git Pre-Commit Hook (Human Reminder)

The hook runs on every `git commit`. It can't be forgotten. FIRE51's hook does two things:

- If `src/` or `public/` files are staged but no `.md` files are staged → print a visible reminder box — *soft warning, doesn't block*
- If `TaxEngine.ts` is staged and PolicyEngine validation fails → hard-block

```
  ┌─────────────────────────────────────────────────────────┐
  │  Doc sync reminder                                      │
  │                                                         │
  │  Code changed but no .md files staged.                  │
  │                                                         │
  │  → Did the relevant design doc get updated?             │
  │  → Anything worth adding to VIBECODING.md Raw Notes?    │
  │                                                         │
  │  Committing anyway — update docs in a follow-up if so.  │
  └─────────────────────────────────────────────────────────┘
```

Soft enforcement. A hard block on every commit creates friction that eventually gets bypassed with `git commit --no-verify`. A visible reminder at the right moment changes behavior without generating resistance. The next post in this series goes deeper on hooks themselves.

## Layer 3 — Write It Down, Not Tribal

Rules that live only in someone's head disappear the moment attention shifts. Rules committed to the repo survive across sessions, across collaborators, across months of project gaps.

Two locations, two audiences:

- `CLAUDE.md` — the AI reads it
- `VIBECODING.md` — humans read it

The `VIBECODING.md` diary rule: whenever a problem required multiple attempts, had a surprising root cause, or produced a lesson — add one line to the Raw Notes section. The bar is deliberately low. Actual entries from FIRE51:

> setup.sh needs `set -a && source .env` to load DB_PASS — manual export is fragile in CI/deploy

> PM2 caches env vars in its dump; `--update-env` adds/overwrites but never removes — deleting requires `pm2 delete <app> && bash setup.sh`

> Helmet 8 CSP silently adds `script-src-attr: 'none'` even when `script-src` has `'unsafe-inline'` — broke all `onclick=` handlers

Each one took 10 seconds to write. Each is worth a blog paragraph. The raw notes accumulate, and the blog posts write themselves. (This series, in fact, is largely extracted from that file.)

## Why Soft Over Hard

Hard enforcement sounds appealing. In practice, hard blocks on every commit produce `git commit --no-verify` habits within a week. The goal isn't to make violations impossible — it's to make correct behavior the path of least resistance.

A visible reminder at commit time, combined with an AI instructed to update docs as part of every task, outlasts a gating system. The ADR-generation bots and PR enforcement tools have their place in a team setting. For solo vibe coding, three layers of written discipline is lighter, cheaper, and — in my experience — more durable.

## What It Looks Like in Practice

**Before**: session ends, code committed, docs stale, lessons forgotten. Next session: AI starts from a map that's one week out of date.

**After**:
1. AI updates the relevant design doc as part of the same task
2. Pre-commit hook fires — human confirms or adds a follow-up note
3. If the fix was interesting, one line goes into Raw Notes
4. Next session starts from an accurate map and a growing journal

Cost per session: under 2 minutes. Compounding value: every future session, every blog post, every new contributor starts from reality instead of archaeology.

---

*FIRE51 is a retirement planning tool built entirely via vibe coding. This is the sixth post in the Vibe Coding series.*
