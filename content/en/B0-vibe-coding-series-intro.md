---
title: "Why I Built FIRE51 — Alice Just Punched Through the Paper Wall of Coding"
date: 2026-04-06
lang: en
slug: vibe-coding-series-intro
series: vibecoding
episode: 0
author: MaiMai
---

![](/blog/assets/B0_hero_en.svg)

The biggest change AI brings to software isn't making programmers faster.

The real change is this: **the barrier to building software is disappearing.**

For decades, the tech industry ran on a hidden structure — lots of people with ideas, very few who could implement them. Programming languages, frameworks, architecture, deployment: these technical details formed a towering barrier. No matter how deep your expertise, if you couldn't cross it, your ideas stayed ideas.

Vibe coding is tearing that down — exposing what was always just a paper wall pretending to be stone.

---

## Alice's MemPalace

I'm not the only one proving this out.

Milla Jovovich — actress, best known as Alice in the Resident Evil franchise — just open-sourced an AI memory system on GitHub and scored the first-ever perfect score on the industry-standard benchmark. Yes, that Milla Jovovich 🤯

<div class="story-images">
  <figure>
    <img src="/blog/assets/B0_Resident-Evil.jpg" alt="Milla Jovovich as Alice in Resident Evil">
    <figcaption>Milla Jovovich as Alice — now also a GitHub contributor with 11k stars</figcaption>
  </figure>
  <figure>
    <img src="/blog/assets/B0_Greek_oratory.avif" alt="Ancient Greek memory palace technique">
    <figcaption>Ancient Greek orators memorized entire speeches using imaginary buildings — the inspiration for MemPalace</figcaption>
  </figure>
</div>

Here's the story: after months of daily AI conversations, she'd accumulated hundreds of decisions, ideas, and thinking — all of it disappearing at the end of every session. Existing memory systems let the AI decide what's worth remembering. That wasn't what she wanted.

So she and a friend spent a few months building [MemPalace](https://github.com/milla-jovovich/mempalace) with Claude Code. The concept draws from the ancient Greek memory palace technique: instead of extracting summaries, you organize memory into a navigable spatial structure — wings, halls, rooms. The result: the first perfect score on the LongMemEval benchmark, MIT licensed, fully local, 11,000+ GitHub stars.

**When the barrier to coding disappears, what determines the ceiling is domain knowledge, systems thinking, and product judgment.** MemPalace is living proof.

---

## A Split Already Happening

The next 12 months may mark a genuine turning point.

Programmers are splitting into two groups:

- **80%** who are primarily doers — translating requirements and architecture diagrams into code — will face compression
- **20%** who think in systems and architecture will return to the central role they always deserved

The people whose job was to translate specs into code are in a position not unlike assembly-line workers a century ago: once indispensable, then quietly displaced by automation.

But this isn't only a story about programmers.

People with deep expertise in finance, medicine, law, manufacturing — they're facing a rare historical opening. What they lacked was never knowledge. It was the ability to turn that knowledge into software. That ability is now becoming accessible. They can build products in their own domains without waiting for a technical co-founder, without learning to code first.

---

## From Theory to Practice

Two years ago I started thinking seriously about what AI means for domain experts. I shared these views at a few conferences last year. But honestly, it was still theoretical.

This spring I decided to find out for myself.

One rule: vibe coding tools only. No hand-written code. Just product decisions and architectural direction.

I completed two projects:

**1pstartup.com** — from idea to live site, about two hours. The site itself isn't technically complex. But it demonstrates something important: work that used to require outsourcing or hiring can now be done by one person in an afternoon.

**FIRE51.com** — a full retirement planning app. Roughly 40 hours: a tax simulation engine, interactive reports, PDF export, JWT authentication, iOS and Android mobile shells.

---

## What FIRE51 Actually Proves

FIRE51 isn't a prototype or a demo. It's a production app — facing real users, with validated tax logic and mobile packaging.

The initial UI took a few hours. What took real time was: getting the tax logic right, modeling the domain accurately, designing the architecture, and learning how to guide the AI toward correct decisions and away from plausible-but-wrong ones. Two more days went into UX polish before launch.

Almost no code was written by hand. But the project required:

- Clear product judgment
- Solid domain knowledge (retirement planning, US tax law)
- Systems thinking
- Continuous review of AI output

The conclusion: **vibe coding doesn't make thinking optional. It just moves the thinking from "how to implement" to "what to build."**

---

## Not a Crisis — a Release

The instinct when hearing "AI replaces jobs" is anxiety.

Flip it. For people with real domain expertise, this is a rare kind of liberation.

Before: you needed to be a programmer first, and an expert second.

Now: you can start from what you actually know — finance, medicine, education, law — and build software that embodies that knowledge. Without a technical co-founder. Without pitching investors on a team you don't have yet. Without spending two years learning to code before you can test a single idea.

That's the real change vibe coding makes.

---

## What This Series Covers

The posts that follow document what actually happened building FIRE51:

- Architecture decisions and design documents
- What AI does well, and where it fails quietly
- Validating a tax engine against an independent ground truth
- Seven problems with PDF generation (and how we solved them)
- Git hooks, CLAUDE.md, and keeping docs in sync with code
- A complete cost breakdown — under $55/month for a production stack

This isn't a tutorial. It isn't AI hype.

It's an honest record of what building software looks like **when the barrier to entry is gone.**

---

*FIRE51 is a retirement planning tool built entirely via vibe coding. The lessons from that build are the source of this series.*
