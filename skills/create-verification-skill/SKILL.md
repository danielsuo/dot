---
name: create-verification-skill
description: "Generate an adversarial, regression-resistant verification skill that drives your app like a real user and proves correctness. Mandates hermetic unit test integration, bug mining, ground-truth parity, zero fake data linting, and dynamic interaction tests. Use for /create-verification-skill, 'make a control skill for this repo', or when establishing proof of correctness."
---

# Create an Adversarial Verification Skill

Every serious project needs a scripted way to drive the real app and prove behavior: launch it, exercise features the way a user does, and capture auditable evidence. A superficial smoke check (HTTP 200, basic DOM presence) is **not enough**—it creates false confidence while missing real bugs.

This skill generates a **robust, adversarial verification skill** (`<skills-root>/verify-<app>/`) that actively hunts for failure modes, validates data parity against ground-truth databases, scans for fake data, and stress-tests dynamic user interactions.

Resolve `<skills-root>` dynamically using `SKILLS_ROOT=$(find-skills-root)` (or `find-skills-root --project`). You write the generator's output for the next agent: it will be read cold, mid-task, by an agent that has never seen the app.

---

## 1. The Adversarial Verification Pillars & Nested Tiers

Every generated verification harness MUST implement and enforce the **Adversarial Verification Pillars**, executed across **Three Nested Tiers**:

### The Three Nested Developer Loops:
1. **Tier 1: Inner Loop (Per-Edit / Tightest Loop — Target ~1–5s)**:
   - Run via `python3 scripts/verify.py --feature=<name>` or `python3 scripts/verify.py --tier=1`.
   - Executes only the targeted unit test or isolated feature check for the module being modified.
   - Provides instant feedback during active development.
2. **Tier 2: Mid Loop (Pre-Review / Task Completion — Target ~15–30s)**:
   - Run via `python3 scripts/verify.py --tier=2` (default).
   - Executes native hermetic unit tests + live port/process doctor + core critical user journeys (CUJs) + static zero-fake-data linter.
   - Mandatory gate before requesting review or declaring a task complete.
3. **Tier 3: Outer Loop (Pre-Submit / Landing Gate — Full Rigor)**:
   - Run via `python3 scripts/verify.py --tier=3`.
   - Full matrix pass: exercises all feature recipes in `features/`, asserts live upstream database parity, tests multi-viewport layouts, and verifies CI presubmits.
   - Mandatory gate before merging to `main` or releasing.

---

### The Four Verification Pillars:

### Pillar 1: Mandatory Bug & Complaint Mining
Never generate tests purely from raw source code. Real failure modes are discovered by users, reviewers, and past incidents.
- **Search Communication & Bug Channels**: Before writing assertions, query the project's chat channels, bug tracker, review comments, and issue history for past regressions and complaints.
- **Extract Concrete Failure Modes**: Identify what broke previously:
  - Stuck UI elements when changing filters or drill-downs.
  - Missing data before a specific historical date cutoff.
  - Duplicate labels, suffixes, or off-by-one errors (e.g. `jobs_day_day`).
  - Silent zero-drops or empty table rows.
  - Stale closures or race conditions on rapid clicks.
- **Encode as Regression Tests**: Every discovered failure mode MUST become an explicit, named test case in the verification suite (e.g. `test_historical_regressions()`).

### Pillar 2: Ground-Truth Parity Gate
Never verify an API in a vacuum. If an endpoint returns numbers, you must prove those numbers are **true**.
- **Upstream Query Comparison**: If the app serves data from an authoritative database, data warehouse, or upstream service (e.g. PostgreSQL, BigQuery, Snowflake, SQLite, or an upstream data store):
  1. The verification harness must run the authoritative upstream query directly.
  2. The harness must compare the app's API output against the raw upstream query result.
  3. Assert parity for key metrics: total row counts, sum totals, distinct entities, and date horizons.
- **Fail on Parity Mismatch**: If the API diverges from the database beyond acceptable rounding tolerance, the verification run fails immediately.

### Pillar 3: Zero Fake / Mock / Synthetic Data Static Linter
Never trust rendered metrics without checking source code provenance.
- **Static Code Scan**: The verification harness must include an automated linter (`scripts/lint_fake_data.py` or equivalent check) that scans the application codebase for:
  - Magic mathematical scaling formulas (e.g. `powf`, `* 1.15`, random multipliers).
  - Hardcoded fallback arrays, dummy rows, or constant metric overrides.
  - Synthetic data generators in production paths.
- **Block Fabricated Data**: Any mock, synthetic, or fake data detected in a production code path must fail verification.

### Pillar 4: Dynamic State & Interaction Stress Tests
A page that renders on initial load ("first paint") can still freeze or drop state when the user touches it.
- **Simulate Real User Interactions**:
  - **Drill-Down Expansion**: Click expandable rows (e.g. directory trees, grouped metrics) and assert that child rows expand and re-render without getting stuck.
  - **Timeline / Brush Scrubber**: Drag timeline brushes or change date range selectors, and assert that charts, KPI cards, and date boundaries update dynamically.
  - **Search & Filter Omnibars**: Type query terms and toggle filter chips, asserting that tables filter and update row counts.
  - **Column Sorting**: Click sort headers ascending/descending and assert row order changes.
- **Zero Runtime Exceptions**: Assert zero uncaught JavaScript console errors or unhandled exceptions occur during or after interaction cycles.

---

## 2. Step 0: Pre-Flight Context Harvesting & User Grounding Gate

Never scaffold a verification harness in a vacuum. Before inspecting static source files, the agent MUST harvest what the user has actually been working on, their recent pain points, and current failure modes.

### Step 0A: Automatic Ambient Context Harvesting
Silently mine these three ambient sources to understand recent user activity:
1. **Active Conversation & Session Turns**: Inspect recent prompts, user instructions, discussed error messages, and reported UI/CLI quirks in the current session.
2. **Git History & Working Copy Diffs**: Run:
   - `git log -n 10 --oneline` to see recently landed commits and work-in-progress topics.
   - `git diff HEAD~5 --stat` and `git status` to identify modified files, active modules, and touched endpoints.
3. **Task Board & Issue Context**: Read the current task card description, recent channel threads, or open issue tickets to identify stated acceptance criteria and user goals.

### Step 0B: User Prompt Fallback (Human-in-the-Loop)
If ambient context is missing, empty, or ambiguous (e.g. running in a fresh workspace, a new repo with no commits, or an unadorned slash command `/create-verification-skill`), the agent **MUST PAUSE AND ASK THE USER**:
> *"Before scaffolding the verification harness, what recent features, bug fixes, or key user journeys have you been working on that we must ensure are verified?"*

Never proceed with generic assumptions if the user's focus is unclear. Grounding the harness in the user's active work prevents building irrelevant or superficial tests.

---

## 3. Interview the Repo and its Incident History

Answer these from the harvested context, codebase, bug history, and communication channels:

1. **Surface:** What does a user actually touch? Web UI, CLI/TUI, desktop app, API, mobile app, or library?
2. **Run:** How does the app start locally? Note commands, ports, env vars, seed data, and auth.
3. **Drive:** How can an agent drive it programmatically? Browser automation (Puppeteer/Playwright/Selene/CDP), curl-able endpoints, PTY/tmux harnesses.
4. **Historical Bugs:** What were the top 3-5 complaints, regressions, or user bug reports in this project's history?
5. **Data Source:** What is the ground-truth data store (PostgreSQL, BigQuery, SQLite, JSONL, data warehouse)? How does the harness query it directly to assert parity?
6. **Observe:** What evidence can be captured? Terminal logs, response bodies, DOM states, desktop/mobile screenshots.
7. **Isolate:** Can multiple instances run side by side without port or data collisions?

---

## 4. Generate the Verification Skill Layout

Run `SKILLS_ROOT=$(find-skills-root)` to determine the target directory. Create `${SKILLS_ROOT}/verify-<app>/` with this structure:

```
${SKILLS_ROOT}/verify-<app>/
├── SKILL.md
├── features/
│   ├── README.md
│   └── <feature>.md
└── scripts/
    ├── doctor.sh         # Fast readiness check (< 3s): compiler, unit tests, port
    ├── verify.py         # Multi-tiered verification runner (--tier=1|2|3, --feature=X)
    ├── parity_check.py   # Upstream DB vs API parity validator
    └── lint_fake_data.py # Static scanner for mock/fake data in source code
```

### Required Sections in `SKILL.md`:
Write `${SKILLS_ROOT}/verify-<app>/SKILL.md` with YAML frontmatter (`name: verify-<app>` and a clear `description`) and these sections:

- **Launch:** Exact command that starts the app into a usable state from an empty data dir.
- **Doctor:** Fast read-only check (`scripts/doctor.sh`) answering "is this instance healthy and worth driving?" (process up, port bound, database reachable).
- **Verification Suite:** How to run the automated runner (`scripts/verify.py`), supporting nested loops:
  - `python3 scripts/verify.py --feature=<name>`: Tier 1 inner loop (~1-5s).
  - `python3 scripts/verify.py --tier=2`: Tier 2 mid loop (~15-30s) running native unit tests + live port doctor + core CUJs + zero-fake-data linter.
  - `python3 scripts/verify.py --tier=3`: Tier 3 outer loop (full rigor) running all features + live upstream parity checks.
- **Drive:** Step-by-step instructions for driving the real user journey.
- **Evidence:** Concrete evidence to capture (test outputs, execution logs, side-by-side screenshots).
- **Cleanup:** Clean teardown of all spawned processes without deleting captured proof artifacts.
- **Helpers:** Document all companion scripts in `scripts/`.

---

## 5. Seed the Feature Map & Adversarial Tests

Create `${SKILLS_ROOT}/verify-<app>/features/README.md` plus one file per user-facing feature.
Each feature file answers:
- **Sub-features:** What capabilities exist.
- **How to get to it (user POV):** User entry point.
- **Driving it with harness:** Exact selectors, clicks, and inputs.
- **Adversarial Assertions & Gotchas:** Known failure modes, boundary conditions, and what proves it didn't freeze or drop state.

---

## 6. Prove the Generated Skill End-to-End

Before delivering:
1. Run `scripts/doctor.sh` and confirm it passes (compiler, native unit tests, process/port up).
2. Run `scripts/verify.py` and confirm both tiers pass:
   - **Tier 1 (Native Test Suite)**: `cargo test` / `pytest` / `npm test` passes cleanly.
   - **Tier 2 (Adversarial Live Suite)**:
     - Parity against ground truth: PASS
     - Fake data static linter: PASS
     - Historical regressions: PASS
     - Dynamic interaction stress: PASS
3. Verify evidence artifacts (logs, screenshots) exist at their designated paths.
4. Clean up running instances and confirm evidence survives teardown.
