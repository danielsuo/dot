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

### 1B. Maintenance: Post-Landing Upkeep Loop (`maintain-verification-skill`)
- **Cadence (Every Landed PR / Mainline Merge)**: A feature map and verification harness rot as the codebase evolves. The maintenance upkeep loop MUST run whenever code merges into `main` (landed PR / merged change), NOT on intermediate exploratory WIP commits.
  1. **When Code Lands**: After a PR or feature branch is merged into `main`, invoke `maintain-verification-skill` (or `skills/maintain-verification-skill/SKILL.md`).
  2. **Harmonize the Suite**:
     - **Doc / Feature Map Drift**: Update `verify-<app>/features/` to reflect newly added capabilities, modified route contracts, and changed UI handles.
     - **Dead Scenario Pruning**: Remove verification recipes for deleted or deprecated features to prevent test rot.
     - **Regression Scenario Ingestion**: Convert user-reported bug fixes, repro steps, and conversational feedback into permanent verification recipes.
     - **Harness Calibration**: Execute a live pass across all features to guarantee zero false alarms and 100% pass rate.
  3. **Strict Edit Scope**: The maintenance pass ONLY updates the verification skill itself (its `SKILL.md`, `features/`, and harness scripts). It NEVER alters product code. Genuine product bugs discovered during maintenance must be reported as issues, never papered over by weakening verification assertions.

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
