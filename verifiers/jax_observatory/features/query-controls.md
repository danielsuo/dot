# Omnibar Query & Filter Controls

The omnibar query controls provide a Monarch-like query interface allowing
dynamic multi-attribute filtering, grouping, and plot configuration on a clean,
single-line surface.

## Sub-features

- `omnibar-single-line`: Query input and filter tags occupy a single line.
- `omnibar-filter-chips`: Interactive removable chips (`path ^= ...`, `by:...`).
- `omnibar-freeform-input`: Type-ahead suggestions for users and paths.
- `plot-single-line-toolbar`: Single-line plot controls (Type, X, Y, By).
- `query-status-indicator`: Live execution spinner (`Running query…`) and completion timestamp (`⚡ Loaded in Xms`).
- `plot-clean-title`: 1-line plot title without confusing color chip widgets.
- `plot-download`: Direct export of chart data.

## How to get to it (user POV)

- Locate the `Query, Filter & Group-By Controls` box directly beneath KPI cards.
- Click into the input field or click an existing filter chip's `×` to remove.
- Type a query expression (e.g. `path ^= google3/learning/*` or `user:dsuo`).
- In the chart card header, select chart type (Stacked Bar, Line, Heatmap),
  X-axis (Date, User, Path), Y-axis (RoT, Idle Time, Overhead), or Group-by.

## Driving it with verify-jax-observatory

Preconditions:
- JAX Observatory is running and healthy on `http://127.0.0.1:8088`.

- **Inspect omnibar layout.** Verify `#queryOmnibarWrap` uses single-line flex
  layout on desktop. The query input must NOT wrap below filter chips unless
  the chips exceed container width.
- **Inspect active filter chips.** Verify default chips exist:
  `path ^= learning/*` and `⚡ source_path`.
- **Remove a filter chip.** In headless browser, click the `×` on
  `path ^= learning/*`. Verify the filter chip disappears, URL updates, and the
  query re-runs for the root fleet.
- **Inspect plot toolbar.** Verify the chart controls container
  (`.plot-controls-toolbar`) occupies a single horizontal row on desktop.
- **Inspect chart title.** Verify `.chart-title` occupies exactly one line and
  contains no extraneous color chips or badges under the heading.
- **Verify query status & latency indicator.** Verify `#queryStatusIndicator`
  and `#queryLoadingIndicator` are present in the query control bar and `#timelineLoadingBadge`
  is in the timeline header. Trigger a query reload or date range change (e.g. `setDateRangePreset('7d')`).
  Assert `#queryStatusIndicator` enters the `.running` state with spinning dot and text "Running query…".
  Upon query resolution, assert `#queryStatusIndicator` enters `.success` state with green check dot,
  displaying `⚡ Loaded in <dt>ms · <timestamp>` execution latency.
- **Change chart metric.** Select `Attached Idle Accelerator Time` from Y-axis
  dropdown. Verify the chart Y-axis re-scales and legend re-renders.
- **Verify proof artifact.** Capture screenshot of the omnibar and plot controls
  at `/tmp/verify-jax-observatory/query_controls.png`.

## Gotchas

- **Split Query Box Trap (`post-028644`):** The query box and type box were
  previously split onto two rows. The board owner explicitly mandated: "Make
  query and the type box one line not split."
- **Plot Toolbar Wrapping (`post-028719`):** Dropdowns for Type, X, Y, and By
  must remain consolidated into a single row on desktop viewports.
- **Confusing Color Chip Trap (`post-029137`):** Earlier versions placed a
  colored pill/chip directly under the plot title. The board owner directed:
  "let's also get rid of the color chip right under the title which I don't
  think I know what corresponds to."
- **Plot Title Wrapping (`post-029137`):** Keep plot title concise and on one
  line (e.g. `RoT Opportunity Cost by Date · Phase · learning`).
