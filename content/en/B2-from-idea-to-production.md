---
title: "40 Hours: From Idea to Production"
date: 2026-04-07
published: true
lang: en
slug: from-idea-to-production
series: vibecoding
episode: 2
author: MaiMai
---

![](/blog/assets/B2_fire51_engraved_hero_en.svg)

FIRE51 is a retirement planning app with a full tax engine, JWT auth, server-side PDF, and iOS/Android apps. From architecture to deployment in roughly 40 hours of actual work — spread across four weeks on a calendar, because life doesn't stop.

That's not a productivity hack. It's a structural shift in what one architect can ship alone.

## What Shipped

About 40 hours of vibe coding produced a full-stack production app:

- Chat-driven financial data collection
- Year-by-year simulation engine (TypeScript, pure functions)
- Interactive report with charts, PDF export, CSV download
- JWT auth with OTP email
- Capacitor iOS/Android shell
- PolicyEngine tax validation suite
- Nginx + SSL + PM2 deployment on AWS Lightsail

Not a prototype. Not a demo. A working app at a real domain with real security.

## The Four-Week Arc

| Week | What Happened |
|------|--------------|
| 1 | Architecture docs, simulation engine, basic report |
| 2 | Live at fire51.com, security hardening, tax engine accuracy |
| 3 | JWT auth, OTP, mobile shell, server-side PDF |
| 4 | Polish, emoji fixes, merge to main, new VM deploy |

Each week built on the last. The design iterated. The architecture held.

## What Made It Possible

**Design docs first.** Before writing a single line of server code, the architecture was already done: a five-module system with JSON interface contracts between each layer. When the AI had that map, implementation had no integration surprises.

**Pure functions throughout.** The simulation engine runs identically on the server, in the browser, and inside the mobile app. No platform-specific branches. No synchronization headaches.

**dist/ committed.** The compiled output lives in the repo. The production server never runs a build step. On a 2 GB Lightsail instance, skipping the build step matters.

**setup.sh handles everything.** One idempotent script sets up Nginx, PM2, MySQL, SSL, and environment variables. Fresh deploy or update — same command.

## The Honest Accounting

The AI wrote roughly 95% of the lines. The architect wrote the architecture, made every major decision, caught every significant bug, and directed every course correction.

That is not "the AI built it." That is a new kind of engineering leverage.

The 5% that required a human was all judgment:
- Which module owns this responsibility
- What's out of scope for V1
- What's the right trade-off between correctness and complexity

The AI executed on those decisions faster than the architect could have typed them.

## What This Changes

The bottleneck used to be implementation. You could think clearly, design well, and still spend weeks writing code that matched the mental model.

That bottleneck is gone. An architect who focuses on describing the system precisely enough will see implementation time collapse.

What's left is the design work — which was always the harder and more valuable part anyway. The gap between having an idea and having a shipped product is now the width of clear thinking and a good architecture document.

---

*FIRE51 is a retirement planning tool built entirely via vibe coding. This is the second post in the Vibe Coding series.*
