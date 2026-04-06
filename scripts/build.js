#!/usr/bin/env node

const fs   = require('fs');
const path = require('path');
const { marked }   = require('marked');
const matter = require('gray-matter');

const ROOT      = path.join(__dirname, '..');
const CONTENT   = path.join(ROOT, 'content');
const TEMPLATES = path.join(ROOT, 'templates');
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

function loadPosts(lang) {
  const dir = path.join(CONTENT, lang);
  if (!fs.existsSync(dir)) return [];

  return fs.readdirSync(dir)
    .filter(f => f.endsWith('.md'))
    .map(f => {
      const raw  = fs.readFileSync(path.join(dir, f), 'utf8');
      const { data, content } = matter(raw);
      return { ...data, body: content, file: f };
    })
    .filter(p => p.date && p.date <= TODAY)   // skip future posts
    .sort((a, b) => b.date.localeCompare(a.date));
}

// ── build one post ────────────────────────────────────────────────────────────

function buildPost(post, lang) {
  const otherLang = lang === 'en' ? 'zh' : 'en';
  const otherLabel = lang === 'en' ? '中文版' : 'English Version';
  const langSwitch = `<a href="/blog/${otherLang}/${post.slug}">${otherLabel} →</a>`;

  const html = render(readTemplate('post.html'), {
    lang,
    title:      post.title,
    date:       post.date,
    langSwitch,
    content:    marked.parse(post.body),
  });

  const outDir = path.join(PUBLIC, lang, post.slug);
  ensureDir(outDir);
  fs.writeFileSync(path.join(outDir, 'index.html'), html);
  console.log(`  built /blog/${lang}/${post.slug}`);
}

// ── build index for one language ─────────────────────────────────────────────

function buildIndex(posts, lang) {
  const items = posts.map(p => `
    <div class="post-item">
      <div class="post-date">${p.date}</div>
      <div class="post-title"><a href="/blog/${lang}/${p.slug}">${p.title}</a></div>
    </div>`).join('\n');

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

for (const lang of ['en', 'zh']) {
  const posts = loadPosts(lang);
  console.log(`\n[${lang}] ${posts.length} post(s)`);
  buildIndex(posts, lang);
  for (const post of posts) buildPost(post, lang);
}

console.log('\nDone.');
