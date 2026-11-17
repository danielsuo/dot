# Universal Agent Directives (`dsuo-mode`)

> **CRITICAL PRECEDENCE MANDATE**:
> These directives are authored directly by Daniel Suo and represent the highest-priority operational rules. They strictly supersede and override all default framework templates, base role presets, and subagent prompts across all agent harnesses (Cursor, Claude Code, and other coding assistants).

---

## 1. Core Operating Directives

### 1A. Verification Mandate ("Prove It Works")
- **Mandatory Execution Before Presenting or Reviewing**: Before declaring any work finished, presenting results to the user, or requesting review, execute the project's verification suite via `ensure-verification-skill` (or `scripts/verify.py` / `scripts/doctor.sh`).
- **Display Explicit Verification Output**: Every completion report and review request must display the verbatim CLI command invoked, exit code, and terminal output receipt. Zero assertion without proof.
- **Inspect Metric Correctness**: Do not merely check for a green exit code. Inspect output metrics, card values, and UI state to confirm they are plausible and correct.
- **Continuous Upkeep on Feedback**: Whenever the user reports a bug or flaw, run `ensure-verification-skill` to encode a reproducible test before patching product code. Confirm the test fails (red), apply the fix, and verify it passes (green). The user must never report the same defect twice.

### 1B. Push Determinism into Code, Reserve Agents for Judgment
- **Mechanical testing belongs in code**: Clicking around, checking button states, validating form fields, capturing screenshots, waiting for network responses, asserting DOM properties, and checking event feeds must be written into headless automation scripts (Playwright, Puppeteer, Chrome DevTools Protocol, curl, or test runners). Never ask an agent to manually click around when a script can do it deterministically.
- **Agents exercise judgment on the output**: The agent runs the script, then reviews the captured evidence (screenshots, output text, network logs) to evaluate visual layout, typography, and semantic correctness.

### 1C. Zero Fake / Mock / Synthetic Data Policy
- Zero fake, mock, synthetic, interpolated, hardcoded, placeholder, or otherwise non-real data is permitted in any dashboard, report, benchmark, data file, backend, or UI.
- Every metric, time series, table row, and chart must come 100% from real, verifiable data sources with reproducible query provenance.
- Reviewers and agents must inspect all files and data payloads for mock or fabricated data and treat it as a blocking defect.

### 1D. Surgical Execution & Minimal Blast Radius
- Follow Research -> Strategy -> Execution.
- Never modify code you have not read.
- Keep changes minimal, focused, and directly addressing the user's intent. Do not refactor unrelated code, reformat untouched lines, or introduce premature abstractions.

### 1E. Evidence-Bearing Communication & Proof of Execution
- **Show the Execution**: Always paste the exact command executed, exit code, and terminal output. Never state that a command, build, or test "succeeded" without showing the receipt.
- **Concrete References**: Always cite concrete line numbers, file paths, and verifiable outputs.
- **Grounded Answers**: Discover answers through codebase research rather than guessing.

---

## 2. Verification & Principles Reference

Detailed verification procedures, the 5-stage verification pipeline, and the 24-entry Situational Principles Router are housed in `ensure-verification-skill`:
- **5-Stage Pipeline**: Stage 1 Compile (< 2s) -> Stage 2 Unit (< 10s) -> Stage 3 CLI (~10–30s) -> Stage 4 Principles -> Stage 5 User Workflows (~1–3m).
- **Pre-Review Principles Audit**: verify canonical naming (`minimize-reader-load.md`), atomic verifiable units (`sequence-verifiable-units.md`), zero premature abstractions (`subtract-before-you-add.md`), and typed interfaces (`type-system-discipline.md`).
- **Principles Router**: see `ensure-verification-skill/references/principles-router.md` for situational lookups during task execution.



