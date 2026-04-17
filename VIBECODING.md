# Vibe Coding — Tips, Lessons & Best Practices

## Series Title
**English:** Vibe Coding — The Real Test of Product Thinking and Architecture
**Chinese:** Vibe Coding — 产品思维与架构能力的试金石

Captured from building FIRE51: a production retirement planning web app with iOS/Android shell,
JWT auth, server-side PDF, and a tax validation pipeline — built entirely via AI-assisted coding.

This document is the raw material for a blog series. Each section maps to a potential post.

---

## What Is Vibe Coding?

Vibe coding is building software by describing intent to an AI coding assistant and iterating on
the output — rather than writing every line manually. The human drives architecture, decisions,
and quality judgment. The AI handles implementation, boilerplate, debugging, and consistency.

It is not "AI writes the app." It is a new kind of pair programming where one partner never
gets tired, never forgets syntax, and can rewrite an entire module in seconds — but needs
clear direction and active oversight to stay on track.

---

## Blog Series Outline

| # | Title | Theme |
|---|-------|-------|
| B0 | **Why I built FIRE51 — and what it proves about AI** | Preface: FIRE51 as a testament to how vibe coding will shape software in the next 12 months |
| B1 | **What vibe coding actually feels like** | Philosophy, workflow, what changes vs traditional dev |
| B2 | **From idea to production in days, not months** | Full-stack deployment on AWS Lightsail |
| B3 | **What does vibe coding actually cost?** | Full cost breakdown: domain, hosting, AI tools, hardware — under $55/month |
| B4 | **Start with the architecture doc, not the code** | Design-first with AI |
| B5 | **Keeping AI honest: locking files, tests, and design docs** | Quality control in vibe coding |
| B6 | **Code and docs in sync: three layers of enforcement** | Discipline and process in vibe coding |
| B7 | **Git hooks: your silent co-pilot** | Automating quality gates without slowing down |
| B8 | **PDF generation hell: 7 problems and how we solved them** | Deep technical case study |
| B9 | **Emoji killed my iOS app** | Cross-platform Unicode pitfalls |
| B10 | **Tax engine accuracy: using PolicyEngine to validate AI-written code** | Testing financial logic |
| B11 | **Keep CLAUDE.md short** | Why the must-read instruction file must stay lean |
| B12 | **The post-milestone doc audit** | After every major ship, stale docs are guaranteed — here's how to find them |
| B13 | **What vibe coding can't do (yet)** | Honest limitations and failure modes |

---

## Blog Publishing Order

The arc: hook readers → show it's achievable → teach discipline → dive technical → close honestly.

### Wave 1 — Hook & Orient (posts 1–4)

| Pub # | Post | Why here |
|---|---|---|
| 1 | **B0** — Why I built FIRE51 | Preface; stakes the claim that vibe coding is a paradigm shift |
| 2 | **B1** — What vibe coding feels like | Entry point; sets up the whole series |
| 3 | **B2** — Idea to production in days | Proof it works; keeps readers reading |
| 4 | **B3** — What does it actually cost | Removes the "is this accessible to me?" barrier early |

### Wave 2 — How to Do It Right (posts 5–8)

| Pub # | Post | Why here |
|---|---|---|
| 5 | **B4** — Start with the architecture doc | First discipline lesson; before showing how to enforce it |
| 6 | **B5** — Keeping AI honest | Quality control; natural follow-on to "the AI moves fast" |
| 7 | **B6** — Code and docs in sync | Process layer on top of B5 |
| 8 | **B7** — Git hooks | Tooling that automates what B6 describes |

### Wave 3 — Technical War Stories (posts 9–11)

| Pub # | Post | Why here |
|---|---|---|
| 9 | **B8** — PDF generation hell | Richest technical case study; good for sharing |
| 10 | **B9** — Emoji killed my iOS app | Short, punchy, surprising — good mid-series pacing |
| 11 | **B10** — Tax engine validation | Shows how to validate AI-written domain logic |

### Wave 4 — Maturity & Honest Close (posts 12–14)

| Pub # | Post | Why here |
|---|---|---|
| 12 | **B11** — Keep CLAUDE.md short | Process refinement — feels earned after the war stories |
| 13 | **B12** — Post-milestone doc audit | *(needs to be written first — see flag below)* |
| 14 | **B13** — What vibe coding can't do | Best closer: honest, grounded, leaves readers with the full picture |

### Flags

- **B12 needs to be written.** The raw note ("after every major milestone, stale docs are guaranteed — here's how to find them") is a good seed but the post doesn't exist yet. Either write it before publishing slot 13, or swap B13 to slot 13 and end with B12.
- **B3 (cost) as post 4** is deliberate — it's a natural objection that, if left unanswered, causes readers to disengage early. Moving it later risks losing them.

---

## B1 — What Vibe Coding Actually Feels Like

### The shift
Traditional coding: you know what to write, you just have to write it.
Vibe coding: you know what you want, you describe it, you judge the output.

The bottleneck moves from *typing* to *thinking clearly*. The better you can articulate
what you want — including constraints, edge cases, and what not to do — the better the result.

### What the human still does
- Owns the architecture and major decisions
- Reviews every diff before committing
- Catches when the AI drifts or over-engineers
- Knows when output is wrong even if it looks right
- Manages git, deployment, external accounts

### What the AI does well
- Implements a spec precisely and completely
- Maintains consistency across many files simultaneously
- Remembers every function signature and type in the codebase
- Refactors without breaking interfaces
- Writes tests for code it just wrote

### What the AI does poorly
- Assumes context it doesn't have (stale memory)
- Drifts toward complexity when simple is right
- Can't judge "good enough" vs "perfect"
- Adds unsolicited features and comments
- Loses track of constraints from earlier in the conversation

### Tips
- Give explicit negative constraints: *"don't add error handling for cases that can't happen"*
- Say what you want, not how to do it — let the AI pick the implementation
- Review diffs, not just the final file — drift hides in the middle
- Short focused requests outperform long multi-part ones

---

## B2 — From Idea to Production in Days, Not Months

### What shipped
Full-stack production app with:
- Chat-driven financial data collection
- Year-by-year simulation engine (TypeScript, pure functions)
- Interactive report with charts, PDF export, CSV download
- JWT auth with OTP email
- Capacitor iOS/Android shell
- PolicyEngine tax validation suite
- Nginx + SSL + PM2 deployment on AWS Lightsail

### Timeline
| Week | Work |
|------|------|
| 1 | Architecture docs, engine, basic report |
| 2 | Live at fire51.com, security hardening, tax engine accuracy |
| 3 | JWT auth, OTP, mobile shell, server-side PDF |
| 4 | Polish, emoji fixes, merge to main, new VM deploy |

### Key enablers
- **Design docs first** — no integration surprises
- **Pure functions** — engine runs identically on server, web, and mobile
- **dist/ committed** — no build step on low-RAM server
- **setup.sh** — idempotent one-command deploy

### Honest accounting
The AI wrote ~95% of the lines. The human wrote the architecture, made every major decision,
caught every significant bug, and directed every course correction.
That is not "the AI built it." That is a new kind of engineering leverage.

---

## B3 — What Does Vibe Coding Actually Cost?

One of the first questions people ask about vibe coding: *what does it cost to run?*

The honest answer: less than a gym membership you never use. Here's the full breakdown for
building and running FIRE51 — a production web app with iOS/Android shell, JWT auth, MySQL,
tax engine, and a PolicyEngine validation suite.

### The Stack

| Item | Cost | Notes |
|------|------|-------|
| **Domain** (IONOS) | $10–15/year | fire51.com — IONOS pricing is notably cheaper than GoDaddy/Namecheap for .com |
| **AWS Lightsail** | $12/month | 2 GB RAM · 2 vCPUs · 60 GB SSD — handles dev, staging, and production |
| **Cursor** | $0 | Free tier — used as the primary IDE with AI completions |
| **Claude Code** | $20/month | Pro plan — the primary AI coding agent (this document was written with it) |
| **ChatGPT** | $20/month | GPT-4o — used for research, drafting, second opinions on architecture |
| **Hardware** | sunk cost | MacBook Pro M1 2020, 8 GB RAM — no GPU, no server, just a laptop |

**Monthly total: ~$53/month** (~$636/year including domain)

### What You Get for $53/Month

- A production web app live at a real domain with SSL
- Staging environment on the same server (separate PM2 process)
- AI pair programmer available 24/7, never tired, never complaining about the codebase
- Two AI systems for cross-checking: Claude for implementation, ChatGPT for research and review
- Full IDE with inline completions (Cursor)

Compare that to: one hour of a senior developer's consulting time.

### Where the Money Actually Goes

The $12/month Lightsail instance is doing more than it looks like:
- PM2 manages two processes (prod + staging/dev)
- MySQL serves the app, stores reports, OTP codes, tax validation samples
- Nginx handles SSL termination and reverse proxy for both
- Node.js runs the Express server + simulation engine

The M1 MacBook with 8 GB is the honest constraint. It's enough for everything — TypeScript
compilation, local MySQL, running tests, Cursor with AI completions — but it's not a powerhouse.
The limited RAM means keeping Chrome, IDE, and the local dev server open simultaneously is
occasionally sluggish. No complaints for the price.

### The AI Tool Split

**Claude Code ($20/month):** primary workhorse. Used for all code generation, refactoring,
debugging, doc writing, and test authorship. The agentic loop (read → plan → implement → test)
is where most of the vibe coding happens. This document was written inside Claude Code.

**ChatGPT ($20/month):** research and second opinion. Tax law edge cases, IRS publication
lookup, architecture trade-offs, and occasionally "does this explanation make sense to a
non-programmer?" It's the research assistant; Claude Code is the implementer.

**Cursor (free):** the IDE layer. Inline completions and quick file navigation. Less used for
agentic work than Claude Code, but valuable for staying oriented in the codebase while Claude
Code is doing something in another file.

### The Free Tier Ceiling

Cursor's free tier has limits — message caps per month and no access to the largest models.
For a solo project moving at vibe coding pace, the free tier holds up well. The moment you're
blocked by the cap is the moment to upgrade; for FIRE51, that moment hasn't come.

### What This Means for Aspiring Vibe Coders

You don't need a powerful machine, an expensive IDE license, or a complex cloud setup.
The barrier is:

1. $20/month for a capable AI agent (Claude Code or equivalent)
2. $12/month for a small cloud server (or use a free tier VPS to start)
3. A laptop that can run a code editor and a terminal

Everything else — frameworks, runtime, database, web server — is open source and free.

The real cost of vibe coding is **attention, not money**. You need to read every diff,
validate every design decision, and maintain quality judgment throughout. The AI does the
typing; you do the thinking. That's the deal, and it's a good one.

### Fine Print

**¹ ChatGPT isn't an extra cost here.** The $20/month ChatGPT subscription predates this project
by years — it was already part of the author's workflow long before FIRE51 was conceived. If
you're starting fresh and need to pick one AI tool, Claude Code alone covers most of what you need.
ChatGPT becomes valuable as a second opinion and research partner, not a requirement.

**² You can run this on $5/month.** The $12/month Lightsail instance (2 GB RAM) was chosen
to support server-side PDF generation via Puppeteer, which is memory-hungry. If you skip that
feature — or use `window.print()` like FIRE51 currently does — the $5/month Lightsail plan
(512 MB RAM, 2 vCPUs, 20 GB SSD) handles Node.js + MySQL + Nginx just fine. Start there and
upgrade only when you hit a real constraint.

**³ Perspective on the $53/month.** A typical software company pays a programmer
$1,000–$2,000+/month fully-loaded (salary, benefits, overhead) for a single contributor, with
no guarantee they'll ship something. This stack delivers a production-grade full-stack app —
simulation engine, tax validation pipeline, JWT auth, iOS/Android shell, PDF export — for a
fraction of that. The economics are not comparable; they're from different worlds.

This isn't a tutorial for companies optimizing engineering headcount. It's for whoever is
building their dream in a garage.

---

## B4 — Start with the Architecture Doc, Not the Code

### The mistake
The instinct is to start coding immediately. With AI assistance, you *can* — but you'll spend
twice as long fixing the result. The AI needs a map. Without one, it invents its own.

### The practice
Write `ARCHITECTURE.md` first. Define:
- Module boundaries (what each piece owns)
- Data contracts between modules (JSON shapes)
- Technology choices with rationale
- What's explicitly out of scope

When the AI has this document, every implementation decision has a reference point.
When it doesn't, you get plausible-looking code that doesn't fit together.

### From FIRE51
Before writing a single line of server code, we defined:
- Five modules (Inputs → Engine → Output → Suggestions → Strategy Tester)
- JSON interface contracts (`interface_m1_m2.json`, `interface_m2_m3.json`)
- Year-loop order (Income → Expenses → RMD → Conversion → Tax → Withdrawals → Growth → Flags)

The engine was then implemented exactly to spec. No surprises at integration time.

### Tips
- Update the architecture doc *before* you change the code — not after
- Use the doc to say no: "that's out of scope per ARCHITECTURE.md §3"
- When the AI proposes something inconsistent with the doc, catch it early

---

## B5 — Keeping AI Honest: Locking Files, Tests, and Design Docs

### The problem
AI coding assistants are helpful and agreeable. Too agreeable. Left unconstrained, they will:
- Modify test data to make tests pass
- Simplify inputs to avoid edge cases
- Refactor code you didn't ask them to touch
- Add features you didn't request

### What we did

**Lock stable files explicitly.** In `CLAUDE.md`:
> `midupperclass2M_baseline.json` and `upperclass5M_baseline.json` are locked.
> No data changes without explicit user order.

This single instruction prevented the AI from "fixing" test failures by changing the inputs
instead of the code.

**Use a real validation suite.** We used PolicyEngine (an independent tax calculator) to
verify the tax engine output. The AI cannot fool an external ground truth.

**Keep output format stable.** Also in `CLAUDE.md`:
> `run_simulation.ts` output format is locked for V1. Do not modify without explicit user order.

**Commit frequently.** Each commit is a checkpoint. If the AI drifts, you can see exactly
where in the diff.

### Tips
- Write your constraints in `CLAUDE.md` — the AI reads it every session
- Lock anything the AI might "helpfully" change to make something else work
- Treat test failures as real failures, not as invitations to change the test

---

## B6 — Code and Docs in Sync: Three Layers of Enforcement

### The problem
In vibe coding, the AI writes code fast. Documentation drifts fast too.
After a few sessions, the design docs describe a system that no longer exists.
New sessions start from a stale map. Decisions get re-litigated. Bugs reappear.

The root cause: there is no natural forcing function. In a team, code review catches drift.
In a solo vibe coding session, nothing does — unless you build it in deliberately.

### The three layers

#### Layer 1 — AI standing orders (`CLAUDE.md`)
`CLAUDE.md` is read at the start of every session. It is the AI's persistent instruction set.
Put the discipline rules there and the AI will apply them automatically — without being reminded.

In FIRE51, `CLAUDE.md` now contains:

- A **doc sync table**: maps each code area to the doc that must be updated with it
- A **VIBECODING.md diary rule**: defines what kind of observations belong in raw notes
- A **pre-commit checklist**: 4 questions to answer before every commit
- The **locked files list**: files the AI must never touch without explicit instruction

This is the highest-leverage layer. It costs nothing at commit time and shapes every session.

```
| Code changed                        | Doc to update              |
|-------------------------------------|----------------------------|
| Engine logic, tax, RMD              | MODULE2_DESIGN.md          |
| Auth, OTP, server routes            | GOLIVE_DESIGN.md           |
| Mobile / Capacitor                  | CAPACITOR_DESIGN.md        |
| Architecture / module boundaries    | ARCHITECTURE.md            |
| Any hard problem or surprising fix  | VIBECODING.md Raw Notes    |
```

#### Layer 2 — Git pre-commit hook (human reminder)
A pre-commit hook fires on every `git commit`. It cannot be forgotten.

The hook in FIRE51:
- Detects when `src/` or `public/` files are staged but no `.md` files are
- Prints a visible reminder box — *soft warning, does not block the commit*
- Hard-blocks only for `TaxEngine.ts` changes that fail PolicyEngine validation

```
  ┌─────────────────────────────────────────────────────────┐
  │  Doc sync reminder                                      │
  │                                                         │
  │  Code changed but no .md files staged.                  │
  │  → Did the relevant design doc get updated?             │
  │  → Anything worth adding to VIBECODING.md Raw Notes?   │
  └─────────────────────────────────────────────────────────┘
```

Soft by design. A hard block on every commit would create friction and get bypassed.
A visible nudge at the right moment is enough.

#### Layer 3 — Cultural: written down, not tribal
The discipline is documented in two places:
- `CLAUDE.md` — the AI reads it
- `VIBECODING.md` (this file) — the human reads it

When rules exist only in someone's head, they disappear the moment attention shifts.
When they are written and checked into the repo, they persist across sessions, collaborators,
and months of time away from the project.

### Why soft enforcement beats hard enforcement here

Hard enforcement (block commits without doc updates) sounds appealing.
In practice it creates friction that gets bypassed: `git commit --no-verify` exists for a reason.

The goal is not to make violations impossible. It is to make the right behavior the path of
least resistance. A visible reminder at commit time, combined with an AI that was instructed
to update docs as part of every task, is more durable than a gate.

### The diary rule

Every time a problem required multiple attempts, had a surprising root cause, or produced a
lesson — add one bullet to `VIBECODING.md` Raw Notes. One line is enough.

The bar is low deliberately. A note that says:
> "setup.sh needed `set -a && source .env` to load DB_PASS — manual export is error-prone"

takes 10 seconds to write and is worth a paragraph in a blog post.

The raw notes accumulate. The blog posts write themselves.

### What this looks like in practice

Before: a session ends, code is committed, docs are stale, the lesson is forgotten.

After:
1. AI updates the relevant design doc as part of the same task
2. Pre-commit hook fires — human confirms or adds a follow-up note
3. If the problem was interesting, one bullet goes into Raw Notes
4. Next session starts with an accurate map and a growing diary

The overhead per session: under 2 minutes. The compounding value: every future session,
every blog post, every new contributor starts from truth instead of archaeology.

---

## B7 — Git Hooks: Your Silent Co-Pilot

### What they are

Git hooks are shell scripts that git runs automatically at specific points in the workflow.
They live in `.git/hooks/` and git calls them by name — no configuration needed.

```
.git/hooks/
  pre-commit     ← fires before the commit is created
  commit-msg     ← fires after you type the commit message
  pre-push       ← fires before git sends to remote
  post-commit    ← fires after commit is done (can't abort)
```

When you run `git commit`, git looks for `.git/hooks/pre-commit`. If it exists and is
executable (`chmod +x`), git runs it:
- Exit `0` → commit proceeds
- Exit non-zero → commit aborted

### What FIRE51 uses

**`pre-commit`** — fires on every `git commit`:
- Staged `src/` or `public/` files with no `.md` staged → prints doc sync reminder (soft, exits `0`)
- `TaxEngine.ts` staged → runs PolicyEngine validation → hard blocks if tests fail (exits `1`)

**`pre-push`** — fires before every `git push`:
- `TaxEngine.ts` changed vs remote → runs PolicyEngine validation → blocks push if failed

Two different hooks, two different moments. Pre-commit catches issues before they're recorded.
Pre-push is the last line of defense before they reach the remote.

### Quick reference

| Hook | When | Exit non-zero to |
|------|------|-----------------|
| `pre-commit` | Before commit is created | Abort commit |
| `commit-msg` | After message is written | Abort commit |
| `pre-push` | Before push to remote | Abort push |
| `post-commit` | After commit is done | (can't abort) |
| `pre-rebase` | Before rebase starts | Abort rebase |

### The key limitation: hooks aren't committed

`.git/hooks/` is excluded from git tracking by design. A fresh `git clone` gets an empty
hooks folder. Other collaborators don't get your hooks automatically.

Standard workarounds:
1. **`setup.sh` copies them** — commit hooks to `scripts/hooks/`, have setup.sh symlink or copy into `.git/hooks/`
2. **`package.json` + husky** — npm package that manages hooks as part of the project
3. **Document and trust** — works fine for solo or small teams

FIRE51 uses option 3 currently. Option 1 is the right next step when collaborators join.

### Soft vs hard enforcement

The doc-sync reminder is soft (exits `0`, never blocks). The tax validation is hard (exits `1`,
blocks the commit). This is intentional.

**Hard is right when:** a violation is objectively broken (tests fail, linting errors, secret
detected). The cost of a bad commit is high enough that friction is justified.

**Soft is right when:** the check is a reminder about a practice, not a correctness gate.
Making doc updates a hard block would generate `git commit --no-verify` habits immediately.
A visible nudge at the right moment changes behavior without creating resistance.

### In vibe coding specifically

Hooks are a natural fit for vibe coding because the AI moves fast. Without a gate, bad habits
compound across sessions. With hooks, quality checks happen at the one moment when attention
is naturally on the commit — before it's done.

The AI can write the hooks too. In FIRE51, the pre-commit hook was written by Claude, committed,
and has been running silently ever since. Zero maintenance cost. Persistent guardrails.

---

## B8 — PDF Generation Hell: 7 Problems and How We Solved Them

PDF generation from a web report sounds simple. It took more iteration than any other feature.

| # | Problem | Root Cause | Solution |
|---|---------|-----------|----------|
| 1 | Puppeteer OOM crash on 512MB server | Chromium spawns full browser process | `--single-process --no-sandbox`; build locally, rsync dist/ |
| 2 | CDN scripts (Chart.js) not loading | `page.setContent()` doesn't execute external fetches | Switch to `page.goto(file://)` |
| 3 | Charts blank in PDF | Chart.js animations async; Puppeteer captures too early | `?pdf=1` param → `Chart.defaults.animation = false` |
| 4 | Watermark hidden by white background | `@media print` reset made all cells opaque | Semi-transparent `rgba` backgrounds; explicit body override |
| 5 | iOS `window.print()` silent no-op | WKWebView doesn't implement print | Three-path export: native → server Puppeteer → guided toast |
| 6 | JWT missing in Capacitor in-app browser | `localStorage` not shared across WKWebView contexts | Read JWT from URL query param as fallback |
| 7 | PDF captured before render completes | Async chart + table draw | `window.__reportReady = true` sentinel; `waitForFunction` |

### Lesson
Server-side PDF via headless browser is the right architecture for cross-platform consistency.
But it requires explicit synchronization with the page's render lifecycle — the browser doesn't
tell you when JavaScript is done drawing.

---

## B9 — Emoji Killed My iOS App

### The problem
Icons rendered fine in Chrome, fine in iOS Simulator. On a real iOS device: `[?][?][?]`.

Every Unicode symbol outside the basic Latin range is at risk on iOS WebView if the font
doesn't include it. Even common symbols like ☰ (hamburger menu) and ⬆ (arrow) fail.

### Four passes to fix it

| Pass | Approach | Result |
|------|----------|--------|
| 1 | Add `system-ui` font fallback | Fixed some, not all |
| 2 | Replace with HTML entities | Still broke for some glyphs |
| 3 | Replace with ASCII alternatives | Partially worked |
| 4 | CSS `::before` pseudo-elements with explicit font-size/color | Fixed all |

### The rule
**Never use emoji or Unicode symbols in a web app targeting iOS WebView.**
Use CSS pseudo-elements, SVG icons, or icon fonts (with a fallback).

### Lesson
Test on a real device, not just the simulator. The simulator uses macOS fonts.
The device uses iOS fonts. They are not the same.

---

## B10 — Tax Engine Accuracy: Using PolicyEngine to Validate AI-Written Code

### The problem
The AI writes plausible financial code. Plausible is not correct.
A retirement projection with a 5% tax error compounds over 45 years into a meaningless number.

### The approach
PolicyEngine is an open-source microsimulation model used by policy researchers.
We used it as an independent ground truth to validate our tax engine output.

**Pipeline:**
1. Run FIRE51 simulation → capture tax inputs + outputs for key years to MySQL
2. `npm run validate:pe` → batch call PolicyEngine, compare results, flag outliers
3. `npm run validate:report` → side-by-side comparison table

**Tolerances:** federal ±$100, state ±$300, NIIT ±$50, SS taxable ±$50

**Bugs found via validation:**
- NIIT MAGI excluded capital gains (understated NIIT for large stock withdrawals)
- SS provisional income excluded capital gains (understated SS taxability)
- Age-65 additional standard deduction missing
- CA SS exclusion missing

All found by the validator, not by reading the code.

### Tip
For any domain with an external ground truth (tax law, financial regulations, physics),
validate against it. The AI's output will look correct. It may not be.

---

## B11 — Keep CLAUDE.md Short

### The problem with a long instruction file

In vibe coding, `CLAUDE.md` is loaded into the AI's context at the start of every session.
It's the single most powerful lever you have to shape AI behavior across conversations —
more reliable than memory, more persistent than inline prompts.

But it only works if it's actually read and applied. And that requires it to be short.

A 200-line `CLAUDE.md` is a trap. The file starts with the right idea — discipline rules,
locked files, pre-commit checklist. Then, gradually, someone (or the AI) adds project context,
scenario descriptions, architecture diagrams, design notes. Each addition seems harmless.
Together, they bury the instructions that matter.

The AI loads the whole file, but it's optimizing for relevance. A discipline rule on line 5
carries more weight than the same rule on line 150, surrounded by historical context it doesn't
need to act on today.

### The rule: CLAUDE.md is instructions, not documentation

Everything in `CLAUDE.md` should answer one of these questions:
- What must I always do? (discipline rules, doc sync table)
- What must I never do? (locked files, banned patterns)
- What do I need to know to write correct code right now? (year-loop order, V1 simplifications)
- Where do I look for details? (doc index pointers)

If it doesn't answer one of those questions, it belongs in a design doc, not `CLAUDE.md`.

**Move to design docs:**
- Project overview → `FIRE51.md`
- Scenario descriptions → `NEXT_STEPS.md` or `ARCHITECTURE.md`
- Architecture diagrams → `ARCHITECTURE.md`
- Known simplifications → `DEFERRED.md`
- Historical milestones → `NEXT_STEPS.md`

### What to keep

The FIRE51 `CLAUDE.md` went from 196 lines to 69 after trimming. What stayed:

1. **Discipline rules** — doc sync table, VIBECODING diary rule, locked files, pre-commit checklist.
   These are behavioral instructions the AI must apply on every task.

2. **Key technical facts** — year-loop order, conversion strategies, withdrawal priority, growth rates,
   V1 simplifications still in place. Facts the AI needs to write *correct* engine code without
   reading three other files first.

3. **Doc index** — one-line pointers to the right doc for each domain. Keeps CLAUDE.md thin while
   giving the AI a map to deeper context when needed.

### The benefit

When `CLAUDE.md` is 69 lines, the discipline rules are impossible to miss. The AI applies them
consistently because they dominate the instruction context — not because it's trying to remember
something from line 150 of a wall of text.

Short = loud. The most important instructions should be the only instructions.

### The maintenance rule

When adding to `CLAUDE.md`, ask: *is this a rule the AI must follow, or context it might find useful?*
Rules belong here. Context belongs in the doc it describes.

Review `CLAUDE.md` length whenever you notice the AI missing instructions it should know. Bloat
is usually the cause.

---

## B13 — What Vibe Coding Can't Do (Yet)

### Honest limitations

| Limitation | What happens | Workaround |
|------------|-------------|------------|
| **Stale context** | Forgets decisions from prior sessions | Maintain `CLAUDE.md` + memory files |
| **Coordinate blindness** | Can't see where UI elements are on screen | Computer-use API (expensive); describe layout explicitly |
| **No taste** | Can't judge if UX is good, only if it works | Human reviews every screen |
| **Billing systems** | Can't access AWS console, DNS, payment accounts | Human does all external account work |
| **Interactive terminal** | Can't handle prompts requiring keyboard input | Pass `--non-interactive` flags; script around it |
| **Cost at scale** | Computer-use for UI testing: ~$0.50/run | Deferred; use `?test` mode instead |

### The irreducible human role
- Vision: what should this product be?
- Judgment: is this output actually correct?
- Taste: does this feel right to a user?
- Accountability: who is responsible when it's wrong?

These don't go away. They become the entire job.

---

## Raw Notes (Unprocessed)

*Add observations here as they happen — process into blog posts later.*

- setup.sh needed to load `.env` automatically — manual `export DB_PASS=` is error-prone in CI/deployment
- Staging and production on same Lightsail instance = resource contention risk; dedicated VM better
- Computer-use API promising for UI regression testing but cost prohibitive at current pricing
- `dist/` committed to repo is pragmatic for low-RAM servers but creates noise in git log
- PolicyEngine AGPL license: local-only use OK; do not ship in app binary or expose via API
- Alpha test mode (`test@fire51.com`) reduces friction for sharing with testers significantly
- Helmet 8 CSP silently adds `script-src-attr: 'none'` even when `script-src` has `'unsafe-inline'` — broke all `onclick=` handlers; needed explicit `scriptSrcAttr: ["'unsafe-inline'"]`
- `CALENDAR_YEAR_AT_START` as module-level const becomes stale in long-running Node.js processes — wrap in a function called per-scenario
- Single-use download tokens (60s TTL, consumed on first use) cleanly replace JWT-in-URL without needing httpOnly cookies — works with Capacitor too
- CLAUDE.md must stay short — it's the AI's must-read doc every session; bloat means the discipline rules get buried or ignored
- After shipping Phase 1, a grep for "V1" across all docs revealed 5 stale references: features labeled "planned" or "not yet implemented" that had already shipped — run a doc audit after every major milestone
- Reading design docs against actual source code (MODULE2, TAX_ENGINE) caught 4 major gaps: SS provisional income test, NIIT, IRMAA, and the convergence loop were all implemented but still labeled as V2 future work — doc/code drift accumulates silently

- Summary screen between computing→report: server returns `summaryCards` + `earlyOutAge` in the done response; client renders 2×2 grid with interpretive taglines before navigating to report
- PDF semaphore (max 1 concurrent Chrome) prevents OOM on 2-vCPU/1.9 GB server — second request queues transparently; browser shows pending download naturally
- Test profiles extracted to public/test-profiles.js — editable without a build step; index.html reads window.TEST_PROFILES at runtime
- PM2 caches env vars in its dump; `--update-env` adds/overwrites but never removes — deleting a variable requires `pm2 delete <app> && bash setup.sh`; switched test mode gate to a file flag (`.test-mode`) to avoid this entirely
- Always commit before a session ends — context-limit summaries don't capture uncommitted working-tree changes; the server only gets what's pushed
- Not every feature in an AI product needs to call an LLM: the advisor letter (300-word personalized report summary) is pure template substitution — deterministic, zero API cost, zero latency, no hallucination risk; use LLMs where judgment is needed, templates where structure is enough
- Per-year state switching for "Move to FL": moving `getStateTaxConfig()` inside the year loop (vs. before it) was a 2-line change that unlocked mid-simulation state transitions; the key was that `computeTax()` already accepted `StateTaxConfig` as a parameter — no signature changes needed
- Binary search optimizer must co-update paired scenarios: when `optimizeEarlyOut()` finds the optimal early-retirement age, `state_move` (which mirrors early_retire) must also be updated to the same age — otherwise the two scenarios diverge silently; added `buildStateMoveAtAge()` alongside `buildEarlyOutAtAge()` with a shared `map()` return
