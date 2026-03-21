/** Zero-dependency Markdown-like → HTML converter with XSS protection */

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function sanitizeUrl(url: string): string {
  const trimmed = url.trim();
  if (/^https?:\/\//i.test(trimmed) || trimmed.startsWith('#') || trimmed.startsWith('/')) {
    return trimmed;
  }
  return '#'; // block javascript:, data:, and other dangerous protocols
}

export function md2html(md: string): string {
  // First, escape all HTML in the raw markdown to prevent injection
  let html = escapeHtml(md);

  // Now apply markdown transformations on the escaped content
  html = html
    .replace(/^#### (.+)$/gm, '<h4>$1</h4>')
    .replace(/^### (.+)$/gm, (_, title) => {
      const id = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '').substring(0, 60);
      return `<h3 id="${id}"><a href="#${id}" class="heading-anchor" aria-label="Link to this section">#</a>${title}</h3>`;
    })
    .replace(/^## (.+)$/gm, '<h2>$1</h2>')
    .replace(/^# (.+)$/gm, '<h1>$1</h1>')
    .replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>')
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    .replace(/`(.+?)`/g, '<code>$1</code>')
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, (_, text, url) => {
      return `<a href="${sanitizeUrl(url)}" target="_blank" rel="noopener">${text}</a>`;
    })
    .replace(/\[(\d+)\]/g, '<sup class="cite" data-num="$1">[$1]</sup>')
    .replace(/^&gt;\s*(.+)$/gm, '<blockquote>$1</blockquote>') // escaped > from escapeHtml
    .replace(/^---$/gm, '<hr>')
    .replace(/^- (.+)$/gm, '<li>$1</li>')
    .replace(/Confidence: HIGH/g, '<span class="badge-high">HIGH</span>')
    .replace(/Confidence: MEDIUM/g, '<span class="badge-med">MEDIUM</span>')
    .replace(/Confidence: LOW/g, '<span class="badge-low">LOW</span>')
    .replace(/Depth: HIGH/g, '<span class="badge-high">HIGH</span>')
    .replace(/Depth: MEDIUM/g, '<span class="badge-med">MEDIUM</span>')
    .replace(/Depth: LOW/g, '<span class="badge-low">LOW</span>')
    .replace(/\*\*Uncertainty:\*\*/g, '<div class="unc-header">⚠ Uncertainty:</div><div class="unc-content">')
    .replace(/(<li>.*<\/li>\n?)+/g, '<ul>$&</ul>');

  html = html.split('\n').map(line => {
    if (line.trim() === '') return '';
    if (/^<[houldb]|^<hr|^<sup|^<blockquote/.test(line.trim())) return line;
    if (line.trim().startsWith('<li>')) return line;
    return `<p>${line}</p>`;
  }).join('\n');

  return html;
}
