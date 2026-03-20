// @ts-check
import { defineConfig } from 'astro/config';
import svelte from '@astrojs/svelte';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://danlex.github.io',
  base: '/autoresearch',
  integrations: [svelte()],
  outDir: '../docs',
  build: { assets: '_assets' },
  vite: {
    plugins: [tailwindcss()],
  },
});
