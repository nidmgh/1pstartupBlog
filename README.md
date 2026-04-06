# 1pstartupBlog

Static markdown blog deployed to https://1pstartup.com/blog

---

## Related Projects

| Project | Path | Domain | Role |
|---|---|---|---|
| `1pstartup` | `/Users/demai/work/1pstartup` | https://1pstartup.com | Existing static site; blog deploys here under `/blog` |
| `FIRE51` | `/Users/demai/work/FIRE51` | https://FIRE51.com | Source app; `VIBECODING.md` contains the blog series content |
| `1pstartupBlog` | `/Users/demai/work/1pstartupBlog` | https://1pstartup.com/blog | This project; builds the static blog |

---

## Content Source

`/Users/demai/work/FIRE51/VIBECODING.md` — outlines for 13 blog posts (B1–B13) about building FIRE51 via vibe coding. Each section maps to one published post.

---

## Workflow

1. Extract post content from `FIRE51/VIBECODING.md`
2. Write English markdown post in `/content/en/`
3. Translate to Chinese, save in `/content/zh/`
4. Build static HTML → `/public/blog`
5. Deploy to server under `/var/www/1pstartup/blog`

---

## Implementation Plan

1. **Build static site generator** — `scripts/build.js`, `templates/post.html`, `templates/index.html`
2. **Create first post** — extract B1 from `FIRE51/VIBECODING.md` into `/content/en/`, translate to `/content/zh/`, verify build output
3. **Wire up nginx** — add `/blog` location to `1pstartup/nginx/1pstartup.conf`
4. **Publish script** — `scripts/publish.sh` builds and deploys to server, skips future-dated posts

---

## Key Docs

- `1pstartup_blog_design.md` — architecture and design decisions
- `CLAUDE.md` — AI coding instructions for this project
