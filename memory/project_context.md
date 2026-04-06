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
- Contains `VIBECODING.md` — the raw content source for the blog series
- `VIBECODING.md` outlines 13 blog posts (B1–B13) about lessons from building FIRE51

## 1pstartupBlog (`/Users/demai/work/1pstartupBlog`) — THIS PROJECT
- Builds the static blog deployed to https://1pstartup.com/blog
- Content source: FIRE51/VIBECODING.md → individual markdown posts
- Bilingual: English (canonical) + Chinese translation
- Output to /public/blog, deployed externally

**Why:** The blog publishes the VIBECODING series as individual posts drawn from FIRE51/VIBECODING.md.
**How to apply:** When generating blog posts, read FIRE51/VIBECODING.md as the content source. When checking deployment config, reference 1pstartup nginx config.
