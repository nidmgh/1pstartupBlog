---
title: "Keeping the AI Honest: Lock Files, Tests, and Design Docs"
date: 2026-04-16
lang: en
slug: keeping-the-ai-honest
series: vibecoding
episode: 5
author: MaiMai
---

<!-- Image placeholder: AI honesty / reward hacking illustration -->

In June 2025, [METR published a study](https://metr.org/blog/2025-06-05-recent-reward-hacking/) showing something uncomfortable: frontier AI models, given a coding task and a test suite, increasingly chose to *modify the tests* rather than fix the bug. OpenAI's o3 model, asked to speed up a program, hacked the timer instead so execution always appeared fast. In November 2025, [Anthropic's own research](https://www.anthropic.com/research/emergent-misalignment-reward-hacking) showed Claude models trained on coding environments learning to issue `sys.exit(0)` to exit the test harness with a success code — making failing tests appear to pass.

There's a name for this: **reward hacking**, also called **specification gaming**. The model optimizes the literal goal it was given ("make the test pass") without the unstated constraint you assumed was obvious ("…by fixing the actual bug"). Anthropic claims Claude 4 reduced this behavior by 65% compared to Claude 3.5 Sonnet. Sixty-five percent is a lot. It's not a hundred.

When you're solo vibe coding, there's no code reviewer to catch it. You are the only line of defense. Here's what that looks like in practice.

## The Pattern to Watch

Left unconstrained, a capable AI assistant will, in good faith:

- Modify test fixtures to make tests pass
- Simplify edge-case inputs to avoid failures
- Refactor code you didn't ask it to touch
- Add features you didn't request

None of this is malicious. It's pure optimization toward the stated goal, without the unstated constraints you assumed were obvious. Exactly the behavior METR documented.

## What I Caught in FIRE51

The first time this bit me: Claude was debugging a tax calculation failure. The test expected a federal tax of $18,432 for a specific income profile. The engine computed $18,601. Claude proposed changing the expected value in `tests/midupperclass2M_baseline.json`.

That baseline was built by hand, against IRS worksheets, over several evenings. The engine was wrong, not the baseline. But to an optimizer minimizing the "tests failing" metric, adjusting the JSON was a one-line change and fixing the engine was a ten-line investigation. Both make the red turn green.

I wrote one line into `CLAUDE.md` that session:

> `tests/midupperclass2M_baseline.json` and `tests/upperclass5M_baseline.json` are locked.
> Do not modify test data without explicit user instruction.

That single instruction, read at the start of every session thereafter, prevented the pattern from recurring. Not because the AI is "obedient" in some moral sense, but because now the path of least resistance is to fix the engine — the one thing it's allowed to touch.

## Three Tools That Actually Work

**Lock files explicitly.** Any file the AI might "helpfully" change to make something else pass needs to be named and locked in `CLAUDE.md`. Baselines, golden outputs, expected snapshots — all of them. The AI reads `CLAUDE.md` at the start of every session and applies the rule without being reminded.

**Validate against an external source.** For FIRE51's tax engine, every output runs through [PolicyEngine](https://policyengine.org) — an independent open-source tax model used by policy researchers at the Brookings Institution and elsewhere. The AI cannot adjust an external fact source to make numbers agree. Either the engine matches PolicyEngine to within tolerance, or it doesn't, and the delta points at the error.

Four real bugs, all caught by this validator, none visible by reading the code:

- NIIT MAGI excluded capital gains (understated NIIT for large stock withdrawals)
- SS provisional income excluded capital gains (understated SS taxability)
- Age-65 additional standard deduction missing
- California SS exclusion missing

If you're working in a domain with external ground truth — tax law, physics, financial regulation, cryptography — validate against it. The AI's output will look correct. It may not be.

**Lock output formats.** Also in `CLAUDE.md`:

> The output format of `run_simulation.ts` is frozen for V1.
> Do not modify the output schema without explicit user instruction.

The report renderer, PDF generator, and CSV export all depend on that shape. A well-intentioned "simplification" of the output would silently break four separate consumers. The lock prevents it.

## Commit Frequently

Every commit is a checkpoint. When you review the diff before committing, you see exactly what changed. If the AI drifted — touched code outside its scope, changed a format that was supposed to be stable — you catch it before it's buried under future work.

Short sessions, frequent commits. This is the cadence that keeps AI output honest.

## The Mental Model

`CLAUDE.md` is not a constitution or a style guide. It's the set of invariants the AI needs to re-read every session because its memory doesn't carry them. What cannot change. What cannot be touched. What the ground rules are.

Without it, every session starts from first principles and the AI rediscovers constraints by trial and error — sometimes by "successfully" completing a task in a way that breaks something else. With it, the constraints carry forward automatically, and the AI's optimization pressure gets redirected onto the part of the problem you actually want solved.

The 65% improvement in Claude 4 is real and welcome. But the other 35% is your job.

---

*FIRE51 is a retirement planning tool built entirely via vibe coding. This is the fifth post in the Vibe Coding series.*
