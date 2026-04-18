# 1pstartupBlog — Claude Project Instructions

This project builds and maintains the blog system for:

https://1pstartup.com/blog

This blog supports Vibe Coding content and future topics including:
- AI coding
- startup ideas
- engineering lessons
- humanities
- history

This is a static markdown blog with bilingual support.

---

# Core Goals

- Static markdown blog (no CMS)
- English + Chinese bilingual
- Short posts (500–900 words)
- 2–4 posts per week
- Automated publishing
- AI-friendly HTML output
- Self-hosted deployment
- Minimal dependencies

---

# Canonical Language Rule

English is the source of truth

Workflow:

1. Write English post
2. Translate to Chinese using AI
3. Manually polish Chinese
4. Publish both

Never write Chinese-only posts first.

---

# Directory Structure

/content/en        English posts (canonical)
/content/zh        Chinese translations

/templates         HTML templates
/scripts           build + publish scripts
/public            generated static files

---

# Post Format

Each post should follow this structure:

# Title

## The Problem
Describe what happened

## Why It Happened
Explain technical cause

## Fix
Explain solution

## Lesson
General takeaway

Posts should be:
- concise
- focused
- technical narrative
- one idea per post

---

# Frontmatter Format

All posts must include frontmatter:

---
title: Post Title
date: YYYY-MM-DD
lang: en
slug: post-slug
---

Chinese version:

---
title: 中文标题
date: YYYY-MM-DD
lang: zh
slug: post-slug
translated: true
---

Slug must match between EN and ZH.

Required for the post to appear on the live site:

- `published: true` — gates whether `build.js` includes the post. Without this flag, the post is a draft and is invisible to the build (and therefore to the deploy). Drafts can sit in `content/` indefinitely without leaking onto the live site.

Optional fields:

- `publishedAt: 2026-04-07T15:30:00-07:00` — full ISO 8601 timestamp. Used **only** for ordering; never rendered. When two posts share a `date`, `publishedAt` decides which comes first.
- `modified: YYYY-MM-DD` — added when a post is revised after its first live publish. Rendered as "Last updated YYYY-MM-DD" below the published date.

---

# Date Immutability

Once a post is deployed to live, its `date:` never changes — doing so would silently shift URLs, RSS order, and index position for readers who saw the old date.

If you revise a published post, add a `modified:` field instead. This keeps the original publish date stable and surfaces the revision honestly.

Only unpublished drafts may have their `date:` edited freely.

---

# Post Ordering

Posts sort by date/time descending:

1. Primary key: `publishedAt` if present, else `date` at midnight UTC
2. Tie-breaker: higher `episode` first

`publishedAt` is internal — it exists so two posts published on the same day still have a stable order — but the timestamp itself is never shown to readers.

---

# URL Structure

Output URLs:

/blog/en/{slug}
/blog/zh/{slug}

Example:

/blog/en/emoji-ios
/blog/zh/emoji-ios

---

# Language Linking

Each page must include language switch:

English page:

Chinese Version → /blog/zh/{slug}

Chinese page:

English Version → /blog/en/{slug}

---

# Publishing Rules

Posts are:

- short
- frequent
- independent
- not long essays
- not tutorials

Target:

2–4 posts per week

A post goes live only when:

1. Frontmatter has `published: true`, AND
2. The post is explicitly named in a deploy command (or pulled in by a full sync).

Date is **not** an automatic publish trigger. A post with `published: true` and a future date will still show in the build and deploy — the date is purely the rendered "publish day" shown to readers.

---

# Content Style

Use technical narrative style

Story → Problem → Fix → Lesson

Avoid:
- academic writing
- long introductions
- unnecessary theory
- overly verbose text

Prefer:
- concrete examples
- real bugs
- lessons learned
- engineering decisions

---

# Build Requirements

The blog generator should:

- Read markdown files
- Parse frontmatter
- Generate static HTML
- Build index page
- Sort by date
- Support bilingual
- Add language switch links
- Output to /public/blog

No database.
No CMS.
Keep implementation simple.

---

# Deployment

Output directory: `/public/blog` (gets rsync'd to `https://1pstartup.com/blog`).

Deploy via `scripts/publish.sh`. Two modes:

- **Scoped** (default — use this for new posts and updates):
  `bash scripts/publish.sh deploy <slug> [<slug>...]`
  Pushes only the named posts (EN+ZH) plus index pages and assets. Does **not** delete anything else on the server. This is the safe, surgical path.

- **Full sync** (use sparingly — only for site-wide changes like CSS or template tweaks):
  `bash scripts/publish.sh deploy`
  Runs `rsync --delete` — anything on the server but not in the local build is removed. Posts without `published: true` will be wiped.

Preflight check refuses to deploy from a dirty or unpushed working tree (override with `--allow-dirty`).

---

# Design Principles

Keep everything:

- simple
- readable
- static
- minimal
- AI-friendly

Avoid:

- frameworks unless necessary
- complex build systems
- heavy dependencies

---

# Priority Order

When implementing features:

1. Simplicity
2. Readability
3. Static output
4. Bilingual support
5. Automation

Do not add features unless necessary.

---

# Summary

This project builds:

- static blog
- bilingual
- automated publishing
- AI-generated content
- self-hosted

Keep everything minimal and maintainable.
