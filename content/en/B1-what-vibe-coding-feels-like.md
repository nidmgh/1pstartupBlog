---
title: What Vibe Coding Actually Feels Like
date: 2026-04-06
lang: en
slug: what-vibe-coding-feels-like
series: vibecoding
episode: 1
author: MaiMai
---

I spent over a decade writing code — fast fingers, quick turnaround, always first to finish. But I never quite understood why speed felt so hollow. Later, as an architect and product manager, I finally knew what customers and markets wanted. The thinking was sharp. But execution ran through other people, and something always got lost in translation — fidelity, nuance, the original intent.

Vibe coding feels completely different. The bottleneck moves to an entirely new place.

## The Shift

When I built FIRE51 — a retirement planning app with a full tax engine, JWT auth, PDF export, and iOS/Android apps — I wrote surprisingly little code by hand. I described what I wanted to Claude, reviewed what came back, steered corrections, and committed.

The bottleneck stopped being *typing*. It became *thinking clearly*.

The better you can articulate what you want — including the constraints, the edge cases, and especially what *not* to do — the better the result. Vague input gets vague output. Precise input gets precise output.

This is not "AI writes the app while you watch." It's a new kind of pair programming. One partner never gets tired, never forgets a function signature, and can rewrite an entire module in 30 seconds. But that partner needs clear direction and active oversight. Without it, it wanders.

## What You Still Do

You might expect vibe coding to shrink the human role. It doesn't — it changes it.

The human still:
- Owns the architecture and the big decisions
- Understands the why and the consequences of every diff before committing
- Catches when the AI over-engineers or misses the point
- Knows when output *looks right but isn't*
- Handles git, deployment, external accounts — anything with real-world state

That last one matters. The AI has no skin in the game. It can't know that deleting this table will break production. You have to carry that knowledge.

## What the AI Does Well

The things AI handles best are the things that used to drain the most energy from me:

**Consistency across files.** When you rename a function, it updates every caller. When you change a data shape, it finds every place that touched it. No more grep-and-pray.

**Implementation from spec.** Give it a precise description of what a function should do, and it writes it. Not approximately. Precisely.

**Boilerplate and scaffolding.** Auth flows, API routes, test setup — the stuff that's necessary but not interesting. Done in seconds instead of an afternoon.

**Refactoring.** "Move this logic into a separate module with this interface." It does it. Cleanly.

## What the AI Does Poorly

This is the part people don't talk about enough.

**Stale context.** Long sessions drift. The AI forgets constraints from earlier in the conversation. It starts making decisions based on assumptions it invented. The fix is short, focused sessions with a clear scope.

**Complexity creep.** Given freedom, it will over-engineer. It adds error handling for things that can't happen. It creates abstractions for one-time operations. You have to explicitly say: *don't add what wasn't asked for.*

**Judgment calls.** It can't tell you when something is "good enough." It will keep optimizing. The human has to decide when to stop.

**Unsolicited additions.** Comments, docstrings, logging statements, feature flags — it will add them unless you tell it not to. Every session, fresh instructions help.

## The Practical Shift

The biggest adjustment isn't technical. It's learning to communicate with precision.

In traditional coding, fuzzy thinking produces working-but-messy code. You can write your way to clarity. In vibe coding, fuzzy thinking produces output you'll spend an hour unwinding.

The discipline I developed:
- Start each session with the scope written out
- State explicitly what should *not* change
- Review diffs, not just the final file — drift hides in the middle
- Use a clear guiding document to keep scope controlled and development on track

## Why It Works

When I shipped FIRE51, the thing that surprised me most wasn't how fast it went. It was how *complete* the result was. Features I would have skipped or simplified — the mobile apps, the server-side PDF, the tax validation — were all there, because the cost of implementation had dropped so much.

<div class="mobile-screenshots">
  <img src="/blog/assets/B1-mobile-1.jpeg" alt="FIRE51 mobile app screen 1">
  <img src="/blog/assets/B1-mobile-2.jpeg" alt="FIRE51 mobile app screen 2">
  <img src="/blog/assets/B1-mobile-3.jpeg" alt="FIRE51 mobile app screen 3">
</div>

That's the real change. The gap between "I want this" and "the product exists" has shrunk to the width of a clear description.

---

*FIRE51 is a retirement planning tool built entirely via vibe coding. The lessons from that build are the source of this series.*
