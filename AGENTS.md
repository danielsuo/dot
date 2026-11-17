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
- **Push Determinism into Code, Reserve Agents for Judgment**:
  Automate mechanical execution with deterministic code; reserve the agent for subjective evaluation and judgment.
  - **Mechanical testing belongs in code**: Clicking around, checking button states, validating form fields, capturing screenshots, waiting for network responses, asserting DOM properties, and checking event feeds must be written into headless automation scripts (such as Playwright, Puppeteer, Chrome DevTools Protocol, curl, or test runners). Never ask an agent to manually click around when a script can do it deterministically.
  - **Agents exercise judgment on the output**: The agent runs the script, then reviews the captured evidence:
    1. Visual layout and typography: does the interface look clean and well-proportioned? Is there text truncation, misalignment, or badge overlap?
    2. Semantic plausibility: are the values, counts, and response texts correct and meaningful in domain context?
    3. User flow: does the interaction feel intuitive and complete?
- **Post-Execution Principles Check**:
  Before moving a card to `in_review` or presenting code as finished, the author must run a 30-second self-audit against `references/principles/`:
  1. **Canonical naming and layout** (`minimize-reader-load.md`): Is file naming standard? Is package layout canonical for this ecosystem (for example, `src/bin/imp.rs` rather than `src/imp_main.rs`)?
  2. **Atomic verifiable units** (`sequence-verifiable-units.md`): Are the implementation code and its verification tests in the same change? Can a reviewer verify everything in one step?
  3. **No premature abstractions** (`subtract-before-you-add.md`): Did I add unused options, dead boilerplate, or unneeded helper scripts?
  4. **Self-documenting interfaces** (`type-system-discipline.md`): Are CLI flags typed and declarative (for example, using standard libraries like `clap` rather than manual index loops)?
  5. **Proof of execution** (`prove-it-works.md`): Did I execute the verification runner and include the exact terminal output receipt?
- **Reviewer Principles Audit**:
  Reviewers must check submitted code against these principles. If a change introduces non-canonical file layouts, manual index-stepping CLI parsing, unneeded abstractions, or lacks verification receipts, flag it for changes.
- **Mandatory Verifier Maintenance on User Feedback & Course Corrections**:
  - Whenever the user provides corrective feedback, reports a flaw, or course-corrects agent behavior:
    1. **Never Apply Silent Code Patches**: A user course-correction is definitive proof of an **escaped defect** that slipped past the existing verification harness.
    2. **Mandatory Verifier Gap Audit**: The agent MUST explicitly ask: *"Why did our verifier fail to catch this? What check or assertion was missing?"*
    3. **Maintain the Verifier**: Check whether to invoke `maintain-verification-skill` (or update `verify.py` / `features/` recipes directly) to add an explicit regression test reproducing the user's feedback.
    4. **Prove It Works (Red-to-Green)**: Ensure the verifier reproduces the failure without the fix and passes green with it.
    5. **Report Verifier Status**: The reply to the user MUST explicitly state whether the verification harness was updated with new assertions, or clearly explain why the verifier already possessed coverage.
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

### 1C. Five-Stage Verification Pipeline
The verification runner (`scripts/verify.py`) tests the application in five stages, ordered by time and complexity:
- **Stage 1: Compile code (< 2s)**: Build and type check without running the application (`cargo check`, `tsc`).
- **Stage 2: Run unit tests (< 10s)**: Hermetic native unit tests in memory (`cargo test`, `pytest`, `npm test`).
- **Stage 3: Run CLI and check flags (~10–30s)**: Binary CLI contracts, flag parsing, test port checks, and zero fake data scan.
- **Stage 4: Architecture and principles audit**: Self-audit against `references/principles/` (canonical naming, atomic verifiable units, no premature abstractions, self-documenting interfaces).
- **Stage 5: Test user workflows and features (~1–3m)**: Automated headless scripts drive user workflows (browser automation, form inputs, CLI triggers). The agent inspects the resulting artifacts (screenshots, output text, network logs) to evaluate visual layout, semantic plausibility, and user experience.

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

---

## 5. Engineering Principles (`references/principles/`)

Engineering principles are modular deep-dive reference manuals housed in `~/dot/references/principles/`. They codify architectural wisdom, debugging discipline, and design standards.

### How to Use Principles (Mid-Flight Autonomous Discovery)
- **Do Not Memorize or Inject Upfront**: Principles are intentionally stored as modular files rather than top-level skills to avoid burning tokens on turn 1.
- **Read On-Demand When Triggered**: Consult the Situational Principles Router table below during task execution. When you hit a matching situation, friction point, or architectural fork, use `read_file` to inspect the relevant principle before writing code.

### Situational Principles Router
When you encounter any of the following situations, read the referenced principle before proceeding:

1. **Questioning task premise or asked to implement a questionable workaround** → read `~/dot/references/principles/attack-the-premise.md`
2. **Exposing cross-module contracts or passing untrusted inputs** → read `~/dot/references/principles/boundary-discipline.md`
3. **Performing repetitive manual steps or debugging toil** → read `~/dot/references/principles/build-the-lever.md`
4. **Fixing a bug and wanting to permanently prevent recurrence** → read `~/dot/references/principles/encode-lessons-in-structure.md`
5. **Evaluating architectural designs or choosing between alternatives** → read `~/dot/references/principles/exhaust-the-design-space.md`
6. **Designing APIs, CLI commands, or user-facing interactions** → read `~/dot/references/principles/experience-first.md`
7. **Displaying metrics, benchmarks, or telemetry counts** → read `~/dot/references/principles/explain-the-number.md`
8. **Tempted to patch a symptom or wrap an error in retry logic** → read `~/dot/references/principles/fix-root-causes.md`
9. **Tackling complex legacy spaghetti or feeling blocked by tech debt** → read `~/dot/references/principles/foundational-thinking.md`
10. **Handling large logs, sprawling diffs, or hitting context limits** → read `~/dot/references/principles/guard-the-context-window.md`
11. **About to write new helper code / checking if prior art exists** → read `~/dot/references/principles/laziness-protocol.md`
12. **Writing scripts, database migrations, or setup routines** → read `~/dot/references/principles/make-operations-idempotent.md`
13. **Modifying, deprecating, or replacing a live API / function contract** → read `~/dot/references/principles/migrate-callers-then-delete-legacy-apis.md`
14. **Writing documentation, comments, or PR descriptions** → read `~/dot/references/principles/minimize-reader-load.md`
15. **Designing domain entities, state representations, or enum types** → read `~/dot/references/principles/model-the-domain.md`
16. **Waiting for human reply when safe forward progress can be made** → read `~/dot/references/principles/never-block-on-the-human.md`
17. **Refining task milestones or verifying customer outcome alignment** → read `~/dot/references/principles/outcome-oriented-execution.md`
18. **About to claim code completion or move a task to review** → read `~/dot/references/principles/prove-it-works.md`
19. **Realizing an existing architecture is fundamentally flawed** → read `~/dot/references/principles/redesign-from-first-principles.md`
20. **Managing shared mutable state, concurrency, or DB locks** → read `~/dot/references/principles/separate-before-serializing-shared-state.md`
21. **Scoping large multi-step changes into deliverable units** → read `~/dot/references/principles/sequence-verifiable-units.md`
22. **Tempted to add flags, options, config keys, or extra parameters** → read `~/dot/references/principles/subtract-before-you-add.md`
23. **Writing unit tests or mocking internal implementation methods** → read `~/dot/references/principles/test-behavior-not-implementation.md`
24. **Using untyped primitives, loose strings, or permissive types** → read `~/dot/references/principles/type-system-discipline.md`

### Pre-Review Principles Self-Audit
Before moving a card to `in_review` or declaring a task complete, run this 30-second checklist:
1. **Canonical naming and layout** (`minimize-reader-load.md`): Is file naming standard? Is package layout canonical for this ecosystem (for example, `src/bin/imp.rs` rather than `src/imp_main.rs`)?
2. **Atomic verifiable units** (`sequence-verifiable-units.md`): Are the implementation code and its verification tests in the same change? Can a reviewer verify everything in one step?
3. **No premature abstractions** (`subtract-before-you-add.md`): Did I add unused options, dead boilerplate, or unneeded helper scripts?
4. **Self-documenting interfaces** (`type-system-discipline.md`): Are CLI flags typed and declarative (for example, using standard libraries like `clap` rather than manual index loops)?
5. **Proof of execution** (`prove-it-works.md`): Did I execute the verification runner and include the exact terminal output receipt?

Reviewers (`@reviewer*`) must audit code against these principles during reviews and reject changes that violate them.


