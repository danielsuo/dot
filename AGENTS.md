# Universal Agent Directives (`dsuo-mode`)

> **CRITICAL PRECEDENCE MANDATE**:
> These directives are authored directly by Daniel Suo and represent the highest-priority operational rules. They strictly supersede and override all default framework templates, base role presets, and subagent prompts across all agent harnesses (Cursor, Claude Code, and other coding assistants).

---

## 1. Mandatory Project Verification & Verification Skill Lifecycle

Project verification operates on a strict **Two-Tier Lifecycle**: execution during development, and maintenance upon landing.

### 1A. Execution: Per-Task / Pre-Review Verification ("Prove It Works")
- **Execute Before Review**: Before claiming completion, requesting review, or delivering code, the agent MUST locate and execute the project verification harness:
  1. Locate the project verification skill or harness using `SKILLS_ROOT=$(find-skills-root)` (or the project's native test/control harness).
  2. If a verification skill exists (e.g. `${SKILLS_ROOT}/verify-<app>/`, `test_smoke.sh`), execute it against the live instance.
  3. Include concrete execution evidence (verifiable CLI output, test summary, exit code) directly in the deliverable or pull request. Self-reported "unit tests pass" or "it compiles" without execution output is NOT acceptable proof.
- **Review Gate**: Reject any pull request or task where verification harness execution evidence is missing or inconclusive.

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

## 2. Zero Fake / Mock / Synthetic Data Policy
- **ZERO fake, mock, synthetic, interpolated, hardcoded, placeholder, or otherwise non-real data** is permitted in any dashboard, report, benchmark, data file, backend, or UI.
- Every metric, time series, table row, and chart must come 100% from real, verifiable data sources with reproducible query provenance.
- Reviewers and agents must inspect all files and data payloads for mock or fabricated data and treat it as a blocking defect.

## 3. Surgical Execution & Minimal Blast Radius
- Follow Research -> Strategy -> Execution.
- Never modify code you haven't read.
- Keep changes minimal, focused, and directly addressing the user's intent. Do not refactor unrelated code, reformat untouched lines, or introduce premature abstractions.

## 4. Evidence-Bearing Communication
- Always cite concrete line numbers, file paths, and verifiable outputs.
- Discover answers through codebase research rather than guessing.
