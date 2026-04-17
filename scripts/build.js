#!/usr/bin/env node

const fs   = require('fs');
const path = require('path');
const { marked }   = require('marked');
const matter = require('gray-matter');

const ROOT      = path.join(__dirname, '..');
const CONTENT   = path.join(ROOT, 'content');
const TEMPLATES = path.join(ROOT, 'templates');
const ASSETS    = path.join(ROOT, 'assets');
const PUBLIC    = path.join(ROOT, 'public', 'blog');
const TODAY     = new Date().toISOString().slice(0, 10);

// ── helpers ──────────────────────────────────────────────────────────────────

function readTemplate(name) {
  return fs.readFileSync(path.join(TEMPLATES, name), 'utf8');
}

function render(template, vars) {
  return template.replace(/\{\{(\w+)\}\}/g, (_, key) => vars[key] ?? '');
}

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function copyAssets() {
  const dest = path.join(PUBLIC, 'assets');
  ensureDir(dest);
  for (const f of fs.readdirSync(ASSETS)) {
    fs.copyFileSync(path.join(ASSETS, f), path.join(dest, f));
  }
  console.log('  copied assets/');
}

function loadPosts(lang) {
  const dir = path.join(CONTENT, lang);
  if (!fs.existsSync(dir)) return [];

  return fs.readdirSync(dir)
    .filter(f => f.endsWith('.md'))
    .map(f => {
      const raw  = fs.readFileSync(path.join(dir, f), 'utf8');
      const { data, content } = matter(raw);
      const dateStr = data.date instanceof Date
    ? data.date.toISOString().slice(0, 10)
    : String(data.date).slice(0, 10);
  const modifiedStr = data.modified instanceof Date
    ? data.modified.toISOString().slice(0, 10)
    : data.modified ? String(data.modified).slice(0, 10) : null;
  const publishedAtRaw = data.publishedAt instanceof Date
    ? data.publishedAt.toISOString()
    : data.publishedAt ? String(data.publishedAt) : null;
  return { ...data, date: dateStr, modified: modifiedStr, publishedAt: publishedAtRaw, body: content, file: f };
    })
    .filter(p => p.date && p.date <= TODAY)   // skip future posts (date already normalized to YYYY-MM-DD)
    .sort((a, b) => {
      // Primary sort: publishedAt timestamp if present, else date at midnight UTC
      const ta = new Date(a.publishedAt || a.date + 'T00:00:00Z').getTime();
      const tb = new Date(b.publishedAt || b.date + 'T00:00:00Z').getTime();
      if (tb !== ta) return tb - ta;
      // Tie-breaker: higher episode number first
      return (b.episode || 0) - (a.episode || 0);
    });
}

// ── build one post ────────────────────────────────────────────────────────────

const SERIES_BANNERS = {
  vibecoding: {
    en: `<div class="series-banner">
      <img src="/blog/assets/fire51-logo.png" alt="FIRE51 logo">
      <div>
        <div class="series-label">Series</div>
        <div class="series-title">Vibe Coding — The Real Test of Product Thinking and Architecture</div>
        <div class="series-desc">Lessons from building <a href="https://fire51.com" target="_blank" rel="noopener">FIRE51.com</a> — a production retirement planning app built entirely with AI-assisted coding.</div>
      </div>
    </div>`,
    zh: `<div class="series-banner">
      <img src="/blog/assets/fire51-logo.png" alt="FIRE51 logo">
      <div>
        <div class="series-label">系列</div>
        <div class="series-title">Vibe Coding — 产品思维与架构能力的试金石</div>
        <div class="series-desc">来自构建 <a href="https://fire51.com" target="_blank" rel="noopener">FIRE51.com</a> 的真实经验——一款完全用 AI 辅助编程打造的退休规划 App。</div>
      </div>
    </div>`,
  },
};

function buildPost(post, lang) {
  const otherLang = lang === 'en' ? 'zh' : 'en';
  const otherLabel = lang === 'en' ? '中文版' : 'English Version';
  const langSwitch = `<a href="/blog/${otherLang}/${post.slug}">${otherLabel} →</a>`;

  const seriesBanner = post.series && SERIES_BANNERS[post.series]
    ? SERIES_BANNERS[post.series][lang] || ''
    : '';

  const authorTag = post.author
    ? `<span class="author">— ${post.author}</span>`
    : '';

  const modifiedLabel = lang === 'zh' ? '最后更新' : 'Last updated';
  const modifiedTag = post.modified
    ? `<span class="modified">${modifiedLabel} ${post.modified}</span>`
    : '';

  const html = render(readTemplate('post.html'), {
    lang,
    title:      post.title,
    date:       post.date,
    langSwitch,
    seriesBanner,
    authorTag,
    modifiedTag,
    content:    marked.parse(post.body),
  });

  const outDir = path.join(PUBLIC, lang, post.slug);
  ensureDir(outDir);
  fs.writeFileSync(path.join(outDir, 'index.html'), html);
  console.log(`  built /blog/${lang}/${post.slug}`);
}

// ── build index for one language ─────────────────────────────────────────────

const SERIES_META = {
  vibecoding: {
    en: 'Vibe Coding — The Real Test of Product Thinking and Architecture',
    zh: 'Vibe Coding — 产品思维与架构能力的试金石',
  },
};

const ZH_NUMS = ['零','一','二','三','四','五','六','七','八','九','十','十一','十二','十三'];

function episodeLabel(episode, lang) {
  const n = episode + 1; // 0-indexed → 1-indexed display
  return lang === 'zh' ? (ZH_NUMS[n] || String(n)) : String(n);
}

function buildIndex(posts, lang) {
  const items = posts.map(p => {
    const seriesName = p.series && SERIES_META[p.series] ? SERIES_META[p.series][lang] : null;
    const episodeTag = p.series && p.episode != null
      ? `<span class="post-episode">${episodeLabel(p.episode, lang)}</span>`
      : '';
    const seriesTag = seriesName
      ? `<div class="post-series">${seriesName}</div>`
      : '';
    return `
    <div class="post-item">
      <div class="post-date">${p.date}</div>
      ${seriesTag}
      <div class="post-title">${episodeTag}<a href="/blog/${lang}/${p.slug}">${p.title}</a></div>
    </div>`;
  }).join('\n');

  const html = render(readTemplate('index.html'), {
    lang,
    enActive: lang === 'en' ? 'active' : '',
    zhActive: lang === 'zh' ? 'active' : '',
    posts:    items || '<p style="color:#5a7368">No posts yet.</p>',
  });

  const outDir = path.join(PUBLIC, lang);
  ensureDir(outDir);
  fs.writeFileSync(path.join(outDir, 'index.html'), html);
  console.log(`  built /blog/${lang}/`);
}

// ── build root /blog redirect ─────────────────────────────────────────────────

function buildRoot() {
  const html = `<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<meta http-equiv="refresh" content="0;url=/blog/en">
<title>Blog — 1pstartup</title></head>
<body><a href="/blog/en">Redirecting…</a></body></html>`;
  ensureDir(PUBLIC);
  fs.writeFileSync(path.join(PUBLIC, 'index.html'), html);
  console.log('  built /blog/ (redirect → /blog/en)');
}

// ── main ──────────────────────────────────────────────────────────────────────

console.log(`Building blog (today = ${TODAY})…`);

buildRoot();
copyAssets();

for (const lang of ['en', 'zh']) {
  const posts = loadPosts(lang);
  console.log(`\n[${lang}] ${posts.length} post(s)`);
  buildIndex(posts, lang);
  for (const post of posts) buildPost(post, lang);
}

console.log('\nDone.');
