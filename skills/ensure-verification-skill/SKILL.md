---
name: ensure-verification-skill
description: "Idempotently ensure a project has an up-to-date verification skill that tests behavior. If missing, scaffolds doctor and verify scripts; if present, updates feature coverage and runs the 5-stage pipeline."
---

# Ensure a verification skill

Every project needs an automated way to test application behavior. Running this skill ensures a working verification skill exists and stays aligned with the current codebase.

Resolve `<skills-root>` by running `SKILLS_ROOT=$(find-skills-root)` (or `find-skills-root --project`).

---

## 1. Fast detection check

Check if verification files already exist in this repository:
- `scripts/doctor.sh` and `scripts/verify.py` in the repository root.
- `<skills-root>/verify-<app>/SKILL.md` (or `.skills/verify-<app>/SKILL.md`).

Pick one path:
- **Case 1: Bootstrap new harness (scripts/verify.py missing)**: go to Section 2. Copy templates from `templates/`.
- **Case 2: Maintain existing harness (scripts/verify.py present)**: go to Section 3. Do not read templates.

---

## 2. Case 1: Bootstrap new harness (scripts/verify.py missing)

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

### Step 2: Copy and customize templates
1. Copy templates into place:
   ```bash
   TEMPLATES="$(find-skills-root)/ensure-verification-skill/templates"
   cp "${TEMPLATES}/doctor.template.sh" scripts/doctor.sh
   cp "${TEMPLATES}/verify.template.py" scripts/verify.py
   mkdir -p "<skills-root>/verify-<app>/features"
   cp "${TEMPLATES}/SKILL.template.md" "<skills-root>/verify-<app>/SKILL.md"
   chmod +x scripts/doctor.sh scripts/verify.py
   ```
2. Customize `<app>`, `<build_cmd>`, and `<test_cmd>` placeholders for the target project.

### Step 3: Run initial pass
Run `scripts/doctor.sh` and `scripts/verify.py` to confirm all stages pass.

---

## 3. Case 2: Maintain existing harness (scripts/verify.py present)

When verification scripts already exist, run `ensure-verification-skill` across three continuous triggers:

### Trigger 1: On every bug report (before touching product code)
- Mechanical bug (crash, error, bad flag): add automated test to `scripts/verify.py` or unit tests.
- Visual or subjective bug: add inspection check to Stage 5.
- Confirm test fails (red), apply fix, and verify test passes (green).

### Trigger 2: On every feature addition (alongside implementation)
- Add programmatic checks (CLI flags, route responses, schema validation) to Stages 1–3.
- Add workflow and visual expectations to Stage 5.

### Trigger 3: Post-landing upkeep (every merged change)
- Audit `<skills-root>/verify-<app>/features/` against modified routes (`git diff main --stat`).
- Prune obsolete checks and run `python3 scripts/verify.py` to ensure all stages pass.

### ⚠️ Blocking rule: maintenance edit scope
Only edit verification files (`SKILL.md`, `features/`, `scripts/`). Never weaken assertions or alter product code during maintenance. Genuine product bugs found during maintenance are defects, not doc drift.

---

## 4. The five verification stages

The verification runner (`scripts/verify.py`) tests the application across five progressive stages:

1. **Stage 1: Compile code (target < 2s)**: `python3 scripts/verify.py --tier=1`
   Build and type check without running the application (`cargo check`, `tsc`).
2. **Stage 2: Run unit tests (target < 10s)**: `python3 scripts/verify.py --tier=2`
   Hermetic native unit tests in memory (`cargo test`, `pytest`, `npm test`).
3. **Stage 3: Run CLI and check flags (target ~10–30s)**: `python3 scripts/verify.py --tier=3`
   Run compiled binaries with argument combinations, test flag errors, launch ephemeral server, scan for fake data.
4. **Stage 4: Architecture and principles audit**: `python3 scripts/verify.py --tier=4`
   Run pre-review checklist and consult `references/principles-router.md` (which maps tasks to principles in `$(find-skills-root)/../references/principles/`).
5. **Stage 5: Test user workflows and features (target ~1–3m)**: `python3 scripts/verify.py --tier=5`
   Automate user flows with headless scripts (capturing logs and screenshots); agent inspects layout, typography, and semantic correctness.

Running `python3 scripts/verify.py` executes all five stages in sequence, appending a run record to `~/.config/skills/usage.jsonl`.


