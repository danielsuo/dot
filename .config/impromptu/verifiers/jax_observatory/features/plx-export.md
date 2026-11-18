# Prepopulated Plx Query & Parameterized Script Export

The JAX Fleet Compilation Observatory provides direct export and deep-linking
into Google-internal Plx Scripts2, enabling engineers to inspect, execute, and
fork parameterized GoogleSQL queries matching the active fleet view, date
window, drill-down paths, and filters without landing on a blank canvas.

## Sub-features

-   `plx-export-button`: Prominent `#btnOpenInPlx` icon button in the header
    toolbar.
-   `plx-parameterized-script`: Clean URL pointing to the official pre-created
    Plx script `dsuo.jax_fleet_compilation_observatory`.
-   `plx-url-parameters`: Dynamic URL hash parameters reflecting active
    dashboard filters (`START_DATE`, `END_DATE`, `PHASE_FILTER`, `PATH_PREFIX`,
    `BORG_USER`, `ACCELERATOR_TYPE`, `WORKLOAD_ROLE`).
-   `plx-clipboard-fallback`: Copies the full, verified GoogleSQL query to the
    clipboard on click as a fallback.
-   `api-sql-parity`: `/api/sql` generates valid, non-empty parameterized
    GoogleSQL queries with consistent schema.

## How to get to it (user POV)

-   Locate the green **Open in Plx** button (`#btnOpenInPlx`) in the top-right
    header toolbar (next to the Share View button).
-   Hover over the button to view the tooltip (*"Open pre-populated GoogleSQL
    query in Plx matching active filters, date window, and GroupBy"*).
-   Click the button:
    1.  A new browser tab opens pointing to
        `https://plx.corp.google.com/scripts2/dsuo.jax_fleet_compilation_observatory...`
        with populated parameters.
    2.  The full verified SQL query is copied to the user's system clipboard.
    3.  A temporary toast confirms: *"Opening Plx script (SQL copied to
        clipboard)!"*.

## Driving it with verify-jax-observatory

Preconditions:

-   JAX Observatory server is running and healthy on `http://127.0.0.1:8088`.

Verification Steps:

1.  **DOM Structure Assertion:**
    -   Assert `#btnOpenInPlx` element exists in the DOM.
    -   Assert `aria-label="Open in Plx"` attribute is present for
        accessibility.
    -   Assert the `href` attribute is non-empty and starts with
        `https://plx.corp.google.com/scripts2/dsuo.jax_fleet_compilation_observatory`.
    -   Assert the `href` does NOT point to an empty scratchpad (`scripts2/new`
        without query).
2.  **Dynamic Filter Synchronization:**
    -   Change the active date window (e.g. 7 days or custom range).
    -   Apply a phase filter (e.g. `phase:BACKEND_COMPILE`) or path drilldown.
    -   Verify that `#btnOpenInPlx.href` dynamically updates to include
        `?p=START_DATE%3A...`, `,END_DATE%3A...`, and `,PHASE_FILTER%3A...`.
3.  **API SQL Generation Verification:**
    -   Send `GET /api/sql?range=7d` and `GET /api/query?range=7d`.
    -   Assert response status is `ok`.
    -   Assert `f1_sql` (or `sql`) field is non-empty, contains
        `xmanager_tracer_alphabet_jobs.jax_compilation_metrics_with_xm_data_per_wid.all`,
        and includes valid `_PARTITION_DATE` clauses.
4.  **Click Simulation:**
    -   In headless Chrome, trigger a click on `#btnOpenInPlx` or evaluate
        `buildPlxScriptUrl()`.
    -   Assert target URL resolves cleanly to the parameterized Plx script.
    -   Assert no JavaScript exceptions or broken redirect loops occur.

## Gotchas

-   **Empty Scratchpad Trap (`post-034188`):** Previously, the button opened
    `plx.corp.google.com/scripts2/new?engine=f1` which displayed an empty editor
    canvas without SQL. The link must point directly to the shared parameterized
    script `dsuo.jax_fleet_compilation_observatory`.
-   **Cross-Origin PostMessage Fragility:** Attempting to inject SQL via
    `window.postMessage` to cross-origin Plx tabs fails silently due to browser
    security policies. Rely on URL parameters + clipboard copy.
-   **SQL Drawer Deprecation (`cl/1016083601`):** In-page SQL drawer was purged
    to streamline UI. Do not resurrect `#sqlDrawer` or `#sqlBox`.
