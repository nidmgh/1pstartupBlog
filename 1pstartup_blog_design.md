# 1PStartup Blog — Design Document

## Goals

- Publish short, frequent posts (2–4/week)
- Use AI-generated content workflow
- Support English + Chinese bilingual
- Optimize for SEO + AI indexing
- Minimal maintenance
- Self-hosted on Lightsail
- Later integrate with YouTube / Bilibili / Xiaohongshu

---

## High-Level Architecture

```
1pstartup.com
    /ideas        (existing)
    /blog         (new)
        /en
        /zh
```

Blog acts as:
- knowledge base
- SEO surface
- video companion
- AI-indexable content
- long-term archive

Videos are the **primary audience driver**  
Blog provides **reference + deep explanation**

---

## Hosting Decision

Self-hosted (NOT Medium / Substack)

Reasons:
- own content + SEO
- AI-friendly clean HTML
- multilingual support
- long-term brand building
- integrates with videos
- no platform dependency

Blog location:

```
https://1pstartup.com/blog
```

---

## Content Format

Posts are:
- short
- focused
- technical narrative
- 500–900 words
- one idea per post

Template:

```
# Title

## The Problem
...

## Why It Happened
...

## Fix
...

## Lesson
...
```

---

## Publishing Strategy

Frequency:
- 2–4 posts per week
- automated publishing
- scheduled via markdown frontmatter

Example:

```
---
title: Emoji Killed My iOS App
date: 2026-04-10
lang: en
---
```

Posts auto-published when date reached.

---

## Content Source Workflow

English is canonical source.

Workflow:

1. Claude generates English post
2. AI translates to Chinese
3. Manual Chinese polish
4. Publish both versions

---

## Bilingual Strategy

Directory structure:

```
/blog/en/
/blog/zh/
```

Example:

```
/blog/en/emoji-ios
/blog/zh/emoji-ios
```

Each page links to other language.

---

## Technology Decision

Use static markdown blog.

Reasons:
- simple
- fast
- AI-friendly
- git versioned
- no database
- no maintenance
- easy bilingual

---

## File Structure

```
/blog
    index.html

/blog/posts
    2026-04-01-vibe-coding.md
    2026-04-02-emoji-ios.md

/blog/en
/blog/zh
```

---

## Content Categories (future)

```
/blog/vibe-coding
/blog/history
/blog/humanities
/blog/startup
/blog/ai
```

---

## Video Integration

Videos published on:

- YouTube
- Bilibili
- Xiaohongshu

Flow:

Video → link to blog post → deep explanation

Blog becomes:
- reference material
- transcript
- extended explanation
- SEO landing page

---

## Content Style

Technical narrative style:

Story + Problem + Fix + Lesson

Not:
- tutorial
- documentation
- academic essay

---

## Automation Pipeline

```
Write markdown
    ↓
Commit to repo
    ↓
Auto build blog
    ↓
Auto deploy Lightsail
    ↓
Scheduled publish
```

---

## Initial Post Plan

1. What vibe coding actually feels like
2. Start with architecture doc
3. Emoji killed my iOS app
4. PDF generation hell
5. Keeping AI honest
6. Git hooks silent co-pilot
7. CLAUDE.md must stay short
8. What vibe coding costs

---

## Final Decisions

Hosting: self-hosted  
Domain: 1pstartup.com/blog  
Platform: static markdown  
Language: English first  
Translation: AI → manual polish  
Posts: short + frequent  
Schedule: automated  
Structure: bilingual folders  
Videos: primary audience  
Blog: reference + SEO
