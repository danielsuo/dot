---
name: verify
description: "Universal verification playbook orchestrator that executes deterministic runners, agentic markdown test specs, principles audits, and skeptical expert reviews."
---

# Verify

Universal verification playbook orchestrator for any project. Coordinates deterministic execution (`verify.py`, `doctor.sh`) with project-defined agentic markdown test specs (`features/*.md`), architectural principles, and expert panel reviews.

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

Execute verification across two operational loops:
- **Inner loop (< 5s, development iteration)**: run targeted tests (`python3 <dir>/verify.py --tier 0 [target]`) or compile/tests (`--fast`) after every sub-step to catch regressions immediately.
- **Outer loop (~1–3m, verification & review gate)**: run the full suite (`python3 <dir>/verify.py`), audit principles, and convene the expert panel. If issues arise, the agent diagnoses, fixes, and re-verifies in a convergence loop (up to 5 iterations) until green.

Maintain coverage across four continuous triggers:
- **Trigger 1 (Bug reports)**: add automated test to `verify.py` (Stage 2) or inspection check to Stage 4.
- **Trigger 2 (New features)**: add checks to Stages 1–2, workflow specs to `features/<feature>.md`.
- **Trigger 3 (Template updates)**: sync framework runner logic while isolating project-specific tests.
- **Trigger 4 (Upkeep)**: audit `features/*.md` against modified routes and prune obsolete checks.

### ⚠️ Boundary rule: framework harness vs project specifics
- **Framework harness**: runner flags (`--tier`, `--fast`), telemetry, principles checklist. Re-syncable from `templates/`.
- **Project specifics**: build/test commands, CLI flags, feature specs in `features/`. Preserved across updates.
- Only edit verification files (`features/`, `scripts/`). Never alter product code during maintenance.

---

## 4. The progressive verification stages

Couples deterministic execution with agentic reasoning and expert peer review (stages and personas are exemplary and adapt to project needs):

0. **Tier 0: Targeted test (< 2s)**: `python3 <dir>/verify.py --tier 0 [target]` [Deterministic]
   Focused test for the specific function, module, or defect under active development (auto-detects modified tests if target omitted).
1. **Stage 1: Compile code (< 2s)**: `python3 <dir>/verify.py --tier=1` [Deterministic]
   Build and type check without running the application (`cargo check`, `tsc`).
2. **Stage 2: Run automated tests (< 10s)**: `python3 <dir>/verify.py --tier=2` [Deterministic]
   Hermetic unit and integration tests (CLI arguments, flag combinations, regressions, migrations).
3. **Stage 3: Architecture & principles audit**: `python3 <dir>/verify.py --tier=3` [Agentic]
   Self-audit against pre-review checklist and `references/principles-router.md` (`$(find-skills-root)/../references/principles/`).
4. **Stage 4: Test user workflows (~1–3m)**: `python3 <dir>/verify.py --tier=4` [Dual]
   Agent executes project agentic markdown test specs (`features/*.md`):
   - Preconditions: environment vars, test servers, daemon state.
   - Actions: CLI commands, API requests, user interactions.
   - Assertions: expected outputs, state transitions, layout sanity.
   - Qualitative review: typography, visual appeal, semantic sense.
5. **Stage 5: Skeptical expert panel review** [Agentic Panel]
   Dynamically convene 5–6 strongly skeptical expert reviewer personas tailored to the specific project and change (for example: application maintainers, related project owners, systems architects, security reviewers). Panel interrogates edge cases, latent failure modes, and API trade-offs.

Output an **Actionable Verification Report** spanning concrete line fixes for Stage 1–2 failures up to architectural remedies for Stage 3–5 concerns.


