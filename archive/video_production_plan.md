# Video Production Plan — 1pstartup Vibe Coding Series

Companion workflow to the blog at https://1pstartup.com/blog. Goal: turn each blog post into a short video for YouTube Shorts and 小红书.

---

## Tooling Decision (2026-04-20)

Three modules, cost-controlled stack:

| Module | Tool | Cost | Notes |
|---|---|---|---|
| ① 文案脚本 | **Claude** (this project) | $0 marginal | Rewrite existing EN/ZH blog posts into spoken scripts. Claude already has full context of the series via `CLAUDE.md` + `VIBECODING.md`. |
| ② 语音合成 | **Fish Audio** | ~$5–10/mo | Clone 迈哥's voice from a short sample. Chinese prosody is more natural than ElevenLabs for 小红书 tone. Upgrade path → **HeyGen** ($24/mo) later if we want a lip-synced digital avatar. |
| ③ 视频剪辑 | **剪映 / CapCut** | $0 | Free. AI captions, BGM library, vertical export, image + clip composition. PPT-style explainer is well within its capability. |

**Starting monthly cost: ~$5–10.** Switching module ② to HeyGen later brings total to ~$24/mo, added only after first 2–3 videos validate completion rate.

---

## Why this stack

- **Claude over ad-hoc prompts**: the blog posts already exist as the canonical source. Script generation is a translation task (written narrative → spoken hook-driven script), not fresh writing. Reusing the same project avoids re-establishing voice/tone each time.
- **Fish Audio over ElevenLabs**: for 小红书, Chinese-native TTS wins on rhythm and colloquial pronunciation. ElevenLabs is stronger for English-first content; we can revisit if we push harder on YouTube Shorts in English.
- **剪映 over Descript**: script-driven editing (Descript) is powerful but overkill for PPT-style explainers with photo/clip inserts. 剪映 has the Chinese template ecosystem and free tier covers everything we need.
- **Defer lip-sync avatar**: adds $24/mo and production friction (need clean front-facing video sample). Not worth it before we know which videos land.

---

## Workflow

```
blog post (EN or ZH)
   │
   ▼ Module ① — Claude
口语化脚本 (.md in /video-scripts/)
   │
   ▼ Module ② — Fish Audio
voiceover (.mp3 or .wav)
   │
   ▼ Module ③ — 剪映
final video (.mp4, 竖屏 9:16)
   │
   ▼
YouTube Shorts / 小红书
```

---

## Directory Layout

```
/video-scripts/
  B0-intro.zh.md       ← spoken script, Chinese
  B0-intro.en.md       ← spoken script, English (optional)
  B1-...
/video-assets/          ← photos, screen recordings, B-roll
/video-output/          ← final exports (gitignored)
```

Scripts are tracked in git alongside blog posts. Raw media and exports are not.

---

## Script Format

Each script file contains:

```markdown
---
source: B0-vibe-coding-series-intro
platform: xiaohongshu | youtube-shorts
duration: ~60s | ~90s
lang: zh | en
---

# Hook (0–3s)
One line that earns the next 5 seconds.

# Body (3–50s)
Spoken-style narrative, short sentences, one idea per beat.
Mark [visual: ...] where a photo/clip/screenshot should appear.

# CTA (50–60s)
关注 / 点赞 / 看下一集 — specific to the post.
```

---

## Target Output

- 10+ scripts from the 8 existing posts (some posts split into 2 angles).
- Start with ZH for 小红书; add EN for YT Shorts where the topic travels.
- 2–4 videos/week once the pipeline is warm (mirrors blog cadence).
