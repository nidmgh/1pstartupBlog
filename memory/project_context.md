---
name: Project Context — Three Repos
description: Locations and roles of the three related projects: 1pstartup, FIRE51, and 1pstartupBlog
type: project
---

Three related projects under /Users/demai/work/:

## 1pstartup (`/Users/demai/work/1pstartup`)
- Live website at https://1pstartup.com
- Static HTML site (index.html, finance.html, history.html, etc.)
- Nginx config at `/Users/demai/work/1pstartup/nginx/1pstartup.conf`
- Served from `/var/www/1pstartup` on the server
- The blog will be deployed under this domain at https://1pstartup.com/blog

## FIRE51 (`/Users/demai/work/FIRE51`)
- Live website at https://FIRE51.com
- Full-stack app: TypeScript, Capacitor (iOS/Android), tax engine, JWT auth, PDF generation
- Contains `VIBECODING.md` — skeleton and raw material for 13 blog posts (B1–B13)
- VIBECODING.md is reference only — posts are NOT extracted from it directly

## 1pstartupBlog (`/Users/demai/work/1pstartupBlog`) — THIS PROJECT
- Builds the static blog deployed to https://1pstartup.com/blog
- Blog is at github.com/nidmgh/1pstartupBlog
- Bilingual: English + Chinese, both written fresh (not translated from each other)
- Output to /public/blog, deployed to /var/www/1pstartup-blog/ on server

**Why:** Posts are written fresh — narrative flow, accessible examples, general audience voice. VIBECODING.md provides ideas and structure only.
**How to apply:** When writing a post, read the relevant B-section in FIRE51/VIBECODING.md for ideas, then write a new post from scratch. Both EN and ZH versions live in content/en/ and content/zh/.
