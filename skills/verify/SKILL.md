---
name: verify
description: "Universal verification playbook orchestrator that executes deterministic runners, agentic markdown test specs, principles audits, and skeptical expert reviews."
---

# Verify

Universal verification playbook orchestrator for any project. Coordinates deterministic execution (`verify.py`, `doctor.sh`) with project-defined agentic markdown test specs (`features/*.md`), architectural principles, and expert panel reviews.

---

## 1. Pre-flight lifecycle branching

- **IF nothing exists**: bootstrap suite via `init-verify [target_dir]` (e.g. `init-verify imp`, `init-verify verification`, or default `scripts/` — avoid dot directories like `.imp` which may be ignored by source control systems). Customize compile and test commands.
- **ELIF new issue or feature**: expand coverage before editing product code:
  * Deterministic: add targeted regression or CLI contract in `verify.py`.
  * Agentic: add user-path specification in `features/<feature>.md`.
- **FINALLY**: execute through the progressive stages.

---

## 2. Operational verification loops & execution gates

Execute verification across two operational loops with strict step-gating and proportional scaling:
- **Inner loop (< 5s, development iteration)**: run targeted tests (`python3 <dir>/verify.py --tier 0 [target]`) or compile/tests (`--fast`) after every sub-step to catch regressions immediately.
- **Strict step-gating**: never advance to Stage N+1 if Stage N fails (exit code != 0). Stop the line: diagnose, patch, and re-run Stage N in a loop (up to 5 iterations) until green.
- **Proportional verification scaling**: scope verification depth to the change's blast radius:
  * *Doc, typo, or comment edits*: Stage 1 only (compile/syntax check).
  * *Local bug fixes / isolated modules*: Stages 1 & 2 (`--fast` compile + unit/regression tests).
  * *Features, architectural changes, public APIs*: Full 5-stage pipeline + expert panel review + diff-scoped mutation verification (`--mutants`).
- **Outer loop (~1–3m, verification & review gate)**: run the scoped suite (`python3 <dir>/verify.py`), audit principles, and convene the expert panel.
- **Final green sweep mandate**: after addressing all fixes, audit findings, and reviewer comments, execute one final uninterrupted run of the scoped suite from top to bottom before presenting work or requesting review. The completion report must display this final clean receipt.

---

## 3. Maintenance triggers

Maintain coverage across four continuous triggers:
- **Trigger 1 (Bug reports)**: add automated test to `verify.py` (Stage 2) or inspection check to Stage 4.
- **Trigger 2 (New features)**: add checks to Stages 1–2, workflow specs to `features/<feature>.md`.
- **Trigger 3 (Template updates)**: sync framework runner logic while isolating project-specific tests.
- **Trigger 4 (Upkeep)**: audit `features/*.md` against modified routes and prune obsolete checks.

### ⚠️ Boundary rule: framework harness vs project specifics
- **Framework harness**: runner flags (`--tier`, `--fast`), telemetry, principles checklist. Re-syncable from `templates/`.
- **Project specifics**: build/test commands, CLI flags, feature specs in `features/`. Preserved across updates.
- Only edit verification files (`features/`, `scripts/`, `.<app>/`). Never alter product code during maintenance.

---

## 4. The progressive verification stages

Division of responsibilities: `verify.py` executes programmatic Stages 1–2 deterministically in code; the agent performs and writes agentic Stages 3–5 in the verification report.

### Programmatic execution in code (`verify.py`)
0. **Tier 0: Targeted test (< 2s)**: `python3 <dir>/verify.py --tier 0 [target]`
   Focused test for the specific function, module, or defect under active development (auto-detects modified tests if target omitted).
1. **Stage 1: Compile code (< 2s)**: `python3 <dir>/verify.py --tier 1`
   Build and type check without running the application (`cargo check`, `tsc`).
2. **Stage 2: Run automated tests (< 10s)**: `python3 <dir>/verify.py --tier 2` (or `--fast` for Stages 1 & 2; optional `--mutants` for diff-scoped mutation testing)
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


