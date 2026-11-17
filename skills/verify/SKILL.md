---
name: verify
description: "Universal verification playbook orchestrator that executes deterministic runners, agentic markdown test specs, principles audits, and skeptical expert reviews."
---

# Verify

Universal verification playbook orchestrator for any project. Coordinates deterministic stage scripts (`doctor.sh`, `compile.sh`, `test.sh`, `mutants.sh`) with project-defined agentic markdown test specs (`features/*.md`), architectural principles, and expert panel reviews.

---

## 1. Pre-flight lifecycle branching

- **IF nothing exists**: bootstrap suite via `init-verify [target_dir]` (e.g. `init-verify imp`, `init-verify verification`, default `scripts/` — avoid dot directories like `.imp` which may be ignored by source control systems). Generates `doctor.sh`, `compile.sh`, `test.sh`, `mutants.sh`, and `features/`.
- **ELIF new issue or feature**: expand coverage before editing product code:
  * Deterministic: add targeted regression or CLI contract in `test.sh`.
  * Agentic: add user-path specification in `features/<feature>.md`.
- **FINALLY**: execute through the progressive stages.

---

## 2. Operational verification loops & execution gates

Execute verification across two operational loops with strict step-gating and proportional scaling:
- **Inner loop (< 5s, development iteration)**: run targeted tests (`<dir>/test.sh [target]`) or compile/tests (`<dir>/compile.sh && <dir>/test.sh`) after every sub-step to catch regressions immediately.
- **Strict step-gating**: never advance to Stage N+1 if Stage N fails (exit code != 0). Stop the line: diagnose, patch, and re-run Stage N in a loop (up to 5 iterations) until green.
- **Proportional verification scaling**: scope verification depth to the change's blast radius:
  * *Doc, typo, or comment edits*: Stage 1 only (`compile.sh`).
  * *Local bug fixes / isolated modules*: Stages 1 & 2 (`compile.sh && test.sh`).
  * *Features, architectural changes, public APIs*: Full pipeline (`doctor.sh`, `compile.sh`, `test.sh`, `mutants.sh`) + expert panel review.
- **Outer loop (~1–3m, verification & review gate)**: run the scoped suite, audit principles, and convene the expert panel.
- **Final green sweep mandate**: after addressing all fixes, audit findings, and reviewer comments, execute one final uninterrupted run of the scoped suite from top to bottom before presenting work or requesting review. The completion report must display this final clean receipt.

---

## 3. Maintenance triggers

Maintain coverage across four continuous triggers:
- **Trigger 1 (Bug reports)**: add automated test to `test.sh` (Stage 2) or inspection check to Stage 4.
- **Trigger 2 (New features)**: add checks to `test.sh`, workflow specs to `features/<feature>.md`.
- **Trigger 3 (Template updates)**: sync framework stage templates while isolating project-specific tests.
- **Trigger 4 (Upkeep)**: audit `features/*.md` against modified routes and prune obsolete checks.

### ⚠️ Boundary rule: framework harness vs project specifics
- **Framework harness**: modular stage templates (`doctor.sh`, `compile.sh`, `test.sh`, `mutants.sh`). Re-syncable from `templates/`.
- **Project specifics**: build/test commands, CLI flags, feature specs in `features/`. Preserved across updates.
- Only edit verification files (`features/`, `scripts/`, `imp/`). Never alter product code during maintenance.

---

## 4. The progressive verification stages

Division of responsibilities: dedicated shell scripts execute programmatic Stages 1–2 deterministically in code; the agent performs and writes agentic Stages 3–5 in the verification report.

### Programmatic execution in code
0. **Tier 0: Targeted test (< 2s)**: `<dir>/test.sh [target]`
   Focused check for the specific function, module, or test target (e.g. `./test.sh event_engine_test`).
1. **Stage 1: Compile code (< 2s)**: `<dir>/compile.sh`
   Build and type check without running the application (`cargo check`, `tsc`).
2. **Stage 2: Run automated tests (< 10s)**: `<dir>/test.sh` (optional `<dir>/mutants.sh` for diff-scoped mutation testing)
   Hermetic unit and integration tests (CLI arguments, flag combinations, regressions, migrations, and diff-scoped mutant kills).

### Agentic reasoning in review (performed and written by agent)
3. **Stage 3: Architecture & principles audit** [Agentic]
   Agent self-audits unsubmitted diff against `AGENTS.md` principles router and `references/principles/` (minimal changes, no premature abstractions, zero fake data, atomic units).
4. **Stage 4: Test user workflows (~1–3m)** [Agentic]
   Agent executes and walks project agentic markdown test specs (`features/*.md`):
   - Preconditions: environment vars, test servers, daemon state.
   - Actions: CLI commands, API requests, user interactions.
   - Assertions: expected outputs, state transitions, layout sanity.
   - Qualitative review: typography, visual appeal, semantic sense.
5. **Stage 5: Skeptical expert panel review** [Agentic Panel]
   Agent dynamically convenes strongly skeptical expert reviewer personas tailored to the specific project and change:
   - Staff Architect: unnecessary complexity, abstraction leaks, future debt, API ergonomics.
   - Principal SRE: failure modes, edge cases, silent regressions, crash handling, timeouts, and adversarial fault injection (verifying assertions turn RED on subtle code mutations).
   - Adversarial User / QA: unexpected inputs, broken user expectations, ergonomic traps.

Output an **Actionable Verification Report** in chat spanning concrete line fixes for Stage 1–2 failures up to architectural remedies for Stage 3–5 concerns.


