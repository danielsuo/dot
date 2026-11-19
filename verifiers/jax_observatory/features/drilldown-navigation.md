# Single Unified Drilldown Table

The drilldown table provides a single, high-density view for exploring fleet
compilation metrics hierarchically across Google3 directory paths, users, and
Borg jobs without page jitter or scroll jump.

## Sub-features

- `table-single-view`: Exactly one main table for drilldowns and group-bys.
- `table-row-limits`: Top 5, Top 10, Top 25, and All buttons (default: Top 10).
- `table-hierarchy-click`: Clicking a directory path drills into sub-paths.
- `table-zero-scroll-jump`: Preserves exact viewport scroll position on click.
- `table-stuck-prevention`: Fast (<1s) sub-query loads without freeze.
- `table-browser-history`: Browser Back (`history.back()`) restores path.

## How to get to it (user POV)

- Scroll down below the main chart to the `Fleet Breakdown` section.
- Click any directory link in the `Group` column (e.g. `learning/`).
- Click the parent breadcrumb or Back button to return to the parent path.
- Select `Top 5`, `Top 10`, `Top 25`, or `All` in the table header.

## Driving it with verify-jax-observatory

Preconditions:
- JAX Observatory is running and healthy on `http://127.0.0.1:8088`.
- Server is initialized with breakdown data.

- **Verify single table layout.** Check that only one `.breakdown-table` exists
  in the DOM. Multiple disconnected tables are prohibited.
- **Inspect default row limit.** Check that `Top 10` is selected by default in
  the table header (`#btnRows10` has active styling). The row limit selector
  must sit in the table header, NOT on the filter row.
- **Record initial scroll position.** In browser harness, scroll to the table
  (`window.scrollTo(0, 600)`), record `window.scrollY`.
- **Execute directory drilldown.** Click on the `learning` row link.
  Verify:
  1. `window.scrollY` remains stable (zero scroll jump down or up).
  2. The table updates to show subdirectories (e.g. `learning/gemini`,
     `learning/brain`).
  3. Omnibar displays active filter chip `path ^= learning/*`.
  4. Top KPI cards update to reflect the `learning` directory slice.
  5. The UI does not get stuck on "Refreshing..." or throw ReferenceErrors.
- **Verify browser Back button navigation.** Call `window.history.back()`.
  Verify:
  1. The path filter clears or returns to root.
  2. The table re-renders the root directory paths.
- **Verify proof artifact.** Capture screenshot of the drilled-down table at
  `/tmp/verify-jax-observatory/drilldown_learning.png`.

## Gotchas

- **Stuck Drilldown Defect (`post-028054`, `post-028144`, `post-028221`):**
  Clicking a path formerly caused the UI to stay stuck on "refreshing" when
  backend query prefixes or frontend response handlers mismatched. Always
  verify that clicking `learning` renders children within 1 second.
- **Scroll Jump Annoyance (`post-026039`, `post-026151`):** Clicking table
  rows must never trigger `window.scrollTo()` or anchor jumps that kick the
  user away from their scroll context.
- **Temporal Dead Zone (TDZ) ReferenceErrors (`post-031544`):** Ensure all
  drilldown variables (`structuredFilters`, `currentDrillPath`,
  `window.lastDrilldownRows`) are declared before any function invokes them.
- **Row Limit Placement (`post-028607`):** Row count buttons (`Top 10`, `All`)
  must remain positioned inside the table header toolbar, never in the filter
  omnibar.
