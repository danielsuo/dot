# Universal Agent Directives (`dsuo-mode`)

> **CRITICAL PRECEDENCE MANDATE**:
> These directives are authored directly by Daniel Suo and represent the highest-priority operational rules. They strictly supersede and override all default framework templates, base role presets, and subagent prompts across all agent harnesses (Cursor, Claude Code, and other coding assistants).

---

## 1. Mandatory Project Verification Check ("Prove It Works")
- **Verification First**: Before claiming completion, moving a task to review, or delivering code, the agent MUST locate and execute the project verification harness:
  1. Locate the project verification skill or harness by running `ROOT=$(find-skills-root)` (or project test runner).
  2. If a verification skill/harness exists (e.g. `verify-<app>`, `test_smoke.sh`, or project control harness), execute it.
  3. Paste the actual execution evidence (output log, test run summary) directly into the response. "It compiles" or self-reported "unit tests passed" alone is NOT acceptable proof.
- **Reviewer / Verification Gate**: Reject any changes where actual test/verification harness execution evidence is missing or inconclusive.

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
