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

### Connect blog to main site
- [ ] **Add Blog link to 1pstartup.com nav** — add `<li><a href="/blog">Blog</a></li>` to top nav and footer in `1pstartup/index.html` (lines ~442 and ~531)

### Complete Wave 1 posts (publishing order: B0 → B1 → B6 → B13)
Wave 1 goal: hook readers, prove it works, remove the cost objection early.

- [x] **B0** — "Why I Built FIRE51 — Alice Just Punched Through the Paper Wall of Coding" ✅ live
- [x] **B1** — "What Vibe Coding Actually Feels Like" ✅ live
- [ ] **B6** — "From Idea to Production in Days, Not Months"
  - Ref: `FIRE51/VIBECODING.md §B6`
  - Show the full timeline (4 weeks), what shipped, key enablers
  - Include FIRE51 report/chart screenshots
  - Hero image needed (EN + ZH)
- [ ] **B13** — "What Does Vibe Coding Actually Cost?"
  - Ref: `FIRE51/VIBECODING.md §B13`
  - Full cost table: domain, Lightsail, Claude Code, ChatGPT, Cursor, hardware
  - Under $55/month total — remove the accessibility objection
  - Hero image needed (EN + ZH)

### Polish
- [ ] **Screenshots for B0** — add FIRE51.com and 1pstartup.com website screenshots where the two projects are mentioned
- [ ] **Add Mermaid diagram support** — one `<script>` tag in post template; useful for B6 timeline and B2 architecture diagrams

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
