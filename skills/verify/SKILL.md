---
name: verify
description: "Universal verification playbook orchestrator dispatching deterministic stage runners via verify-cmd, agentic test specs, principles audits, and skeptical expert reviews."
---

# Verify

Universal verification playbook orchestrator for any project. Dispatches deterministic stages via `verify-cmd` (`compile`, `test`, `doctor`, `mutants`) paired with agentic markdown test specs (`features/*.md`), architectural principles, and expert panel reviews. Verifier suites live centrally or out-of-tree (configured in `~/.config/impromptu/projects.toml` and resolved via `verify-cmd path`) for zero repository clutter.

---

## 1. Pre-flight lifecycle & upkeep

- **Locate verifier suite**: run `verify-cmd path` (or `verify-cmd edit [script]`) to inspect or edit the active project's verifier scripts and `features/*.md`.
- **IF unconfigured**: run `verify-cmd init [path]` to scaffold `doctor.sh`, `compile.sh`, `test.sh`, `mutants.sh`, and `features/` into a verifiers directory and register in `~/.config/impromptu/projects.toml`.
- **ELIF new issue or feature**: expand coverage before editing product code:
  * Deterministic: add targeted regression or CLI contract in `$(verify-cmd edit test)`.
  * Agentic: add user-path specification in `$(verify-cmd path)/features/<feature>.md`.
- **FINALLY**: execute through the progressive stages using `verify-cmd`.

---

## 2. Operational verification loops & execution gates

Execute verification across two operational loops with strict step-gating and proportional scaling:
- **Inner loop (< 5s, development iteration)**: run `verify-cmd test [target]` or `verify-cmd compile && verify-cmd test` after every sub-step to catch regressions immediately.
- **Strict step-gating**: never advance to Stage N+1 if Stage N fails (exit code != 0). Stop the line: diagnose, patch, and re-run Stage N in a loop (up to 5 iterations) until green.
- **Proportional scaling**:
  * *Doc, typo, or comment edits*: Stage 1 only (`verify-cmd compile`).
  * *Local bug fixes / isolated modules*: Stages 1 & 2 (`verify-cmd compile && verify-cmd test`).
  * *Features, architectural changes, public APIs*: Full pipeline (`verify-cmd doctor`, `compile`, `test`, `mutants`) + expert panel review.
- **Outer loop (~1–3m, verification & review gate)**: run the scoped suite, audit principles, and convene the expert panel.
- **Final green sweep mandate**: after addressing all fixes, execute one final uninterrupted run of the scoped suite from top to bottom before presenting work or requesting review.

---

## 3. Maintenance triggers

Maintain coverage across four continuous triggers:
- **Trigger 1 (Bug reports)**: add automated test to `test.sh` (Stage 2) or inspection check to Stage 4.
- **Trigger 2 (New features)**: add checks to `test.sh`, workflow specs to `features/<feature>.md`.
- **Trigger 3 (Harness upkeep)**: run `verify-cmd path` to locate stage scripts; update without touching product code.
- **Trigger 4 (Spec pruning)**: audit `features/*.md` against modified routes and prune obsolete checks.

---

## 4. The progressive verification stages

Division of responsibilities: `verify-cmd` executes programmatic Stages 1–2 deterministically in code; the agent performs and writes agentic Stages 3–5 in the verification report.

### Programmatic execution in code
0. **Tier 0: Targeted test (< 2s)**: `verify-cmd test [target]` (e.g. `verify-cmd test my_test`).
1. **Stage 1: Compile code (< 2s)**: `verify-cmd compile` (build and type check without running).
2. **Stage 2: Run automated tests (< 10s)**: `verify-cmd test` (and `verify-cmd mutants` for diff-scoped mutation checks).

### Agentic reasoning in review (performed and written by agent)
3. **Stage 3: Architecture & principles audit** [Agentic]
   Agent self-audits unsubmitted diff against `AGENTS.md` principles (minimal changes, no premature abstractions, zero fake data, atomic units).
4. **Stage 4: Test user workflows (~1–3m)** [Agentic]
   Agent executes and walks project agentic markdown test specs in `$(verify-cmd path)/features/*.md`:
   - Preconditions: environment vars, test servers, daemon state.
   - Actions: CLI commands, API requests, user interactions.
   - Assertions: expected outputs, state transitions, layout sanity.
   - Qualitative review: typography, visual appeal, semantic sense.
5. **Stage 5: Skeptical expert panel review** [Agentic Panel]
   Agent dynamically convenes strongly skeptical expert reviewer personas tailored to the specific project and change:
   - Staff Architect: unnecessary complexity, abstraction leaks, future debt, API ergonomics.
   - Principal SRE: failure modes, edge cases, silent regressions, crash handling, timeouts, adversarial fault injection.
   - Adversarial User / QA: unexpected inputs, broken user expectations, ergonomic traps.

Output an **Actionable Verification Report** in chat spanning concrete line fixes for Stage 1–2 failures up to architectural remedies for Stage 3–5 concerns.


