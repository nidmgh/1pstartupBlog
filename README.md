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

`/Users/demai/work/FIRE51/VIBECODING.md` — skeleton and raw material for 13 blog posts (B1–B13).

**Not extracted directly.** Each post is written fresh, drawing ideas and structure from VIBECODING.md but with proper narrative flow, accessible examples, images, and a voice tuned for a general audience.

---

## Workflow

1. Read the relevant section in `FIRE51/VIBECODING.md` for ideas and structure
2. Write a fresh English post in `content/en/` — narrative style, general audience
3. Write Chinese version in `content/zh/` — not a direct translation, tuned for Chinese readers
4. Set `date` in frontmatter to schedule publish
5. Build static HTML → `public/blog/`
6. Deploy to server under `/var/www/1pstartup-blog/`

---

## Implementation Plan

- [x] Build static site generator — `scripts/build.js`, templates, bilingual support
- [x] B0 and B1 posts written (EN + ZH) with hero images, mobile screenshots, series banner
- [x] Nginx `/blog` location wired up (`1pstartup/nginx/1pstartup.conf`)
- [x] Deploy script — `scripts/publish.sh` with dry-run, setup, and deploy modes
- [x] Live at https://1pstartup.com/blog

---

## Next Steps

- [ ] **Add Blog link to 1pstartup.com nav** — add `<li><a href="/blog">Blog</a></li>` to top nav and footer in `1pstartup/index.html` (lines ~442 and ~531)
- [ ] **Write B2** — "Start with the Architecture Doc, Not the Code" (ref: FIRE51/VIBECODING.md §B2)
- [ ] **Write B6** — "From Idea to Production in Days" — Wave 1 post #3 per publishing order
- [ ] **Write B13** — "What Does Vibe Coding Actually Cost?" — Wave 1 post #4
- [ ] **Add Mermaid diagram support** — add one `<script>` tag to post template for flow diagrams
- [ ] **Screenshots for B0** — add FIRE51.com and 1pstartup.com screenshots where the projects are mentioned

---

## Commands

```bash
npm run build              # build locally
bash scripts/publish.sh dryrun    # preview what would change on server
bash scripts/publish.sh deploy    # build + deploy to production
```

Local preview:
```bash
npx serve public -p 4000
# then open http://localhost:4000/blog/en/
```

---

## Key Docs

- `1pstartup_blog_design.md` — architecture and design decisions
- `CLAUDE.md` — AI coding instructions for this project
