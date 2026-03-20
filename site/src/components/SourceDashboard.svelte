<script lang="ts">
  interface SectionData { slug: string; name: string; t1: number; t2: number; t3: number; }
  let { total, bySection }: { total: { t1: number; t2: number; t3: number }; bySection: SectionData[] } = $props();

  function pct(n: number, t: number) { return t > 0 ? (n / t * 100).toFixed(1) : '0'; }
</script>

<div class="bg-surface border border-border rounded-xl p-5 my-6">
  <h3 class="text-text-secondary font-semibold text-[0.95rem] mt-0 mb-4">Source Quality</h3>

  <!-- Overall -->
  <div class="flex items-center gap-3 mb-4">
    <span class="font-mono text-[0.7rem] font-medium text-dim w-16">Overall</span>
    <div class="source-bar flex-1">
      <div class="t1" style={`width: ${pct(total.t1, total.t1 + total.t2 + total.t3)}%`}></div>
      <div class="t2" style={`width: ${pct(total.t2, total.t1 + total.t2 + total.t3)}%`}></div>
      <div class="t3" style={`width: ${pct(total.t3, total.t1 + total.t2 + total.t3)}%`}></div>
    </div>
    <span class="font-mono text-[0.65rem] text-dim w-24 text-right">{total.t1 + total.t2 + total.t3} sources</span>
  </div>

  <!-- Per section -->
  {#each bySection as sec}
    {@const t = sec.t1 + sec.t2 + sec.t3}
    {#if t > 0}
      <div class="flex items-center gap-3 mb-2">
        <span class="font-mono text-[0.65rem] font-medium text-dim w-16 truncate" title={sec.name}>{sec.name.split(' ')[0]}</span>
        <div class="source-bar flex-1">
          <div class="t1" style={`width: ${pct(sec.t1, t)}%`}></div>
          <div class="t2" style={`width: ${pct(sec.t2, t)}%`}></div>
          <div class="t3" style={`width: ${pct(sec.t3, t)}%`}></div>
        </div>
        <span class="font-mono text-[0.6rem] text-dim w-24 text-right">{sec.t1}T1 {sec.t2}T2 {sec.t3}T3</span>
      </div>
    {/if}
  {/each}

  <!-- Legend -->
  <div class="flex gap-4 mt-4 pt-3 border-t border-border">
    <span class="flex items-center gap-1.5 text-[0.7rem] text-dim">
      <span class="w-2.5 h-2.5 rounded-full bg-ar-green shadow-[0_0_4px_rgba(34,197,94,0.4)]"></span> Tier 1 ({total.t1})
    </span>
    <span class="flex items-center gap-1.5 text-[0.7rem] text-dim">
      <span class="w-2.5 h-2.5 rounded-full bg-ar-blue shadow-[0_0_4px_rgba(59,130,246,0.4)]"></span> Tier 2 ({total.t2})
    </span>
    <span class="flex items-center gap-1.5 text-[0.7rem] text-dim">
      <span class="w-2.5 h-2.5 rounded-full bg-dim"></span> Tier 3 ({total.t3})
    </span>
  </div>
</div>
