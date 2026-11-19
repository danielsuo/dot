# JAX Observatory Verification Map

This directory is the maintained source for verifying user-facing behavior of
the JAX Fleet Compilation Observatory
([`observatory/`](http://google3/experimental/users/dsuo/jax/observatory/)).
Read the index before driving the app, then use the matching feature file as
the verification recipe.

## Baseline Preconditions

- Launch JAX Observatory on an isolated local port (e.g. `http://127.0.0.1:8088`
  or `18088`) via
  [`server`](http://google3/experimental/users/dsuo/jax/observatory/BUILD;l=43).
- Ensure the server is connected to daily SQLite shards in
  `/cns/iz-d/home/dsuo/jax_fleet_observatory/daily/` (or test directory with
  `--db_dir`).
- Run [`doctor.sh`](http://google3/experimental/users/dsuo/verifiers/jax_observatory/doctor.sh)
  and require HTTP 200 on `/api/health`, active total rows, and zero obsolete
  banner artifacts.
- Never drive an instance not started or verified by this verification run.

## Driving Conventions

- Start every recipe from baseline (`http://127.0.0.1:8088/?range=30d`)
  unless preconditions specify otherwise.
- Drive browser interactions via headless Chrome or Selene Browser.
- Drive API endpoints via standard HTTP GET/POST queries (`/api/query`,
  `/api/sql`, `/api/health`).
- Validate zero JavaScript console exceptions (`window.onerror`,
  `ReferenceError`, `TypeError`, `Uncaught`) on every page load.
- Ensure all proof artifacts (screenshots, DOM dumps, JSON logs) survive
  cleanup and are stored in `/tmp/verify-jax-observatory/`.

## Proof and Skip Reporting

- Capture the user action and the resulting state, not only the final screen.
- UI proof includes desktop screenshot (1440x900) and mobile screenshot
  (375x812) with the dashboard header and KPI cards visible.
- API proof includes HTTP status code, `total_db_rows`, `matched_rows`,
  `matched_experiments`, and slice counts.
- Report unreachable paths with attempted command and unmet precondition.
- Never report a skipped entry point as verified through a different path.

## Feature Entry Contract

Each feature file describes user-visible behavior with exactly four H2 sections:
1. `Sub-features`: Lists short IDs with one line per behavior.
2. `How to get to it (user POV)`: Lists every entry point from the UI or URL.
3. `Driving it with <harness>`: Starts with `Preconditions:` and uses labeled
   bullets pairing each action with an exact command and observable result.
4. `Gotchas`: Traps, historical failure modes, and regression guards from
   channel history.

## Features

- [Top KPI Summary Cards](./kpi-cards.md) covers the 6-column top metric row,
  clean Borg Jobs formatting, distinct XM experiments, and reactive updates.
- [Timeline Scrubber & Time Range](./timeline-scrubber.md) covers 1d to MAX
  (237-day) presets, brush handle drag, timeline pan, and date persistence.
- [Single Unified Drilldown Table](./drilldown-navigation.md) covers directory
  drilling, sub-path expansion, zero scroll jump, row count options, and
  browser history back navigation.
- [Omnibar Query & Filter Controls](./query-controls.md) covers filter chips,
  single-line query layout, plot type/axis dropdowns, and PLX export.
- [Data Accuracy & Source Attribution](./data-accuracy-and-sources.md) covers
  the zero fake data policy, worker vs controller task attribution, and
  authoritative F1/PLX SQL generation.

