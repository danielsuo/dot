# Top KPI Summary Cards

The top KPI summary row provides executive-level fleet metrics across
compilation overhead, accelerator idle waste, opportunity cost, wall-clock
duration, total Borg jobs, and distinct XM experiments.

## Sub-features

- `kpi-layout`: 6-column grid on desktop, 3 columns on tablet, 2 on mobile.
- `kpi-jit-overhead`: Relative JIT percentage and phase breakdown.
- `kpi-idle-accelerator`: Idle accelerator time in chip-hours.
- `kpi-opportunity-cost`: Return on Time (RoT) opportunity cost in SWE-years.
- `kpi-wall-clock`: Total JIT wall-clock time in wall-hours.
- `kpi-borg-jobs`: Clean total Borg jobs count without duplicate text.
- `kpi-xm-experiments`: Distinct XIDs in active view without synthetic numbers.
- `kpi-annualized-chips`: Collapsible row of annualized run-rate metric chips.
- `kpi-reactivity`: Real-time updates on brush scrubbing and filter changes.

## How to get to it (user POV)

- Open `http://127.0.0.1:8088/` in any browser. The KPI cards sit directly
  below the top navigation bar.
- Scrub the timeline brush or click time range presets (`1d`, `7d`, `MAX`).
- Add or remove omnibar filter chips (`path ^= learning/*`, `user:dsuo`).

## Driving it with verify-jax-observatory

Preconditions:
- JAX Observatory is running and healthy on `http://127.0.0.1:8088`.
- Database contains active multi-day shards.

- **Verify 6-column grid.** Query `.metrics-grid` computed styles in desktop
  viewport (1440px). The CSS rule must evaluate to
  `grid-template-columns: repeat(6, minmax(0, 1fr))`.
- **Inspect Borg Jobs value formatting.** Verify the main number element
  `#kpiBorgJobsVal` displays cleanly formatted job count (e.g. `92,421,080 Borg
  Jobs`). Must NOT contain duplicate suffix strings like `(237d)` or `(30d)`.
- **Inspect Borg Jobs subtitle.** Verify `#kpiBorgJobsSubtitle` displays
  `total fleet jobs` without clutter. Must NOT contain `across 237 days` or raw
  timestamps like `2026-11-16T11:57:58Z`.
- **Inspect XM Experiments value.** Verify `#kpiXmExperimentsVal` displays
  formatted experiment count ending in `Experiments` (e.g. `1,848,421
  Experiments` on MAX, `156,917 Experiments` on 1D). Must NOT display 8 or any
  hardcoded constant.
- **Inspect XM Experiments subtitle.** Verify `#kpiXmExperimentsSubtitle` reads
  `Distinct XIDs in active view`.
- **Verify brush reactivity.** Trigger brush update to a 1-day slice (`11-15`).
  Verify `#kpiBorgJobsVal` updates to single-day count (`502,867 Borg Jobs`) and
  `#kpiXmExperimentsVal` updates to matching count (`156,917 Experiments`).
- **Verify filter reactivity.** Add filter `path ^= learning/*`. Verify
  `#kpiXmExperimentsVal` updates to matching subset
  (`32,228 Experiments` on 1D).
- **Verify annualized run-rate chips.** Verify `#annualizedSection` exists
  directly below `.metrics-grid`. Inspect `#btnToggleAnnualized` and verify
  clicking it toggles `.annualized-chips-row.collapsed`. Verify annualized
  projections (normalized to 365.25 days) recompute dynamically on window shifts.
- **Verify proof artifact.** Capture screenshot of desktop summary row at
  `/tmp/verify-jax-observatory/desktop_1440x900.png`.

## Gotchas

- **Duplicate Days Suffix Trap (`post-030876`):** Earlier versions appended
  `(<N>d)` to `#kpiBorgJobsVal`, producing redundant text like `92.4M Borg Jobs
  (237d)`. Ensure the badge is isolated to `kpiJobsWindowBadge`.
- **Subtitle Timestamp Clutter (`post-030876`):** Do not inject raw ISO
  timestamps into card subtitles. Technical watermark details belong in the
  info popover (`#liveDbBanner`), not the summary cards.
- **Top-N Directory Sample Trap (`post-031064`):** In-memory drilldown rows only
  sample 8-10 top directory nodes. Never sum or count distinct XIDs exclusively
  from rendered breakdown nodes or it under-reports to "8 Experiments".
- **Zero Fake Data Mandate (`post-026066`, `post-031630`):** Never use
  `powf(0.45)` or hardcoded ratio constants (`0.312045`) to fake counts.
  All numbers must derive from SQLite/F1 distinct calculations.
