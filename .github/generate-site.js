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
  <link rel="icon" type="image/svg+xml" href="favicon.svg">
  <title>{{title}} — Autoresearch by Alexandru DAN</title>
  <meta name="description" content="{{meta_description}}">
  <meta name="author" content="Alexandru DAN, CEO TVL Tech">
  <meta property="og:title" content="{{title}} — Autoresearch">
  <meta property="og:description" content="{{meta_description}}">
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://danlex.github.io/autoresearch/">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="{{title}} — Autoresearch">
  <meta name="twitter:description" content="{{meta_description}}">
  <style>
    :root {
      --bg: #09090b;
      --surface: rgba(255,255,255,0.03);
      --surface-hover: rgba(255,255,255,0.06);
      --border: rgba(255,255,255,0.08);
      --text: #fafafa;
      --text-secondary: #a1a1aa;
      --dim: #52525b;
      --green: #22c55e;
      --amber: #f59e0b;
      --red: #ef4444;
      --blue: #3b82f6;
      --cyan: #06b6d4;
      --purple: #a855f7;
      --gradient-1: linear-gradient(135deg, #f59e0b 0%, #ef4444 100%);
      --gradient-2: linear-gradient(135deg, #3b82f6 0%, #a855f7 100%);
      --gradient-3: linear-gradient(135deg, #22c55e 0%, #06b6d4 100%);
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    html { scroll-behavior: smooth; }
    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.75;
      max-width: 920px;
      margin: 0 auto;
      padding: 2rem;
      -webkit-font-smoothing: antialiased;
    }

    /* Navigation */
    nav {
      display: flex;
      align-items: center;
      gap: 0.25rem;
      padding: 0.5rem;
      margin-bottom: 3rem;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 12px;
      backdrop-filter: blur(12px);
      position: sticky;
      top: 1rem;
      z-index: 100;
    }
    nav a {
      color: var(--text-secondary);
      text-decoration: none;
      font-family: 'Inter', sans-serif;
      font-size: 0.85rem;
      font-weight: 500;
      padding: 0.5rem 1rem;
      border-radius: 8px;
      transition: all 0.2s ease;
    }
    nav a:hover { color: var(--text); background: var(--surface-hover); }
    nav a.active { color: var(--text); background: rgba(255,255,255,0.1); font-weight: 600; }

    /* Typography */
    h1 {
      font-size: 2.5rem;
      font-weight: 800;
      letter-spacing: -0.03em;
      line-height: 1.2;
      margin: 1.5rem 0;
      background: var(--gradient-1);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }
    h2 {
      font-size: 1.5rem;
      font-weight: 700;
      letter-spacing: -0.02em;
      color: var(--text);
      margin: 3rem 0 1rem;
      padding-bottom: 0.5rem;
      border-bottom: 1px solid var(--border);
    }
    h3 {
      font-size: 1.15rem;
      font-weight: 600;
      color: var(--text-secondary);
      margin: 2rem 0 0.75rem;
    }
    h4 { color: var(--dim); font-size: 1rem; margin: 1.5rem 0 0.5rem; font-weight: 600; }
    p { margin: 1rem 0; color: #d4d4d8; font-size: 0.95rem; }
    a { color: var(--blue); text-decoration: none; transition: color 0.15s; }
    a:hover { color: var(--cyan); text-decoration: underline; }
    strong { color: var(--text); font-weight: 600; }

    /* Code */
    code {
      font-family: 'JetBrains Mono', 'Fira Code', monospace;
      background: rgba(255,255,255,0.06);
      padding: 0.15rem 0.5rem;
      border-radius: 6px;
      font-size: 0.85em;
      border: 1px solid var(--border);
    }

    /* Blockquotes */
    blockquote {
      border-left: 3px solid var(--amber);
      padding: 1rem 1.25rem;
      margin: 1.5rem 0;
      background: var(--surface);
      border-radius: 0 8px 8px 0;
      color: var(--text-secondary);
      font-style: italic;
    }

    /* Lists */
    ul { padding-left: 1.5rem; margin: 0.75rem 0; }
    li { margin: 0.4rem 0; color: #d4d4d8; }
    li::marker { color: var(--dim); }

    hr { border: none; border-top: 1px solid var(--border); margin: 3rem 0; }

    /* Citations */
    sup.cite {
      color: var(--cyan);
      font-size: 0.7em;
      cursor: help;
      font-family: 'JetBrains Mono', monospace;
      font-weight: 600;
      transition: color 0.15s;
    }
    sup.cite:hover { color: var(--amber); }

    /* Badges */
    .badge {
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.7rem;
      font-weight: 600;
      padding: 0.2rem 0.6rem;
      border-radius: 9999px;
      letter-spacing: 0.05em;
      text-transform: uppercase;
    }
    .badge.high { background: rgba(34,197,94,0.15); color: var(--green); border: 1px solid rgba(34,197,94,0.2); }
    .badge.medium { background: rgba(245,158,11,0.15); color: var(--amber); border: 1px solid rgba(245,158,11,0.2); }
    .badge.low { background: rgba(239,68,68,0.15); color: var(--red); border: 1px solid rgba(239,68,68,0.2); }

    /* Uncertainty blocks */
    .uncertainty { color: var(--amber); margin-top: 1.5rem; font-weight: 600; }
    .uncertainty-body {
      background: rgba(245,158,11,0.05);
      padding: 1rem 1.25rem;
      border-radius: 8px;
      margin: 0.5rem 0 1.5rem;
      border: 1px solid rgba(245,158,11,0.15);
      font-size: 0.9rem;
      color: var(--text-secondary);
    }

    /* Stats grid */
    .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 1rem; margin: 2rem 0; }
    .stat {
      background: var(--surface);
      padding: 1.25rem;
      border-radius: 12px;
      border: 1px solid var(--border);
      text-align: center;
      transition: border-color 0.2s, transform 0.2s;
    }
    .stat:hover { border-color: rgba(255,255,255,0.15); transform: translateY(-2px); }
    .stat-value {
      font-size: 2.25rem;
      font-weight: 800;
      font-family: 'JetBrains Mono', monospace;
      letter-spacing: -0.02em;
    }
    .stat-label { color: var(--dim); font-size: 0.75rem; margin-top: 0.4rem; text-transform: uppercase; letter-spacing: 0.1em; font-weight: 500; }

    /* Score bar */
    .score-bar {
      background: rgba(255,255,255,0.05);
      border-radius: 9999px;
      overflow: hidden;
      height: 6px;
      margin: 1rem 0;
    }
    .score-fill {
      height: 100%;
      background: var(--gradient-3);
      border-radius: 9999px;
      transition: width 1s ease;
    }

    /* Video grid */
    .video-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.2rem; margin: 1.5rem 0; }
    .video-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 12px;
      overflow: hidden;
      transition: border-color 0.2s, transform 0.2s;
    }
    .video-card:hover { border-color: rgba(255,255,255,0.15); transform: translateY(-2px); }
    .video-card iframe { width: 100%; aspect-ratio: 16/9; border: none; display: block; }
    .video-card .video-info { padding: 1rem; }
    .video-card .video-title { color: var(--text); font-weight: 600; font-size: 0.9rem; }
    .video-card .video-desc { color: var(--dim); font-size: 0.8rem; margin-top: 0.3rem; }

    /* Profile */
    .profile-row { display: flex; gap: 2rem; align-items: center; margin: 2rem 0; flex-wrap: wrap; }
    .profile-img {
      width: 130px;
      height: 130px;
      border-radius: 50%;
      border: 3px solid transparent;
      background-image: var(--gradient-1);
      background-origin: border-box;
      background-clip: content-box, border-box;
      object-fit: cover;
      box-shadow: 0 0 30px rgba(245,158,11,0.15);
    }
    .profile-text { flex: 1; min-width: 250px; }

    /* Section cards */
    .section-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.8rem; margin: 1.5rem 0 2.5rem; }
    .section-card {
      background: var(--surface);
      padding: 1.2rem;
      border-radius: 12px;
      border: 1px solid var(--border);
      text-decoration: none;
      color: var(--text);
      transition: all 0.2s ease;
      display: block;
    }
    .section-card:hover { border-color: var(--amber); transform: translateY(-2px); background: var(--surface-hover); text-decoration: none; }
    .section-card strong { color: var(--amber); font-size: 0.95rem; }
    .section-card p { color: var(--dim); font-size: 0.8rem; margin: 0.3rem 0 0; }

    /* Footer */
    footer {
      margin-top: 4rem;
      padding: 2rem 0;
      border-top: 1px solid var(--border);
      color: var(--dim);
      font-size: 0.8rem;
      text-align: center;
    }
    footer a { color: var(--text-secondary); }
    footer a:hover { color: var(--text); }
    footer p { color: var(--dim); margin: 0.3rem 0; }

    /* Table */
    table { width: 100%; border-collapse: collapse; margin: 1rem 0; }
    th { text-align: left; padding: 0.75rem; color: var(--amber); border-bottom: 1px solid var(--border); font-size: 0.85rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
    td { padding: 0.75rem; border-bottom: 1px solid var(--border); font-size: 0.9rem; color: #d4d4d8; }
    tr:hover td { background: var(--surface); }

    /* Section submenu — horizontal bar under main nav */
    .section-bar {
      display: flex;
      gap: 0.2rem;
      padding: 0.4rem;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 10px;
      margin-bottom: 2.5rem;
      overflow-x: auto;
      position: sticky;
      top: 4.5rem;
      z-index: 99;
      backdrop-filter: blur(12px);
      -webkit-overflow-scrolling: touch;
    }
    .section-bar::-webkit-scrollbar { height: 0; }
    .section-bar a {
      white-space: nowrap;
      color: var(--dim);
      text-decoration: none;
      font-size: 0.8rem;
      font-weight: 500;
      padding: 0.45rem 0.9rem;
      border-radius: 7px;
      transition: all 0.15s ease;
      flex-shrink: 0;
    }
    .section-bar a:hover { color: var(--text-secondary); background: var(--surface-hover); text-decoration: none; }
    .section-bar a.active { color: var(--amber); background: rgba(245,158,11,0.1); font-weight: 600; }
    /* Light theme overrides */
    [data-theme="light"] {
      --bg: #ffffff;
      --surface: rgba(0,0,0,0.03);
      --surface-hover: rgba(0,0,0,0.06);
      --border: rgba(0,0,0,0.1);
      --text: #1a1a1a;
      --text-secondary: #555555;
      --dim: #888888;
    }
    [data-theme="light"] p,
    [data-theme="light"] li,
    [data-theme="light"] td { color: #333333; }
    [data-theme="light"] h1 { -webkit-text-fill-color: unset; background: none; color: #1a1a1a; }
    [data-theme="light"] code { background: rgba(0,0,0,0.06); border-color: rgba(0,0,0,0.1); }
    [data-theme="light"] .score-bar { background: rgba(0,0,0,0.08); }
    [data-theme="light"] .section-card:hover { background: rgba(0,0,0,0.04); }

    /* Reading progress bar */
    .progress-bar {
      position: fixed;
      top: 0;
      left: 0;
      height: 3px;
      width: 0%;
      background: linear-gradient(90deg, var(--amber), var(--red), var(--purple));
      z-index: 9999;
      transition: width 0.1s linear;
      pointer-events: none;
    }

    /* Reading time pill */
    .reading-time {
      display: inline-block;
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.7rem;
      font-weight: 500;
      color: var(--dim);
      background: var(--surface);
      border: 1px solid var(--border);
      padding: 0.2rem 0.7rem;
      border-radius: 9999px;
      margin-left: 0.5rem;
      vertical-align: middle;
      letter-spacing: 0.02em;
    }

    /* Theme toggle button */
    .theme-toggle {
      background: var(--surface);
      border: 1px solid var(--border);
      color: var(--text-secondary);
      font-size: 0.85rem;
      padding: 0.4rem 0.6rem;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.2s ease;
      line-height: 1;
      margin-left: auto;
      flex-shrink: 0;
    }
    .theme-toggle:hover { color: var(--text); background: var(--surface-hover); }

    /* Interactive career timeline */
    .timeline {
      display: flex;
      align-items: center;
      padding: 0.75rem 1rem;
      margin: 0.5rem 0 2rem;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 12px;
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
      gap: 0;
    }
    .timeline::-webkit-scrollbar { height: 0; }
    .timeline-item {
      flex: 1;
      min-width: 0;
      position: relative;
    }
    .timeline-item a {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      text-decoration: none;
      color: var(--text);
      padding: 0.5rem 0.6rem;
      border-radius: 8px;
      transition: background 0.15s;
      white-space: nowrap;
    }
    .timeline-item a:hover { background: var(--surface-hover); text-decoration: none; }
    .tl-dot {
      width: 10px;
      height: 10px;
      border-radius: 50%;
      background: var(--amber);
      flex-shrink: 0;
      transition: transform 0.15s;
    }
    .timeline-item a:hover .tl-dot { transform: scale(1.4); }
    .tl-year {
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.7rem;
      font-weight: 700;
      color: var(--amber);
      flex-shrink: 0;
    }
    .tl-title {
      font-size: 0.78rem;
      color: var(--text-secondary);
      font-weight: 500;
    }
    /* Connector line between items */
    .tl-connector {
      width: 20px;
      height: 2px;
      background: var(--border);
      flex-shrink: 0;
    }
    @media (max-width: 640px) {
      .timeline-item a { padding: 0.4rem; }
      .tl-title { display: none; }
    }

    /* Citation popovers */
    .cite-popover {
      position: absolute;
      z-index: 1000;
      background: #1e1e2e;
      color: #e0e0e0;
      border: 1px solid rgba(255,255,255,0.12);
      border-radius: 8px;
      padding: 0.6rem 0.9rem;
      font-size: 0.8rem;
      line-height: 1.5;
      max-width: 320px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.5);
      pointer-events: none;
      opacity: 0;
      transform: translateY(4px);
      transition: opacity 0.15s ease, transform 0.15s ease;
    }
    .cite-popover.visible { opacity: 1; transform: translateY(0); pointer-events: auto; }
    .cite-popover::after {
      content: '';
      position: absolute;
      bottom: -5px;
      left: 50%;
      transform: translateX(-50%);
      border-left: 5px solid transparent;
      border-right: 5px solid transparent;
      border-top: 5px solid #1e1e2e;
    }
    [data-theme="light"] .cite-popover { background: #2a2a3a; color: #f0f0f0; }
    [data-theme="light"] .cite-popover::after { border-top-color: #2a2a3a; }

    /* TOC dropdown */
    .toc-dropdown {
      display: none;
      position: absolute;
      top: 100%;
      left: 0;
      right: 0;
      margin-top: 0.3rem;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 10px;
      backdrop-filter: blur(16px);
      padding: 0.4rem;
      z-index: 200;
      max-height: 280px;
      overflow-y: auto;
      box-shadow: 0 8px 24px rgba(0,0,0,0.3);
    }
    .toc-dropdown.open { display: block; }
    .toc-dropdown a {
      display: block;
      color: var(--text-secondary);
      text-decoration: none;
      font-size: 0.78rem;
      padding: 0.4rem 0.8rem;
      border-radius: 6px;
      transition: all 0.15s ease;
    }
    .toc-dropdown a:hover { color: var(--text); background: var(--surface-hover); text-decoration: none; }

    /* Client-side search */
    .search-box {
      position: relative;
      margin-left: 0.25rem;
      flex-shrink: 0;
    }
    .search-box input {
      font-family: 'Inter', sans-serif;
      font-size: 0.8rem;
      background: var(--surface);
      border: 1px solid var(--border);
      color: var(--text);
      padding: 0.4rem 0.7rem;
      border-radius: 8px;
      width: 140px;
      outline: none;
      transition: all 0.2s ease;
    }
    .search-box input::placeholder { color: var(--dim); }
    .search-box input:focus { border-color: var(--amber); width: 200px; }
    .search-results {
      display: none;
      position: absolute;
      top: calc(100% + 0.4rem);
      right: 0;
      width: 340px;
      max-height: 320px;
      overflow-y: auto;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 10px;
      backdrop-filter: blur(16px);
      box-shadow: 0 8px 24px rgba(0,0,0,0.4);
      z-index: 300;
      padding: 0.3rem;
    }
    .search-results.open { display: block; }
    .search-results .sr-item {
      display: block;
      padding: 0.5rem 0.7rem;
      font-size: 0.8rem;
      color: var(--text-secondary);
      border-radius: 6px;
      cursor: pointer;
      transition: background 0.15s;
      line-height: 1.4;
    }
    .search-results .sr-item:hover { background: var(--surface-hover); color: var(--text); }
    .search-results .sr-item mark {
      background: rgba(245,158,11,0.3);
      color: var(--amber);
      border-radius: 2px;
      padding: 0 2px;
    }
    .search-results .sr-empty {
      padding: 0.8rem;
      font-size: 0.8rem;
      color: var(--dim);
      text-align: center;
    }

    /* Key findings callout boxes */
    .callout {
      background: var(--surface);
      border: 1px solid var(--border);
      border-left: 4px solid var(--amber);
      border-radius: 0 10px 10px 0;
      padding: 1.2rem 1.5rem;
      margin: 1.5rem 0;
      font-size: 1rem;
      line-height: 1.7;
      color: var(--text-secondary);
    }
    .callout strong { color: var(--amber); }

    /* Section stats pills */
    .section-stats {
      display: inline-flex;
      gap: 0.4rem;
      flex-wrap: wrap;
      margin: 0.4rem 0;
    }
    .section-stats span {
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.65rem;
      font-weight: 500;
      padding: 0.15rem 0.5rem;
      border-radius: 9999px;
      background: var(--surface);
      border: 1px solid var(--border);
      color: var(--dim);
      letter-spacing: 0.02em;
    }

    /* Source quality indicators */
    .source-t1::before,
    .source-t2::before,
    .source-t3::before {
      content: '';
      display: inline-block;
      width: 7px;
      height: 7px;
      border-radius: 50%;
      margin-right: 0.4rem;
      vertical-align: middle;
    }
    .source-t1::before { background: var(--green); box-shadow: 0 0 4px rgba(34,197,94,0.4); }
    .source-t2::before { background: var(--blue); box-shadow: 0 0 4px rgba(59,130,246,0.4); }
    .source-t3::before { background: var(--dim); }

    /* Open questions badge */
    .oq-badge {
      display: inline-block;
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.65rem;
      font-weight: 700;
      min-width: 1.3rem;
      height: 1.3rem;
      line-height: 1.3rem;
      text-align: center;
      border-radius: 9999px;
      background: var(--amber);
      color: var(--bg);
      margin-left: 0.3rem;
      vertical-align: middle;
      letter-spacing: 0;
    }

    /* Print stylesheet */
    @media print {
      nav, .section-bar, .search-box, .search-results, .theme-toggle,
      .progress-bar, .timeline, .video-grid, .video-card, .toc-dropdown,
      .score-bar, footer { display: none !important; }
      body {
        background: #fff;
        color: #000;
        max-width: 100%;
        padding: 0;
        font-size: 11pt;
        line-height: 1.5;
      }
      h1, h2, h3, h4 { color: #000; -webkit-text-fill-color: #000; background: none; }
      h1 { font-size: 20pt; }
      h2 { font-size: 16pt; border-bottom-color: #ccc; }
      h3 { font-size: 13pt; color: #333; }
      p, li, td { color: #222; }
      a { color: #000; text-decoration: underline; }
      sup.cite { color: #555; }
      .badge { border: 1px solid #999; background: none; color: #333; }
      .stat { border-color: #ccc; }
      .stat-value { color: #000; }
      .callout { border-color: #ccc; border-left-color: #999; background: #f9f9f9; }
      blockquote { border-left-color: #999; background: #f5f5f5; }
      code { background: #f0f0f0; border-color: #ddd; }
      @page { margin: 2cm; }
    }

    @media (max-width: 640px) {
      body { padding: 1rem; }
      h1 { font-size: 1.8rem; }
      .stats { grid-template-columns: 1fr 1fr; }
      .section-grid { grid-template-columns: 1fr; }
      .video-grid { grid-template-columns: 1fr; }
      nav { flex-wrap: nowrap; overflow-x: auto; }
      nav a { white-space: nowrap; font-size: 0.8rem; padding: 0.4rem 0.75rem; }
      .search-box input { width: 100px; }
      .search-box input:focus { width: 140px; }
      .search-results { width: 280px; }
    }
  </style>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
</head>
<body>
  <div class="progress-bar" id="progress-bar"></div>
  <nav>
    <a href="index.html" class="{{nav_index}}">Research</a>
    <a href="progress.html" class="{{nav_progress}}">Progress</a>
    <a href="sections.html" class="{{nav_sections}}">Sections</a>
    <a href="sources.html" class="{{nav_sources}}">Sources</a>
    <a href="about.html" class="{{nav_about}}">About</a>
    <button class="theme-toggle" id="theme-toggle" aria-label="Toggle dark/light mode" title="Toggle theme">&#9790;</button>
    <div class="search-box">
      <input type="text" id="search-input" placeholder="Search..." aria-label="Search content">
      <div class="search-results" id="search-results"></div>
    </div>
  </nav>
  {{content}}
  <footer>
    <p>Built by <strong>Alexandru DAN</strong>, CEO <a href="#">TVL Tech</a></p>
    <p>Powered by <a href="https://github.com/danlex/autoresearch">Autoresearch</a> — Autonomous research with Claude Opus</p>
    <p><a href="https://github.com/danlex/autoresearch">GitHub Repository</a></p>
  </footer>
  <div class="cite-popover" id="cite-popover"></div>
  <script>
  (function() {
    // === Reading progress bar ===
    var progressBar = document.getElementById('progress-bar');
    function updateProgress() {
      var scrollTop = window.scrollY || document.documentElement.scrollTop;
      var docHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
      var pct = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
      progressBar.style.width = pct + '%';
    }
    window.addEventListener('scroll', updateProgress, { passive: true });
    updateProgress();

    // === Dark/light mode toggle ===
    var toggle = document.getElementById('theme-toggle');
    var root = document.documentElement;
    var stored = localStorage.getItem('ar-theme');
    if (stored) {
      root.setAttribute('data-theme', stored);
    }
    function updateToggleIcon() {
      toggle.innerHTML = root.getAttribute('data-theme') === 'light' ? '&#9728;' : '&#9790;';
    }
    updateToggleIcon();
    toggle.addEventListener('click', function() {
      var current = root.getAttribute('data-theme');
      var next = current === 'light' ? 'dark' : 'light';
      if (next === 'dark') {
        root.removeAttribute('data-theme');
      } else {
        root.setAttribute('data-theme', next);
      }
      localStorage.setItem('ar-theme', next);
      updateToggleIcon();
    });

    // === Citation popovers ===
    var popover = document.getElementById('cite-popover');
    var cites = document.querySelectorAll('sup.cite');
    var hideTimer = null;
    function showPopover(el) {
      clearTimeout(hideTimer);
      var num = el.textContent.replace(/[\\[\\]]/g, '');
      var srcEl = null;
      // Look for a matching source in the page — find li or p containing [N] as a source entry
      var allEls = document.querySelectorAll('#sources-section li, #sources-section p');
      for (var i = 0; i < allEls.length; i++) {
        if (allEls[i].textContent.match(new RegExp('^\\\\s*\\\\[?' + num + '\\\\]?[\\\\s.:\\\\-]'))) {
          srcEl = allEls[i];
          break;
        }
      }
      var text = srcEl ? srcEl.textContent.substring(0, 200) : 'Source [' + num + ']';
      popover.textContent = text;
      popover.classList.add('visible');
      var rect = el.getBoundingClientRect();
      var popW = popover.offsetWidth;
      var left = rect.left + rect.width / 2 - popW / 2;
      if (left < 8) left = 8;
      if (left + popW > window.innerWidth - 8) left = window.innerWidth - popW - 8;
      popover.style.left = left + 'px';
      popover.style.top = (rect.top + window.scrollY - popover.offsetHeight - 8) + 'px';
    }
    function hidePopover() {
      hideTimer = setTimeout(function() { popover.classList.remove('visible'); }, 200);
    }
    cites.forEach(function(c) {
      c.addEventListener('mouseenter', function() { showPopover(c); });
      c.addEventListener('mouseleave', hidePopover);
      c.addEventListener('click', function(e) {
        e.preventDefault();
        if (popover.classList.contains('visible')) {
          popover.classList.remove('visible');
        } else {
          showPopover(c);
        }
      });
    });

    // === Client-side search ===
    var searchInput = document.getElementById('search-input');
    var searchResults = document.getElementById('search-results');
    var searchTimeout = null;
    searchInput.addEventListener('input', function() {
      clearTimeout(searchTimeout);
      searchTimeout = setTimeout(doSearch, 200);
    });
    searchInput.addEventListener('focus', function() {
      if (searchInput.value.trim().length >= 2) doSearch();
    });
    document.addEventListener('click', function(e) {
      if (!e.target.closest('.search-box')) {
        searchResults.classList.remove('open');
      }
    });
    function doSearch() {
      var q = searchInput.value.trim().toLowerCase();
      if (q.length < 2) { searchResults.classList.remove('open'); return; }
      var paragraphs = document.querySelectorAll('p, li, h2, h3');
      var results = [];
      for (var i = 0; i < paragraphs.length && results.length < 12; i++) {
        var txt = paragraphs[i].textContent;
        if (txt.toLowerCase().indexOf(q) !== -1) {
          results.push({ el: paragraphs[i], text: txt.substring(0, 150) });
        }
      }
      searchResults.innerHTML = '';
      if (results.length === 0) {
        searchResults.innerHTML = '<div class="sr-empty">No results found</div>';
      } else {
        results.forEach(function(r) {
          var div = document.createElement('div');
          div.className = 'sr-item';
          var escaped = r.text.replace(/</g, '&lt;');
          var esc = q.replace(/[-.*+?^$|()\\[\\]\\\\]/g, '\\\\$&');
          var re = new RegExp('(' + esc + ')', 'gi');
          div.innerHTML = escaped.replace(re, '<mark>$1</mark>');
          div.addEventListener('click', function() {
            r.el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            searchResults.classList.remove('open');
            r.el.style.outline = '2px solid var(--amber)';
            setTimeout(function() { r.el.style.outline = ''; }, 2000);
          });
          searchResults.appendChild(div);
        });
      }
      searchResults.classList.add('open');
    }

    // === TOC dropdown for section bar ===
    var sectionBar = document.getElementById('section-bar');
    if (sectionBar) {
      var tocDrop = document.createElement('div');
      tocDrop.className = 'toc-dropdown';
      tocDrop.id = 'toc-dropdown';
      sectionBar.appendChild(tocDrop);

      sectionBar.addEventListener('click', function(e) {
        var link = e.target.closest('.section-bar a.active');
        if (!link) { tocDrop.classList.remove('open'); return; }
        e.preventDefault();
        // Find the h3s inside the target section
        var href = link.getAttribute('href');
        if (!href || href.charAt(0) !== '#') return;
        var sectionEl = document.getElementById(href.slice(1));
        if (!sectionEl) return;
        var h3s = sectionEl.querySelectorAll('h3[id]');
        if (h3s.length === 0) { tocDrop.classList.remove('open'); return; }
        tocDrop.innerHTML = '';
        h3s.forEach(function(h) {
          var a = document.createElement('a');
          a.href = '#' + h.id;
          a.textContent = h.textContent;
          a.addEventListener('click', function() { tocDrop.classList.remove('open'); });
          tocDrop.appendChild(a);
        });
        tocDrop.classList.toggle('open');
      });

      document.addEventListener('click', function(e) {
        if (!e.target.closest('.section-bar')) {
          tocDrop.classList.remove('open');
        }
      });
    }
  })();
  </script>
</body>
</html>`;

function writePage(filename, title, content, activeNav, metaDesc) {
  const desc = metaDesc || 'Autonomous research powered by Claude Opus. Built by Alexandru DAN, CEO TVL Tech.';
  let html = TEMPLATE
    .replace(/\{\{title\}\}/g, title)
    .replace(/\{\{meta_description\}\}/g, desc)
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
// Media — YouTube videos and images per section
// ============================================================================

const MEDIA = {
  'intellectual-contributions': {
    videos: [
      { id: 'Xl0E7FuXj4g', title: 'Tesla AI Day 2021 — Full Presentation', desc: 'Karpathy presents the Autopilot neural network stack' },
      { id: 'y57wwucbXR8', title: 'Building the Software 2.0 Stack (Spark+AI 2018)', desc: 'Expanding the Software 2.0 thesis with Tesla examples' },
      { id: 'bZQun8Y4L2A', title: 'State of GPT — Microsoft Build 2023', desc: 'Karpathy explains the full GPT training pipeline' },
    ],
  },
  'education-and-teaching': {
    videos: [
      { id: 'VMj-3S1tku0', title: "Let's build GPT: from scratch, in code", desc: 'Building a GPT language model step by step (1h56m)' },
      { id: 'l8pRSuU81PU', title: "Let's reproduce GPT-2 (124M)", desc: 'Full GPT-2 reproduction walkthrough (~4h)' },
      { id: 'kCc8FmEb1nY', title: 'Neural Networks: Zero to Hero — Intro', desc: 'First lecture in the Zero to Hero series' },
      { id: 'vT1JzLTH4G4', title: 'CS231n Lecture 1 — Intro to CNNs', desc: 'Stanford cs231n with Karpathy (2016)' },
    ],
  },
  'views-on-ai-future': {
    videos: [
      { id: 'EcWMbk0HuMI', title: 'Karpathy on Lex Fridman Podcast #333', desc: 'Deep dive on AI future, Tesla, OpenAI, and education' },
      { id: 'hM_h0UA7upI', title: 'Andrej Karpathy — Dwarkesh Patel 2025', desc: 'AGI timelines, OpenAI reflections, AI safety' },
    ],
  },
  'eureka-labs': {
    videos: [
      { id: 'VMj-3S1tku0', title: "Let's build GPT (Eureka Labs precursor)", desc: 'The teaching style that inspired Eureka Labs' },
    ],
  },
  'key-relationships': {
    videos: [
      { id: 'Xl0E7FuXj4g', title: 'Tesla AI Day 2021 — with Musk', desc: 'Karpathy presenting alongside Elon Musk' },
    ],
  },
};

function renderVideoGrid(sectionKey) {
  const media = MEDIA[sectionKey];
  if (!media || !media.videos || media.videos.length === 0) return '';

  let html = '<div class="video-grid">';
  for (const v of media.videos) {
    html += `
      <div class="video-card">
        <iframe src="https://www.youtube.com/embed/${v.id}" allowfullscreen loading="lazy"></iframe>
        <div class="video-info">
          <div class="video-title">${v.title}</div>
          <div class="video-desc">${v.desc}</div>
        </div>
      </div>
    `;
  }
  html += '</div>';
  return html;
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

  // Build section summaries for the overview
  const sectionMeta = [
    { file: 'intellectual-contributions.md', name: 'Intellectual Contributions', anchor: 'intellectual-contributions', desc: 'Stanford PhD, OpenAI, Tesla Autopilot, Software 2.0 thesis' },
    { file: 'education-and-teaching.md', name: 'Education and Teaching', anchor: 'education-and-teaching', desc: 'cs231n, nanoGPT, micrograd, Zero to Hero, pedagogical approach' },
    { file: 'views-on-ai-future.md', name: 'Views on AI Future', anchor: 'views-on-ai-future', desc: 'AGI timelines, safety concerns, slopacolypse, Software 3.0' },
    { file: 'eureka-labs.md', name: 'Eureka Labs', anchor: 'eureka-labs', desc: 'AI-native school, LLM101n, nanochat, pedagogical model' },
    { file: 'key-relationships.md', name: 'Key Relationships', anchor: 'key-relationships', desc: 'Elon Musk, Fei-Fei Li, Ilya Sutskever, collaborations' },
  ];

  let body = `
    <h1>Andrej Karpathy — Research Document</h1>

    <div class="profile-row">
      <img src="karpathy.jpg" alt="Andrej Karpathy" class="profile-img">
      <div class="profile-text">
        <p style="font-size: 1.1rem; margin: 0 0 0.5rem;">
          <strong>Andrej Karpathy</strong> — AI researcher, educator, and entrepreneur.
        </p>
        <p style="color: var(--dim); margin: 0;">
          Founding member of OpenAI. Former Director of AI at Tesla Autopilot.
          Creator of cs231n, nanoGPT, and micrograd. Founder of Eureka Labs.
          Stanford PhD under Fei-Fei Li.
        </p>
      </div>
    </div>

    <p style="font-size: 0.95rem; color: var(--dim); margin: 1rem 0 2rem;">
      This document was autonomously researched using <a href="https://github.com/danlex/autoresearch">Autoresearch</a> —
      an AI-powered system that generates research questions, searches the web, writes findings with inline citations,
      and verifies everything through a three-judge review panel. Built by <strong>Alexandru DAN</strong>, CEO TVL Tech.
    </p>

    <div class="stats">
      <div class="stat"><div class="stat-value" style="color: var(--green)">${score}%</div><div class="stat-label">Research Score</div></div>
      <div class="stat"><div class="stat-value">${header.tasks}</div><div class="stat-label">Tasks</div></div>
      <div class="stat"><div class="stat-value">${header.sources}</div><div class="stat-label">Sources</div></div>
      <div class="stat"><div class="stat-value">${header.updated}</div><div class="stat-label">Last Updated</div></div>
    </div>
    <div class="score-bar"><div class="score-fill" style="width: ${score}%"></div></div>

    <div class="timeline">
      <div class="timeline-item"><a href="#intellectual-contributions"><span class="tl-dot"></span><span class="tl-year">2011</span><span class="tl-title">Stanford PhD</span></a></div>
      <span class="tl-connector"></span>
      <div class="timeline-item"><a href="#intellectual-contributions"><span class="tl-dot" style="background: var(--green)"></span><span class="tl-year">2015</span><span class="tl-title">OpenAI</span></a></div>
      <span class="tl-connector"></span>
      <div class="timeline-item"><a href="#intellectual-contributions"><span class="tl-dot" style="background: var(--red)"></span><span class="tl-year">2017</span><span class="tl-title">Tesla AI</span></a></div>
      <span class="tl-connector"></span>
      <div class="timeline-item"><a href="#education-and-teaching"><span class="tl-dot" style="background: var(--cyan)"></span><span class="tl-year">2022</span><span class="tl-title">nanoGPT</span></a></div>
      <span class="tl-connector"></span>
      <div class="timeline-item"><a href="#intellectual-contributions"><span class="tl-dot" style="background: var(--green)"></span><span class="tl-year">2023</span><span class="tl-title">OpenAI #2</span></a></div>
      <span class="tl-connector"></span>
      <div class="timeline-item"><a href="#eureka-labs"><span class="tl-dot" style="background: var(--purple)"></span><span class="tl-year">2024</span><span class="tl-title">Eureka Labs</span></a></div>
    </div>

    <h2>Sections</h2>
    <div class="section-grid">
  `;

  for (const s of sectionMeta) {
    body += `
      <a href="#${s.anchor}" class="section-card">
        <strong>${s.name}</strong>
        <p>${s.desc}</p>
      </a>
    `;
  }

  body += '</div>';

  // Build section bar (horizontal, under main nav)
  let barHtml = '<div class="section-bar" id="section-bar">';
  for (const s of sectionMeta) {
    barHtml += '<a href="#' + s.anchor + '">' + s.name + '</a>';
  }
  barHtml += '<a href="#sources-section">Sources</a>';
  barHtml += '<a href="#about-section">About</a>';
  barHtml += '</div>';

  body += barHtml;

  // Calculate total reading time
  let totalWords = 0;
  for (const s of sectionMeta) {
    const content = readSection(s.file);
    totalWords += content.split(/\s+/).length;
  }
  const readingMinutes = Math.ceil(totalWords / 230);
  body += '<p class="reading-time">' + readingMinutes + ' min read · ' + totalWords.toLocaleString() + ' words</p>';

  // Build content sections with stats and callout boxes
  for (const s of sectionMeta) {
    const content = readSection(s.file);
    if (content.trim()) {
      const words = content.split(/\s+/).length;
      const citeCount = (content.match(/\[\d+\]/g) || []).length;
      const subsections = (content.match(/^### .+$/gm) || []).length;
      const highConf = (content.match(/Confidence: HIGH/g) || []).length;
      const medConf = (content.match(/Confidence: MEDIUM/g) || []).length;
      const lowConf = (content.match(/Confidence: LOW/g) || []).length;

      // Get first substantive paragraph as callout
      const paragraphs = content.split('\\n').filter(l => l.trim() && !l.startsWith('#') && !l.startsWith('**Confidence') && !l.startsWith('**Uncertainty') && !l.startsWith('>') && l.length > 80);
      const calloutText = paragraphs.length > 0 ? paragraphs[0].substring(0, 300).replace(/\[\d+\]/g, '') + '...' : '';

      let sectionHtml = md2html(content);
      // Add id anchors to h3 headings
      sectionHtml = sectionHtml.replace(/<h3>(.+?)<\/h3>/g, (match, title) => {
        const anchor = title.toLowerCase().replace(/<[^>]+>/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '').substring(0, 60);
        return '<h3 id="' + anchor + '">' + title + '</h3>';
      });

      body += '<div id="' + s.anchor + '">';

      // Section stats
      body += '<div class="section-stats">';
      body += '<span>' + words + ' words</span>';
      body += '<span>' + citeCount + ' citations</span>';
      body += '<span>' + subsections + ' subsections</span>';
      if (highConf > 0) body += '<span style="color: var(--green);">' + highConf + ' HIGH</span>';
      if (medConf > 0) body += '<span style="color: var(--amber);">' + medConf + ' MED</span>';
      if (lowConf > 0) body += '<span style="color: var(--red);">' + lowConf + ' LOW</span>';
      body += '</div>';

      // Callout box (TL;DR)
      if (calloutText) {
        body += '<div class="callout">' + calloutText + '</div>';
      }

      body += sectionHtml;

      const videos = renderVideoGrid(s.anchor);
      if (videos) {
        body += '<h3 style="color: var(--dim); margin-top: 2rem;">Related Videos</h3>' + videos;
      }
      body += '</div><hr>';
    }
  }

  // Sources with tier indicators
  let sourcesHtml = readSection('sources.md');
  sourcesHtml = sourcesHtml
    .replace(/^(- \[\d+\].*)(Tier 1)(.*$)/gm, '$1<span class="source-t1">Tier 1</span>$3')
    .replace(/^(- \[\d+\].*)(Tier 2)(.*$)/gm, '$1<span class="source-t2">Tier 2</span>$3')
    .replace(/^(- \[\d+\].*)(Tier 3)(.*$)/gm, '$1<span class="source-t3">Tier 3</span>$3');
  body += '<div id="sources-section">' + md2html(sourcesHtml) + '</div>';

  // About section at bottom of index
  body += `
    <hr>
    <div id="about-section">
      <h2>About This Research</h2>
      <p>This document was produced autonomously by <a href="https://github.com/danlex/autoresearch">Autoresearch</a> — an open-source AI research system that generates questions, searches the web, writes findings with inline citations, and verifies everything through a three-judge review panel.</p>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin: 1.5rem 0;">
        <div style="background: var(--surface); padding: 1.5rem; border-radius: 12px; border: 1px solid var(--border);">
          <h3 style="color: var(--amber); margin: 0 0 0.5rem; font-size: 1.1rem;">Alexandru DAN</h3>
          <p style="color: var(--text-secondary); margin: 0 0 0.5rem; font-size: 0.85rem; font-weight: 500;">CEO & Founder, TVL Tech</p>
          <p style="font-size: 0.9rem;">Building autonomous AI tools that produce verified, citation-backed knowledge.</p>
          <p style="margin-top: 0.5rem; font-size: 0.85rem;"><a href="https://github.com/danlex">GitHub</a></p>
        </div>
        <div style="background: var(--surface); padding: 1.5rem; border-radius: 12px; border: 1px solid var(--border);">
          <h3 style="background: var(--gradient-2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin: 0 0 0.5rem; font-size: 1.1rem;">TVL Tech</h3>
          <p style="color: var(--text-secondary); margin: 0 0 0.5rem; font-size: 0.85rem; font-weight: 500;">Technology. Vision. Leadership.</p>
          <p style="font-size: 0.9rem;">AI-first tools and platforms — autonomous research, AI workflows, open source.</p>
        </div>
      </div>

      <p style="font-size: 0.9rem; color: var(--text-secondary);">Every claim has inline <sup class="cite">[N]</sup> citations. Three independent judges (Evidence, Consistency, Completeness) review all content. The full research process — every Issue, PR, and judge review — is public on <a href="https://github.com/danlex/autoresearch">GitHub</a>.</p>
    </div>
  `;

  // Scroll spy: highlight active section in the bar
  body += `
  <script>
    const barLinks = document.querySelectorAll('.section-bar a[href^="#"]');
    const sects = [];
    barLinks.forEach(link => {
      const id = link.getAttribute('href').slice(1);
      const el = document.getElementById(id);
      if (el) sects.push({ el, link });
    });
    function updateBar() {
      let current = sects[0];
      for (const s of sects) {
        if (s.el.getBoundingClientRect().top <= 150) current = s;
      }
      barLinks.forEach(l => l.classList.remove('active'));
      if (current) current.link.classList.add('active');
    }
    window.addEventListener('scroll', updateBar, { passive: true });
    updateBar();
  </script>`;

  writePage('index.html', 'Research Document', body, 'index',
    'Comprehensive autonomous research on Andrej Karpathy — AI researcher, educator, OpenAI founding member, Tesla AI Director, Eureka Labs founder. ' + score + '% complete with ' + header.sources + ' verified sources.');
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

// --- 5. about.html — Project + Author ---
{
  let body = `
    <h1>About Autoresearch</h1>

    <div style="background: var(--surface); padding: 2rem; border-radius: 16px; border: 1px solid var(--border); margin: 2rem 0;">
      <h3 style="color: var(--amber); margin: 0 0 0.3rem; font-size: 1.3rem;">Alexandru DAN</h3>
      <p style="color: var(--text-secondary); margin: 0 0 1rem; font-weight: 500;">CEO & Founder, TVL Tech</p>
      <p>Creator of the Autoresearch system. Building autonomous AI-powered research tools that produce verified, citation-backed knowledge with zero human intervention.</p>
      <p style="margin-top: 0.8rem;">
        <a href="https://github.com/danlex" style="margin-right: 1.5rem;">GitHub</a>
        <a href="https://github.com/danlex/autoresearch">Autoresearch Repository</a>
      </p>
    </div>

    <div style="background: var(--surface); padding: 2rem; border-radius: 16px; border: 1px solid var(--border); margin: 2rem 0;">
      <h3 style="background: var(--gradient-2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin: 0 0 0.5rem; font-size: 1.3rem;">TVL Tech</h3>
      <p style="color: var(--text-secondary); margin: 0 0 1rem; font-weight: 500;">Technology. Vision. Leadership.</p>
      <p>TVL Tech builds AI-first tools and platforms that augment human capabilities. Our focus areas:</p>
      <ul>
        <li><strong>Autonomous Research</strong> — AI systems that research, verify, and publish knowledge independently, with human oversight at every stage</li>
        <li><strong>AI-Powered Workflows</strong> — Integrating large language models into real business processes — not chatbots, but autonomous agents that do actual work</li>
        <li><strong>Open Source AI Tools</strong> — Contributing to the ecosystem with production-grade tools like Autoresearch that anyone can use and extend</li>
      </ul>
      <p style="margin-top: 1rem;">TVL Tech believes the most impactful AI applications are not consumer chat products but <strong>infrastructure that makes knowledge workers more effective</strong> — automating the research, verification, and synthesis steps that consume 80% of knowledge work.</p>
      <p style="margin-top: 0.8rem; color: var(--dim);">Autoresearch is TVL Tech's first open-source release — a proof that autonomous AI research is possible, auditable, and trustworthy when built with the right guardrails (three-judge review, mandatory citations, source verification).</p>
    </div>

    <h2>What is Autoresearch?</h2>
    <p>Autoresearch is a single-subject autonomous research system. You define a research goal, and the system does everything else: generates research questions, searches the web, writes findings with inline citations, and verifies everything through a three-judge review panel.</p>

    <p>The entire research process is transparent and auditable. Every finding has numbered citations <sup class="cite">[N]</sup> linking to verified sources. Three independent Claude Opus judges — focused on evidence, consistency, and completeness — review every piece of content before it's published. If they find issues, they fix them. After three rounds without consensus, content is published with review notes.</p>

    <h2>How It Works</h2>
    <div style="background: var(--surface); padding: 1.2rem; border-radius: 8px; font-family: 'JetBrains Mono', monospace; font-size: 0.85rem; line-height: 2; border: 1px solid var(--border); margin: 1rem 0;">
      <span style="color: var(--amber);">goal.md</span> defines the subject<br>
      &nbsp;&nbsp;&darr;<br>
      <span style="color: var(--cyan);">explode-goal.sh</span> generates 30-50 research tasks<br>
      &nbsp;&nbsp;&darr;<br>
      <span style="color: var(--green);">research.sh</span> picks tasks, runs Claude Code (web search + write)<br>
      &nbsp;&nbsp;&darr;<br>
      <span style="color: var(--blue);">3 judges</span> review: Evidence, Consistency, Completeness<br>
      &nbsp;&nbsp;&darr;<br>
      <span style="color: var(--green);">PR merged</span> &rarr; findings published &rarr; new tasks proposed<br>
      &nbsp;&nbsp;&darr;<br>
      Score climbs toward <span style="color: var(--green);">100%</span>
    </div>

    <h2>The Score</h2>
    <p>The research score (0-100%) is computed from three components:</p>
    <ul>
      <li><strong>Task completion (60%)</strong> — percentage of research Issues completed</li>
      <li><strong>Citation quality (30%)</strong> — percentage of content paragraphs with inline [N] citations</li>
      <li><strong>Confidence (10%)</strong> — penalizes LOW confidence sections</li>
    </ul>
    <p>The system only publishes content when document changes are detected. Judges can fix issues directly — they help, never block.</p>

    <h2>The Three Judges</h2>
    <table style="width: 100%; border-collapse: collapse; margin: 1rem 0;">
      <tr style="border-bottom: 1px solid var(--border);">
        <th style="text-align: left; padding: 0.5rem; color: var(--amber);">Judge</th>
        <th style="text-align: left; padding: 0.5rem; color: var(--amber);">Focus</th>
        <th style="text-align: left; padding: 0.5rem; color: var(--amber);">Checks</th>
      </tr>
      <tr style="border-bottom: 1px solid var(--border);">
        <td style="padding: 0.5rem;">Judge 1</td>
        <td style="padding: 0.5rem; color: var(--green);">Evidence</td>
        <td style="padding: 0.5rem;">Fabricated facts, phantom citations, unsourced claims</td>
      </tr>
      <tr style="border-bottom: 1px solid var(--border);">
        <td style="padding: 0.5rem;">Judge 2</td>
        <td style="padding: 0.5rem; color: var(--blue);">Consistency</td>
        <td style="padding: 0.5rem;">Contradictions, date mismatches, style, confidence levels</td>
      </tr>
      <tr>
        <td style="padding: 0.5rem;">Judge 3</td>
        <td style="padding: 0.5rem; color: var(--cyan);">Completeness</td>
        <td style="padding: 0.5rem;">Coverage gaps, missing perspectives, skeptical outsider view</td>
      </tr>
    </table>

    <h2>Technology</h2>
    <ul>
      <li><strong>Research engine:</strong> Claude Opus via Claude Code CLI (<code>claude -p</code>)</li>
      <li><strong>Orchestration:</strong> <code>research.sh</code> — bash loop managing branches, PRs, judges</li>
      <li><strong>Task management:</strong> GitHub Issues with labels for type, priority, status</li>
      <li><strong>Backend:</strong> NestJS with hourly cron scheduler</li>
      <li><strong>Quality:</strong> ShellCheck + 83 automated tests (bash + Jest)</li>
    </ul>

    <h2>Source Code</h2>
    <p>Autoresearch is open source. The full code, research history, and all Issues are public.</p>
    <p style="margin: 1rem 0;">
      <a href="https://github.com/danlex/autoresearch" style="background: var(--amber); color: var(--bg); padding: 0.6rem 1.2rem; border-radius: 4px; text-decoration: none; font-family: 'JetBrains Mono', monospace; font-weight: bold;">View on GitHub</a>
    </p>
  `;

  writePage('about.html', 'About', body, 'about',
    'Autoresearch — autonomous research system by Alexandru DAN, CEO TVL Tech. Open source, powered by Claude Opus.');
}

console.log('\nDone! Site generated in docs/');
console.log('Enable GitHub Pages: Settings → Pages → Source: Deploy from branch → /docs');
