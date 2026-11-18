# Data Accuracy & Source Attribution

JAX Observatory enforces strict, reproducible data provenance: all telemetry
derives directly from real production logs and SQLite shards. Zero fake, mock,
or synthetic data is permitted.

## Sub-features

- `data-zero-fake`: 100% real production telemetry; zero mock or synthetic data.
- `data-f1-ground-truth`: Exact parity with live F1 queries across all time windows.
- `data-task-attribution`: Worker tasks only; controller tasks excluded.
- `data-overlap-handling`: Correct chip attribution during multi-task overlaps.
- `data-zero-chip`: Zero-chip waiting jobs excluded from accelerator waste.
- `data-plx-source-of-truth`: Authoritative SQL generation linking to live PLX.
- `data-security-hygiene`: Banned file issue endpoints and modals removed.

## How to get to it (user POV)

- Click the `Open in Plx` button (`#btnOpenInPlx`) in the top navigation bar.
- Click the `Shard Integrity` badge (`#dataValidationBadge`) to inspect health.
- Click the `Info` button (`#btnHeaderInfo`) to inspect database path.

## Driving it with verify-jax-observatory

Preconditions:
- JAX Observatory is running and healthy on `http://127.0.0.1:8088`.

- **Live F1 Parity Check.** Run `python3 imp/verify.py`.
  Verify Suite 1 completes with 100% pass:
  1. Live F1 query against upstream partition matches `/api/query` daily XID metrics.
  2. Distinct experiments match F1 ground truth across MAX (12,270,364) and 30d (3,077,770).
  3. Filtered queries (e.g. `is_restart = "true"`) reflect exact sample-scaled distinct XIDs.
- **Audit source files for fake data.** Scan
  [`server.rs`](http://google3/experimental/users/dsuo/jax/observatory/src/server.rs),
  [`query_engine.rs`](http://google3/experimental/users/dsuo/jax/observatory/src/query_engine.rs),
  and [`lib.rs`](http://google3/experimental/users/dsuo/jax/observatory/src/lib.rs)
  for heuristic constants or mock data. Must return 0 occurrences.
- **Inspect /api/sql output.** Run:
  `curl -s "http://127.0.0.1:8088/api/sql?range=30d"`.
  Verify:
  1. `status` is `ok`.
  2. `f1_sql` is valid GoogleSQL containing
     `SELECT _PARTITION_DATE AS log_date`.
  3. Query includes 24h capacity bounds and filters out non-worker tasks.
- **Verify Open in Plx link generation.** Inspect `#btnOpenInPlx` in the DOM.
  Verify:
  1. `href` points to `https://plx.corp.google.com/scripts2/new?engine=f1...`.
  2. URL parameters contain `title` and encoded `sql` matching current view.
  3. Uses standard square icon button without bulky text.
- **Verify removal of file issue button.** Query DOM for `#fileIssueBtn` or
  `#fixIssueBtn`. Must NOT exist.
- **Inspect telemetry provenance.** Click `#btnHeaderInfo`. Verify the popover
  reports live database source
  `/cns/iz-d/home/dsuo/jax_fleet_observatory/daily/` and UTC watermark.

## Gotchas

- **Mandatory Zero Fake Data Policy (`post-026066`, `post-031630`):**
  The board owner explicitly mandated: "Make sure the reviewer ALWAYS FLAGS and
  ALWAYS DEMANDS removal of fake, mock, cheat, or otherwise non real data."
  Any heuristic scaling curves, hardcoded anchors, or mock datasets are
  blocking P0 defects.
- **Single Plx Button Rule (`post-027797`, `post-027823`):**
  Never build internal SQL query execution workbenches inside the dashboard.
  The official source of truth is PLX; the dashboard must provide a single
  button popping out to a pre-populated PLX script.
- **Security-Risk Button Removal (`post-029137`, `post-029176`):**
  The "file issue to beekeeper" button was removed as a security risk. Neither
  the frontend button nor any backend `/api/file_issue` handler may exist.
- **Controller Chip Attribution Distortion:** Controllers and directors don't
  hold accelerator chips; attributing accelerator idle time to controller tasks
  causes massive overcounting. Only tasks holding physical chips count.
