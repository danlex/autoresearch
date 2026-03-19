#!/usr/bin/env node

// ============================================================================
// generate-site.js — Generates a static GitHub Pages site from research files
// Run: node .github/generate-site.js
// Output: docs/ directory with HTML files
// ============================================================================

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const SECTIONS_DIR = path.join(ROOT, 'sections');
const DOCS_DIR = path.join(ROOT, 'docs');
const TEMPLATE_PATH = path.join(__dirname, 'page-template.html');

// Ensure docs/ exists
if (!fs.existsSync(DOCS_DIR)) fs.mkdirSync(DOCS_DIR, { recursive: true });

// ============================================================================
// Simple Markdown → HTML (no dependencies)
// ============================================================================

function md2html(md) {
  let html = md
    // Headings
    .replace(/^#### (.+)$/gm, '<h4>$1</h4>')
    .replace(/^### (.+)$/gm, '<h3>$1</h3>')
    .replace(/^## (.+)$/gm, '<h2>$1</h2>')
    .replace(/^# (.+)$/gm, '<h1>$1</h1>')
    // Bold + italic
    .replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>')
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    // Inline code
    .replace(/`(.+?)`/g, '<code>$1</code>')
    // Links
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank">$1</a>')
    // Citations [N] — style as superscript
    .replace(/\[(\d+)\]/g, '<sup class="cite">[$1]</sup>')
    // Blockquotes
    .replace(/^>\s*(.+)$/gm, '<blockquote>$1</blockquote>')
    // Horizontal rules
    .replace(/^---$/gm, '<hr>')
    // Lists
    .replace(/^- (.+)$/gm, '<li>$1</li>')
    // Confidence badges
    .replace(/Confidence: HIGH/g, '<span class="badge high">HIGH</span>')
    .replace(/Confidence: MEDIUM/g, '<span class="badge medium">MEDIUM</span>')
    .replace(/Confidence: LOW/g, '<span class="badge low">LOW</span>')
    .replace(/Depth: HIGH/g, '<span class="badge high">HIGH</span>')
    .replace(/Depth: MEDIUM/g, '<span class="badge medium">MEDIUM</span>')
    .replace(/Depth: LOW/g, '<span class="badge low">LOW</span>')
    // Uncertainty blocks
    .replace(/\*\*Uncertainty:\*\*/g, '<div class="uncertainty"><strong>⚠ Uncertainty:</strong></div><div class="uncertainty-body">')
    // Wrap consecutive <li> in <ul>
    .replace(/(<li>.*<\/li>\n?)+/g, '<ul>$&</ul>');

  // Paragraphs — wrap lines not already in tags
  html = html.split('\n').map(line => {
    if (line.trim() === '') return '';
    if (/^<[houldb]|^<hr|^<sup|^<blockquote/.test(line.trim())) return line;
    if (line.trim().startsWith('<li>')) return line;
    return `<p>${line}</p>`;
  }).join('\n');

  return html;
}

// ============================================================================
// Read research data
// ============================================================================

function readFile(filepath) {
  try { return fs.readFileSync(filepath, 'utf-8'); } catch { return ''; }
}

function readSection(name) {
  return readFile(path.join(SECTIONS_DIR, name));
}

// Parse score
function getScore() {
  try {
    const { execSync } = require('child_process');
    const output = execSync('bash autoresearch.sh 2>&1', { cwd: ROOT }).toString();
    const score = output.split('\n')[0].trim();
    const breakdown = output.split('\n')[1] || '';
    return { score, breakdown };
  } catch {
    return { score: '?', breakdown: '' };
  }
}

// Parse status.json
function getStatus() {
  try {
    return JSON.parse(readFile(path.join(ROOT, 'status.json')));
  } catch {
    return {};
  }
}

// Parse document.md header
function getHeader() {
  const doc = readFile(path.join(ROOT, 'document.md'));
  const match = doc.match(/Coverage: (\S+) \| Tasks: (\S+) \| Sources: (\S+) \| Last updated: (\S+)/);
  if (match) return { coverage: match[1], tasks: match[2], sources: match[3], updated: match[4] };
  return { coverage: '?', tasks: '?', sources: '?', updated: '?' };
}

// ============================================================================
// HTML Template
// ============================================================================

const TEMPLATE = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{title}} — Autoresearch</title>
  <style>
    :root {
      --bg: #0d0d0d;
      --surface: #161616;
      --border: #2a2a2a;
      --text: #e0e0e0;
      --dim: #555;
      --green: #4ade80;
      --amber: #fbbf24;
      --red: #f87171;
      --blue: #60a5fa;
      --cyan: #22d3ee;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: Georgia, 'Times New Roman', serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.7;
      max-width: 860px;
      margin: 0 auto;
      padding: 2rem;
    }
    nav {
      display: flex;
      gap: 1.5rem;
      padding: 1rem 0;
      border-bottom: 1px solid var(--border);
      margin-bottom: 2rem;
      flex-wrap: wrap;
    }
    nav a {
      color: var(--amber);
      text-decoration: none;
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.85rem;
    }
    nav a:hover { text-decoration: underline; }
    nav a.active { color: var(--text); font-weight: bold; }
    h1 { color: var(--amber); font-size: 2rem; margin: 1rem 0; }
    h2 { color: var(--amber); font-size: 1.4rem; margin: 2rem 0 0.5rem; border-bottom: 1px solid var(--border); padding-bottom: 0.3rem; }
    h3 { color: var(--blue); font-size: 1.1rem; margin: 1.5rem 0 0.5rem; }
    h4 { color: var(--dim); font-size: 1rem; margin: 1rem 0 0.3rem; }
    p { margin: 0.8rem 0; }
    a { color: var(--blue); }
    code { font-family: 'JetBrains Mono', monospace; background: var(--surface); padding: 0.1rem 0.4rem; border-radius: 3px; font-size: 0.9em; }
    blockquote { border-left: 3px solid var(--amber); padding: 0.5rem 1rem; margin: 1rem 0; color: var(--dim); background: var(--surface); }
    ul { padding-left: 1.5rem; margin: 0.5rem 0; }
    li { margin: 0.3rem 0; }
    hr { border: none; border-top: 1px solid var(--border); margin: 2rem 0; }
    sup.cite { color: var(--cyan); font-size: 0.75em; cursor: help; }
    .badge { font-family: 'JetBrains Mono', monospace; font-size: 0.75rem; padding: 0.1rem 0.4rem; border-radius: 3px; }
    .badge.high { background: #064e3b; color: var(--green); }
    .badge.medium { background: #451a03; color: var(--amber); }
    .badge.low { background: #450a0a; color: var(--red); }
    .uncertainty { color: var(--amber); margin-top: 1rem; }
    .uncertainty-body { background: var(--surface); padding: 0.8rem; border-radius: 4px; margin: 0.3rem 0 1rem; border-left: 3px solid var(--amber); }
    .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 1rem; margin: 1.5rem 0; }
    .stat { background: var(--surface); padding: 1rem; border-radius: 8px; border: 1px solid var(--border); text-align: center; }
    .stat-value { font-size: 2rem; font-weight: bold; font-family: 'JetBrains Mono', monospace; }
    .stat-label { color: var(--dim); font-size: 0.8rem; margin-top: 0.3rem; }
    .score-bar { background: var(--surface); border-radius: 4px; overflow: hidden; height: 8px; margin: 0.5rem 0; }
    .score-fill { height: 100%; background: var(--green); transition: width 0.3s; }
    footer { margin-top: 3rem; padding-top: 1rem; border-top: 1px solid var(--border); color: var(--dim); font-size: 0.8rem; text-align: center; }
    footer a { color: var(--dim); }
    @media (max-width: 600px) { body { padding: 1rem; } .stats { grid-template-columns: 1fr 1fr; } }
  </style>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
</head>
<body>
  <nav>
    <a href="index.html" class="{{nav_index}}">Research</a>
    <a href="progress.html" class="{{nav_progress}}">Progress</a>
    <a href="sections.html" class="{{nav_sections}}">Sections</a>
    <a href="sources.html" class="{{nav_sources}}">Sources</a>
    <a href="about.html" class="{{nav_about}}">About</a>
  </nav>
  {{content}}
  <footer>
    Generated by <a href="https://github.com/danlex/autoresearch">Autoresearch</a> — Autonomous research powered by Claude Opus
  </footer>
</body>
</html>`;

function writePage(filename, title, content, activeNav) {
  let html = TEMPLATE
    .replace('{{title}}', title)
    .replace('{{content}}', content)
    .replace('{{nav_index}}', activeNav === 'index' ? 'active' : '')
    .replace('{{nav_progress}}', activeNav === 'progress' ? 'active' : '')
    .replace('{{nav_sections}}', activeNav === 'sections' ? 'active' : '')
    .replace('{{nav_sources}}', activeNav === 'sources' ? 'active' : '')
    .replace('{{nav_about}}', activeNav === 'about' ? 'active' : '');

  fs.writeFileSync(path.join(DOCS_DIR, filename), html);
  console.log(`  Generated: docs/${filename}`);
}

// ============================================================================
// Generate Pages
// ============================================================================

console.log('Generating GitHub Pages site...\n');

const header = getHeader();
const { score, breakdown } = getScore();

// --- 1. index.html — Research document (all sections combined) ---
{
  const sections = [
    'intellectual-contributions.md',
    'education-and-teaching.md',
    'views-on-ai-future.md',
    'eureka-labs.md',
    'key-relationships.md',
  ];

  let body = `
    <h1>Andrej Karpathy — Research Document</h1>
    <div class="stats">
      <div class="stat"><div class="stat-value" style="color: var(--green)">${score}%</div><div class="stat-label">Research Score</div></div>
      <div class="stat"><div class="stat-value">${header.tasks}</div><div class="stat-label">Tasks</div></div>
      <div class="stat"><div class="stat-value">${header.sources}</div><div class="stat-label">Sources</div></div>
      <div class="stat"><div class="stat-value">${header.updated}</div><div class="stat-label">Last Updated</div></div>
    </div>
    <div class="score-bar"><div class="score-fill" style="width: ${score}%"></div></div>
  `;

  for (const s of sections) {
    const content = readSection(s);
    if (content.trim()) {
      body += md2html(content);
    }
  }

  writePage('index.html', 'Research Document', body, 'index');
}

// --- 2. progress.html — Score, pipeline, changelog ---
{
  const changelog = readFile(path.join(ROOT, 'changelog.md'));
  const status = getStatus();

  let body = `
    <h1>Research Progress</h1>
    <div class="stats">
      <div class="stat"><div class="stat-value" style="color: var(--green)">${score}%</div><div class="stat-label">Score</div></div>
      <div class="stat"><div class="stat-value">${header.tasks}</div><div class="stat-label">Tasks Done</div></div>
      <div class="stat"><div class="stat-value">${header.sources}</div><div class="stat-label">Sources</div></div>
      <div class="stat"><div class="stat-value">${status.iteration || '?'}</div><div class="stat-label">Iterations</div></div>
    </div>
    <div class="score-bar"><div class="score-fill" style="width: ${score}%"></div></div>
    <p style="color: var(--dim); font-family: 'JetBrains Mono', monospace; font-size: 0.8rem;">${breakdown}</p>
    <h2>Changelog</h2>
    ${md2html(changelog)}
  `;

  writePage('progress.html', 'Progress', body, 'progress');
}

// --- 3. sections.html — Section index with previews ---
{
  const sectionFiles = [
    { file: 'intellectual-contributions.md', name: 'Intellectual Contributions' },
    { file: 'education-and-teaching.md', name: 'Education and Teaching' },
    { file: 'views-on-ai-future.md', name: 'Views on AI Future' },
    { file: 'eureka-labs.md', name: 'Eureka Labs' },
    { file: 'key-relationships.md', name: 'Key Relationships and Collaborations' },
  ];

  let body = '<h1>Research Sections</h1>';

  for (const s of sectionFiles) {
    const content = readSection(s.file);
    const lines = content.split('\n').filter(l => l.trim()).length;
    const subsections = (content.match(/^### .+$/gm) || []).length;
    // Get first substantive paragraph as preview
    const paragraphs = content.split('\n').filter(l => l.trim() && !l.startsWith('#') && !l.startsWith('**Confidence') && l.length > 50);
    const preview = paragraphs[0] ? paragraphs[0].substring(0, 200) + '...' : 'No content yet.';

    body += `
      <div style="background: var(--surface); padding: 1.2rem; border-radius: 8px; border: 1px solid var(--border); margin: 1rem 0;">
        <h3 style="margin: 0 0 0.5rem;">${s.name}</h3>
        <p style="color: var(--dim); font-size: 0.85rem;">${lines} lines · ${subsections} subsections</p>
        <p style="font-size: 0.9rem;">${preview}</p>
      </div>
    `;
  }

  writePage('sections.html', 'Sections', body, 'sections');
}

// --- 4. sources.html — All sources ---
{
  const sources = readSection('sources.md');
  let body = `<h1>Sources</h1>${md2html(sources)}`;
  writePage('sources.html', 'Sources', body, 'sources');
}

// --- 5. about.html — README content ---
{
  const readme = readFile(path.join(ROOT, 'README.md'));
  let body = md2html(readme);
  writePage('about.html', 'About', body, 'about');
}

console.log('\nDone! Site generated in docs/');
console.log('Enable GitHub Pages: Settings → Pages → Source: Deploy from branch → /docs');
