<script lang="ts">
  let { videoId, title, desc }: { videoId: string; title: string; desc: string } = $props();
</script>

<div class="bg-surface border border-border rounded-xl overflow-hidden transition-all hover:border-white/15 hover:-translate-y-0.5">
  <div class="lite-youtube" data-id={videoId}>
    <img
      src={`https://img.youtube.com/vi/${videoId}/hqdefault.jpg`}
      alt={title}
      loading="lazy"
    />
    <button class="lite-yt-play" aria-label="Play {title}"></button>
  </div>
  <div class="p-4">
    <div class="text-text-primary font-semibold text-[0.9rem]">{title}</div>
    <div class="text-dim text-[0.8rem] mt-1">{desc}</div>
  </div>
</div>
