import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';

// Astro builds from site/ — project root is one level up
const ROOT = path.resolve(process.cwd(), '..');
const SECTIONS_DIR = path.join(ROOT, 'sections');

function readFile(filepath: string): string {
  try { return fs.readFileSync(filepath, 'utf-8'); } catch { return ''; }
}

export interface SectionMeta {
  slug: string;
  name: string;
  desc: string;
  file: string;
}

export const SECTIONS: SectionMeta[] = [
  { slug: 'intellectual-contributions', name: 'Intellectual Contributions', desc: 'Stanford PhD, OpenAI, Tesla Autopilot, Software 2.0 thesis', file: 'intellectual-contributions.md' },
  { slug: 'education-and-teaching', name: 'Education and Teaching', desc: 'cs231n, nanoGPT, micrograd, Zero to Hero, pedagogical approach', file: 'education-and-teaching.md' },
  { slug: 'views-on-ai-future', name: 'Views on AI Future', desc: 'AGI timelines, safety concerns, slopacolypse, Software 3.0', file: 'views-on-ai-future.md' },
  { slug: 'eureka-labs', name: 'Eureka Labs', desc: 'AI-native school, LLM101n, nanochat, pedagogical model', file: 'eureka-labs.md' },
  { slug: 'key-relationships', name: 'Key Relationships', desc: 'Elon Musk, Fei-Fei Li, Ilya Sutskever, collaborations', file: 'key-relationships.md' },
];

export function readSection(filename: string): string {
  return readFile(path.join(SECTIONS_DIR, filename));
}

export function getHeader() {
  const doc = readFile(path.join(ROOT, 'document.md'));
  const match = doc.match(/Coverage: (\S+) \| Tasks: (\S+) \| Sources: (\S+) \| Last updated: (\S+)/);
  if (match) return { coverage: match[1], tasks: match[2], sources: match[3], updated: match[4] };
  return { coverage: '?', tasks: '?', sources: '?', updated: '?' };
}

export function getScore() {
  try {
    const output = execSync('bash autoresearch.sh 2>&1', { cwd: ROOT }).toString();
    const lines = output.split('\n');
    return { score: lines[0].trim(), breakdown: lines[1] || '' };
  } catch {
    return { score: '?', breakdown: '' };
  }
}

export function getStatus() {
  try {
    return JSON.parse(readFile(path.join(ROOT, 'status.json')));
  } catch {
    return {};
  }
}

export function getChangelog(): string {
  return readFile(path.join(ROOT, 'changelog.md'));
}

export interface SourceEntry {
  number: number;
  tier: 1 | 2 | 3;
  text: string;
}

export function parseSources(): { entries: SourceEntry[]; raw: string } {
  const raw = readFile(path.join(SECTIONS_DIR, 'sources.md'));
  const entries: SourceEntry[] = [];
  let currentTier: 1 | 2 | 3 = 1;
  for (const line of raw.split('\n')) {
    if (line.startsWith('### Tier 1')) { currentTier = 1; continue; }
    if (line.startsWith('### Tier 2')) { currentTier = 2; continue; }
    if (line.startsWith('### Tier 3')) { currentTier = 3; continue; }
    const match = line.match(/^- \[(\d+)\]/);
    if (match) {
      let tier = currentTier;
      if (line.includes('Tier 1')) tier = 1;
      else if (line.includes('Tier 2')) tier = 2;
      else if (line.includes('Tier 3')) tier = 3;
      entries.push({ number: parseInt(match[1]), tier, text: line.replace(/^- /, '') });
    }
  }
  return { entries, raw };
}

export interface SectionStats {
  slug: string;
  name: string;
  words: number;
  citations: number[];
  subsections: string[];
  highConf: number;
  medConf: number;
  lowConf: number;
  readingMinutes: number;
  content: string;
}

export function getSectionStats(meta: SectionMeta): SectionStats {
  const content = readSection(meta.file);
  const words = content.split(/\s+/).filter(Boolean).length;
  const citationMatches = content.match(/\[(\d+)\]/g) || [];
  const citations = [...new Set(citationMatches.map(m => parseInt(m.replace(/[\[\]]/g, ''))))];
  const subsectionMatches = content.match(/^### .+$/gm) || [];
  const subsections = subsectionMatches.map(s => s.replace(/^### /, ''));
  const highConf = (content.match(/Confidence: HIGH/g) || []).length;
  const medConf = (content.match(/Confidence: MEDIUM/g) || []).length;
  const lowConf = (content.match(/Confidence: LOW/g) || []).length;
  return {
    slug: meta.slug,
    name: meta.name,
    words,
    citations,
    subsections,
    highConf,
    medConf,
    lowConf,
    readingMinutes: Math.ceil(words / 230),
    content,
  };
}

export interface SourceDashboard {
  total: { t1: number; t2: number; t3: number };
  bySection: { slug: string; name: string; t1: number; t2: number; t3: number }[];
}

export function getSourceDashboard(): SourceDashboard {
  const { entries } = parseSources();
  const tierMap = new Map(entries.map(e => [e.number, e.tier]));
  const total = { t1: 0, t2: 0, t3: 0 };
  for (const e of entries) {
    if (e.tier === 1) total.t1++;
    else if (e.tier === 2) total.t2++;
    else total.t3++;
  }
  const bySection = SECTIONS.map(meta => {
    const stats = getSectionStats(meta);
    let t1 = 0, t2 = 0, t3 = 0;
    for (const num of stats.citations) {
      const tier = tierMap.get(num);
      if (tier === 1) t1++;
      else if (tier === 2) t2++;
      else if (tier === 3) t3++;
    }
    return { slug: meta.slug, name: meta.name, t1, t2, t3 };
  });
  return { total, bySection };
}

export const MEDIA: Record<string, { videos: { id: string; title: string; desc: string }[] }> = {
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
