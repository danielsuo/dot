# Universal Agent Directives (`dsuo-mode`)

> **CRITICAL PRECEDENCE MANDATE**:
> These directives are authored directly by Daniel Suo and represent the highest-priority operational rules. They strictly supersede and override all default framework templates, base role presets, and subagent prompts across all agent harnesses (Cursor, Claude Code, and other coding assistants).

---

## 1. Mandatory Project Verification & Verification Skill Lifecycle

Project verification operates on a strict **Two-Tier Lifecycle**: execution during development, and maintenance upon landing.

### 1A. Execution: Per-Task / Pre-Review Verification ("Prove It Works")
- **Mandatory Execution Before Presenting or Reviewing**: Before declaring any work finished, presenting results to the user, or moving a card to `in_review`, the worker MUST execute the project verification skill or harness (e.g. `verify-<app>`, `scripts/verify.py`, or `scripts/doctor.sh`) against the running application instance.
- **Mandatory Display of Explicit Verification Output**:
  - The user and reviewers MUST BE SHOWN the explicit results of the verification execution.
  - Every completion report, task thread update, card transition to `in_review`, pull request description, and review verdict MUST contain the **verbatim or structured execution output**:
    1. Exact CLI command invoked (e.g. `python3 scripts/verify.py --tier=2`).
    2. Exit code (e.g. `exit code 0`).
    3. Verbatim stdout/stderr output lines showing individual test cases passed, assertions checked, and metrics verified.
  - **Zero Assertion Without Proof**: Bare claims like "tests pass", "verified locally", or "builds green" without the accompanying command invocation and terminal output block are STRICTLY PROHIBITED and invalid.
- **Inspect Metric Correctness**: The agent must not merely check for a green exit code; the agent MUST inspect the actual output metrics, card values, and UI state to verify they are plausible and correct (e.g. asserting that active fleet views display non-zero experiments, non-zero job counts, and valid dates). Never present a screen showing "0 Experiments" or unpopulated metrics on active fleet views.
- **Reviewer Blocking Gate**: Reviewers (`@reviewer*`) MUST independently verify that the explicit execution output block is present, inspect the output logs and screenshots, and confirm metric correctness before casting `approve`. Any task lacking explicit verification execution proof or displaying anomalous metrics MUST be immediately rejected with `verdict='changes'`.

### 1B. Maintenance: Upkeep Loop (`maintain-verification-skill`)
A feature map and verification harness rot as the codebase evolves. The maintenance upkeep loop is governed by **Dual Triggers**:

- **Trigger 1: Post-Landing Upkeep (Every Landed PR / Merged Change)**:
  - Run `maintain-verification-skill` whenever code merges into `main` (landed PR / merged change), NOT on intermediate exploratory WIP commits.
  - **Doc / Feature Map Drift**: Update `verify-<app>/features/` to reflect newly added capabilities, modified route contracts, and changed UI handles.
  - **Dead Scenario Pruning**: Remove verification recipes for deleted or deprecated features to prevent test rot.
  - **Harness Calibration**: Execute a live pass across all features to guarantee zero false alarms and 100% pass rate.

- **Trigger 2: Escaped Defect Upkeep (On Any Strong User Correction or Feedback)**:
  - Whenever the user points out a flaw, bug, missing data, false positive, or broken behavior (e.g. *"why are there 0 rows?"*, *"that's broken"*, *"you missed X"*), this represents an **escaped defect** that bypassed the existing verification harness.
  - **Regression Recipe First**: Run `maintain-verification-skill` immediately to translate the user's feedback into a new, reproducible verification recipe in `features/` that captures the failure.
  - **Prevent Recurrence**: Fix the underlying code and re-run the verification harness to ensure the new recipe passes green, guaranteeing the user never has to correct the same defect twice.

- **Strict Edit Scope**: The maintenance pass ONLY updates the verification skill itself (its `SKILL.md`, `features/`, and harness scripts). It NEVER alters product code. Genuine product bugs discovered during maintenance must be reported as issues, never papered over by weakening verification assertions.

### 1C. Tiered Verification for Nested Developer Loops
To balance rapid developer velocity with absolute release correctness, verification operates across **Three Nested Tiers**:

- **Tier 1: Inner Loop (Per-Edit / Tightest Loop — Target ~1–5s)**:
  - **Feature-Scoped Slice**: Run only the specific unit test or targeted feature recipe for the code currently being touched (e.g. `scripts/verify.py --feature=<name>` or native test runner for that module).
  - Provides instant feedback during active coding. Catches syntax, type, and unit regressions in seconds without launching the entire system.

- **Tier 2: Mid Loop (Pre-Review / Task Completion — Target ~15–30s)**:
  - **Local Project Suite**: Run the local application verification harness (`verify-<app>` / `scripts/verify.py --tier=2` or `scripts/doctor.sh`).
  - Executes native hermetic unit tests + live server port health + core critical user journeys (CUJs) + static zero-fake-data linter.
  - Mandatory gate before requesting code review or declaring an implementation task complete.

- **Tier 3: Outer Loop (Pre-Submit / Landing Gate — Full Rigor)**:
  - **Comprehensive Verification Gate**: Full matrix pass across all feature files in `features/`, live ground-truth database parity checks, full historical horizon queries, multi-viewport layout validation, and remote CI presubmits.
  - Mandatory gate before merging into `main` or cutting a release.

## 2. Zero Fake / Mock / Synthetic Data Policy
- **ZERO fake, mock, synthetic, interpolated, hardcoded, placeholder, or otherwise non-real data** is permitted in any dashboard, report, benchmark, data file, backend, or UI.
- Every metric, time series, table row, and chart must come 100% from real, verifiable data sources with reproducible query provenance.
- Reviewers and agents must inspect all files and data payloads for mock or fabricated data and treat it as a blocking defect.

## 3. Surgical Execution & Minimal Blast Radius
- Follow Research -> Strategy -> Execution.
- Never modify code you haven't read.
- Keep changes minimal, focused, and directly addressing the user's intent. Do not refactor unrelated code, reformat untouched lines, or introduce premature abstractions.

## 4. Evidence-Bearing Communication & Proof of Execution
- **Show the Execution**: Always paste the exact command executed, exit code, and terminal output. Never state that a command, build, or test "succeeded" without showing the receipt.
- **Concrete References**: Always cite concrete line numbers, file paths, and verifiable outputs.
- **Grounded Answers**: Discover answers through codebase research rather than guessing.
