# Timeline Scrubber & Time Range Presets

The timeline scrubber provides visual date-range selection across the entire
237-day JAX fleet history using interactive brush handles, timeline panning,
and one-click preset buttons.

## Sub-features

- `scrubber-horizon`: Full 237-day timeline (2026-03-23 to 2026-11-15).
- `scrubber-presets`: Quick selection via `1d`, `3d`, `7d`, `14d`, `30d`, `MAX`.
- `scrubber-brush-drag`: Direct drag-to-resize on left and right grip handles.
- `scrubber-window-pan`: Direct drag-to-pan of the active window box.
- `scrubber-persistence`: Date window preserved across drilldown clicks.
- `scrubber-step-buttons`: Single-step left and right window stepping buttons.

## How to get to it (user POV)

- Locate the `Timeline Scrubber` directly beneath the time preset controls.
- Click any preset button (`1d`, `7d`, `30d`, `MAX`) in the time toolbar.
- Click and drag the left or right pill handle on the scrubber to resize.
- Click and drag inside the translucent window box to slide across time.
- Click the left (`◀`) or right (`▶`) chevron buttons to step one window.

## Driving it with verify-jax-observatory

Preconditions:
- JAX Observatory is running and healthy on `http://127.0.0.1:8088`.
- Historical daily shards are loaded.

- **Verify preset buttons exist.** Check that `#btnRange1d`, `#btnRange3d`,
  `#btnRange7d`, `#btnRange14d`, `#btnRange30d`, and `#btnRangeMax` exist and
  are clickable.
- **Select MAX preset.** Click `#btnRangeMax` or navigate to `/?range=MAX`.
  Verify the active window label updates to `2026-03-23 .. 2026-11-15 (237 of
  237 Days)`.
- **Select 1d preset.** Click `#btnRange1d` or navigate to `/?range=1d`.
  Verify the active window label updates to `1 of 237 Days`.
- **Verify scrubber handle drag.** In headless browser, dispatch mousedown on
  the left handle (`#brushLeftHandle`), mousemove by +100px, and mouseup.
  Verify the start date shifts forward and KPI cards recompute.
- **Verify scrubber window pan.** Dispatch mousedown on the window body
  (`.brush-window`), mousemove by -50px, and mouseup. Verify the date window
  shifts backward without changing window duration.
- **Verify persistence on drilldown.** With active window set to `14d`, click
  a directory in the breakdown table (e.g. `learning`). Verify the URL retains
  `range=14d` or explicit `start_date` and `end_date` without resetting to MAX.
- **Verify proof artifact.** Capture DOM snapshot and screenshot showing the
  active scrubber window at `/tmp/verify-jax-observatory/scrubber_active.png`.

## Gotchas

- **External Sliders Trap (`post-026209`):** Earlier versions placed HTML
  range input sliders below the scrubber. The board owner explicitly required
  moving the ends of the brush directly and sliding the box without external
  sliders.
- **Date Window Reset Regression (`post-026048`):** Clicking a drilldown row
  must NEVER reset the scrubber window back to default 30d or MAX. The active
  brush window must persist.
- **Missing Date Gaps Trap (`post-029068`):** Ensure the daily horizon series
  interpolates zero-job dates gracefully on the canvas sparkline rather than
  collapsing dates and causing visual chunking.
- **Single-Line Toolbar Rule (`post-028607`):** Time controls (`◀`, `▶`, preset
  buttons, and date pickers) must occupy exactly one line, never wrapping into
  two rows on desktop viewports.
