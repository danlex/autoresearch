// @ts-check
import { defineConfig } from 'astro/config';
import svelte from '@astrojs/svelte';
import tailwindcss from '@tailwindcss/vite';

import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://danlex.github.io',
  base: '/autoresearch',
  integrations: [svelte(), sitemap()],
  outDir: '../docs',
  build: { assets: '_assets' },
  vite: {
    plugins: [tailwindcss()],
  },
});