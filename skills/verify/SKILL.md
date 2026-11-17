---
name: verify
description: "Universal verification skill that triggers on ANY project change (new project, feature, bug fix, or refactor) to create, update, and run the 5-stage verification suite."
---

# Verify

Universal verification runner and maintainer for any project. Couples deterministic execution in code (`verify.py`, `doctor.sh`) with agentic judgment on principles (`references/principles/`) and user workflows (`features/*.md`).

---

## 1. Fast detection check

Check if verification files exist in the repository:
- `scripts/verify.py` or `.<app>/verify.py` (and `doctor.sh`)

Pick one path:
- **Case 1: Bootstrap new harness (verify.py missing)**: go to Section 2.
- **Case 2: Run and maintain verification (verify.py present)**: go to Section 3.

---

## 2. Case 1: Bootstrap new harness (verify.py missing)

Follow these steps when the project has no verification files:

### Step 1: Gather context
Read conversation history, recent git commits (`git log -n 10 --oneline`), and open card criteria.

### 🎯 Mandatory user confirmation gate
Present findings to the user before writing files:
> "Here is what I gathered from your recent activity:
> - Recent commits and touched files: [summary]
> - Discovered features and fixes: [summary]
> Which specific features, bug fixes, or edge cases from your recent work should we verify?"

Wait for user confirmation before proceeding.

### Step 2: Bootstrap suite
Run `init-verify`:
```bash
init-verify
```
This copies `doctor.sh` and `verify.py` from `templates/`, creates `features/`, and sets execute permissions. Customize compile and test commands for the target project.

### Step 3: Run initial pass
Run preflight and runner to confirm all stages pass.

---

## 3. Case 2: Run and maintain verification (verify.py present)

Execute verification and keep coverage up to date across four continuous triggers:

### Trigger 1: On every bug report (before touching product code)
- Mechanical bug (crash, error, bad flag): add automated test to `verify.py` (Stage 2) or unit tests.
- Visual or subjective bug: add inspection check to Stage 4.
- Confirm test fails (red), apply fix, and verify test passes (green).

### Trigger 2: On every feature addition (alongside implementation)
- Add programmatic checks (CLI flags, route responses, schema validation) to Stages 1–2.
- Add workflow and visual expectations to Stage 4 in `features/<feature>.md`.

### Trigger 3: On template updates (re-sync framework)
- When global templates update (flags, telemetry, principles): sync framework logic in `verify.py` and `doctor.sh`.
- Strictly isolate and preserve project-specific commands, test functions, and `features/*.md` specs.

### Trigger 4: Post-landing upkeep (every merged change)
- Audit `features/*.md` against modified routes (`git diff main --stat`).
- Prune obsolete checks and run verification to ensure all stages pass.

### ⚠️ Boundary rule: framework harness vs project specifics
- **Framework harness**: runner flags (`--tier`), telemetry, principles checklist. Re-syncable from `templates/`.
- **Project specifics**: build/test commands, CLI flags, feature specs in `features/`. Preserved across updates.
- Only edit verification files (`features/`, `scripts/`). Never alter product code during maintenance.

---

## 4. The five verification stages

Couples deterministic execution with agentic reasoning and expert peer review (stages and personas are exemplary and adapt to project needs):

1. **Stage 1: Compile code (< 2s)**: `python3 <dir>/verify.py --tier=1` [Deterministic]
   Build and type check without running the application (`cargo check`, `tsc`).
2. **Stage 2: Run automated tests (< 10s)**: `python3 <dir>/verify.py --tier=2` [Deterministic]
   Hermetic unit and integration tests (CLI arguments, flag combinations, regressions, migrations).
3. **Stage 3: Architecture & principles audit**: `python3 <dir>/verify.py --tier=3` [Agentic]
   Self-audit against pre-review checklist and `references/principles-router.md` (`$(find-skills-root)/../references/principles/`).
4. **Stage 4: Test user workflows (~1–3m)**: `python3 <dir>/verify.py --tier=4` [Dual]
   Headless automation captures logs/screenshots; agent evaluates layout, typography, and correctness against `features/*.md`.
5. **Stage 5: Skeptical expert panel review** [Agentic Panel]
   Dynamically convene 5–6 strongly skeptical expert reviewer personas tailored to the specific project and change (for example: application maintainers, related project owners, systems architects, security reviewers). Panel interrogates edge cases, latent failure modes, and API trade-offs.

Output an **Actionable Verification Report** spanning concrete line fixes for Stage 1–2 failures up to architectural remedies for Stage 3–5 concerns.


