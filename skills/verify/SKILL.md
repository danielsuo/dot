---
name: verify
description: "Universal verification skill to bootstrap and run a project's 5-stage verification pipeline, update feature tests, and enforce engineering principles."
---

# Verify

Universal verification runner and maintainer for any project. Verification harnesses live directly in the project as `scripts/verify.py` (or `.<app>/verify.py`), `doctor.sh`, and `features/*.md`.

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
- Mechanical bug (crash, error, bad flag): add automated test to `verify.py` or unit tests.
- Visual or subjective bug: add inspection check to Stage 5.
- Confirm test fails (red), apply fix, and verify test passes (green).

### Trigger 2: On every feature addition (alongside implementation)
- Add programmatic checks (CLI flags, route responses, schema validation) to Stages 1–3.
- Add workflow and visual expectations to Stage 5 in `features/<feature>.md`.

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

The verification runner (`verify.py`) tests the application across five progressive stages:

1. **Stage 1: Compile code (target < 2s)**: `python3 <dir>/verify.py --tier=1`
   Build and type check without running the application (`cargo check`, `tsc`).
2. **Stage 2: Run unit tests (target < 10s)**: `python3 <dir>/verify.py --tier=2`
   Hermetic native unit tests in memory (`cargo test`, `pytest`, `npm test`).
3. **Stage 3: Run CLI and check flags (target ~10–30s)**: `python3 <dir>/verify.py --tier=3`
   Run compiled binaries with argument combinations, test flag errors, launch ephemeral server, scan for fake data.
4. **Stage 4: Architecture and principles audit**: `python3 <dir>/verify.py --tier=4`
   Run pre-review checklist and consult `references/principles-router.md` (which maps tasks to principles in `$(find-skills-root)/../references/principles/`).
5. **Stage 5: Test user workflows and features (target ~1–3m)**: `python3 <dir>/verify.py --tier=5`
   Automate user flows with headless scripts (capturing logs and screenshots); agent inspects layout, typography, and semantic correctness.

Running `python3 <dir>/verify.py` executes all five stages in sequence, appending a run record to `~/.config/skills/usage.jsonl`.


