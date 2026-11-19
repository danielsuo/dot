---
name: verify
description: "Universal deterministic verification orchestrator running machine-executable stages via verify CLI (doctor, compile, test, mutants, stats) with handoff to Reviewer Agent."
---

# Verify

Universal deterministic verification orchestrator for any project. Dispatches
machine-executable stages via `verify` (`doctor`, `compile`, `test`, `mutants`,
`live`, `final`, `stats`). Verifier suites live in `./imp/` (or `./verifiers/`)
inside the target project, resolved via `verify path` or `verify <stage> --path`.

Once deterministic verification passes (100% green exit code), the unsubmitted
diff is handed off to a dedicated **Reviewer Agent** (or review skill) to audit
against `AGENTS.md` and engineering principles before review or mailing.

---

## 1. Pre-flight lifecycle & upkeep

- **Locate verifier suite**: run `verify path` (or `verify <stage> --path` /
  `verify edit [script]`) to inspect or edit verifier scripts.
- **IF unconfigured**: run `verify init [path]` to scaffold `doctor.sh`,
  `compile.sh`, `test.sh`, and `mutants.sh` into `./imp/`.
- **ELIF new issue or feature**: MANDATORY PRE-CODE UPKEEP before editing code:
  * Locate suite: run `verify path` to find the verifier root.
  * Update `compile.sh` (new build targets/flags) and `test.sh` (add regression
    test for bugs, unit/integration targets).
- **FINALLY**: execute through the deterministic stages using `verify`. Run
  `verify stats` for execution metrics.

---

## 2. Operational verification loops & execution gates

Execute verification across two loops with strict step-gating and scaling:
- **Inner loop (< 5s, development iteration)**: run `verify test [target]` or
  `verify compile && verify test` after every sub-step to catch regressions.
- **Strict step-gating**: never advance to Stage N+1 if Stage N fails (exit
  code != 0). Stop the line: diagnose, patch, and re-run Stage N (up to 5
  iterations) until green.
- **Proportional scaling**:
  * *Doc, typo, or comment edits*: Stage 1 only (`verify compile`).
  * *Local bug fixes / isolated modules*: Stages 1 & 2 (`verify compile &&
    verify test`).
  * *Features, architectural changes, public APIs*: Full deterministic
    pipeline (`verify doctor`, `compile`, `test`, `mutants`).
- **Final green sweep mandate**: after addressing all fixes, execute `verify final`
  (one final uninterrupted run of `doctor`, `compile`, `test`, `mutants`, and
  `live` when `live.sh` is present) before presenting work or requesting review.

---

## 3. The deterministic verification stages

All stages are pure, machine-executable contracts (exit 0 on success):
0. **Stage 0: Health check**: `verify doctor` (tooling, environment).
1. **Stage 1: Compile code (< 2s)**: `verify compile` (build and type check).
2. **Stage 2: Run automated tests (< 10s)**: `verify test` (and
   `verify test [target]`). Inspect paths with `verify <stage> --path`.
3. **Stage 3: Mutation tests**: `verify mutants` (diff-scoped mutation checks).
4. **Stage 4: Live E2E gate**: `verify live` (optional `live.sh` in `./imp/`,
   automatically included by `verify final`).

---

## 4. Handoff to Reviewer Agent

`verify` intentionally excludes subjective or prompt-based agentic review to
remain sub-15s, 100% reproducible, and zero-hallucination.

After `verify` passes 100% green:
1. **Handoff**: The workspace diff is provided to the dedicated **Reviewer
   Agent** (or `@reviewer`) running the `review` skill (`skills/review/SKILL.md`).
2. **Principle Audit**: The Reviewer Agent audits changes against `AGENTS.md`
   and all 24 poteto principles in `skills/review/references/principles.md`
   (and `references/principles/*.md`).
3. **Adversarial Critique**: The Reviewer Agent evaluates API ergonomics, edge
   cases, behavioral test oracle strength, and failure modes, emitting
   structured findings (`P0`–`P3`) with `[Principle: <slug>]` citations.
