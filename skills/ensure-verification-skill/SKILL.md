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
- **Case 1: Bootstrap new harness (scripts/verify.py missing)**: go to Section 2.
- **Case 2: Maintain existing harness (scripts/verify.py present)**: go to Section 3. Do not read scaffolding templates.

---

## 2. Case 1: Bootstrap new harness (scripts/verify.py missing)

Follow these steps when the project has no verification files:

### Step 1: Gather context
Read three sources:
1. Conversation history: check recent error messages, feature requests, and discussed bugs.
2. Git history: run `git log -n 10 --oneline` and `git diff HEAD~5 --stat` to find touched modules.
3. Task board: check the card description and open tickets for acceptance criteria.

### 🎯 Mandatory user confirmation gate
Present findings to the user before writing files:
> "Here is what I gathered from your recent activity:
> - Recent commits and touched files: [summary]
> - Discovered features and fixes: [summary]
> Which specific features, bug fixes, or edge cases from your recent work should we verify?"

Wait for user confirmation before proceeding.

### Step 2: Generate files
Scaffold the standard directory structure:
- `scripts/doctor.sh`: fast preflight check verifying compiler, tools, and ports.
- `scripts/verify.py`: 5-stage runner testing compile, unit tests, CLI flags, principles, and user workflows.
- `<skills-root>/verify-<app>/SKILL.md`: documentation for driving and verifying the app.
- `<skills-root>/verify-<app>/features/`: Markdown specs for individual features.

See `references/template.md` for template code and file layouts.

### Step 3: Run initial pass
Run `scripts/doctor.sh` and `scripts/verify.py` to confirm all stages pass.

---

## 3. Case 2: Maintain existing harness (scripts/verify.py present)

When verification scripts already exist, run `ensure-verification-skill` across three continuous triggers:

### Trigger 1: On every bug report (before touching product code)
- If the bug is mechanical (crash, bad exit code, broken flag, wrong payload format, unhandled error): add an automated test to `scripts/verify.py` or native unit tests.
- If the bug is visual or subjective (layout shift, misalignment, bad typography, confusing copy): add an inspection check to Stage 5.
- Confirm the test fails (red), apply the product fix, and verify the test passes (green).

### Trigger 2: On every feature addition (alongside implementation)
- A feature does not exist until its verification recipe exists.
- Add programmatic checks (CLI flags, route responses, schema validation) to `scripts/verify.py` (Stages 1 through 3).
- Add workflow and visual expectations to Stage 5.

### Trigger 3: Post-landing upkeep (every merged change)
- Audit files in `<skills-root>/verify-<app>/features/` against modified routes (`git diff main --stat`).
- Prune verification checks for deleted routes or obsolete configuration options.
- Run `python3 scripts/verify.py` to ensure all five stages pass with zero false alarms.

### ⚠️ Blocking rule: maintenance edit scope
Only edit verification files (`SKILL.md`, `features/`, `scripts/`). Never weaken assertions or alter product code during maintenance. Genuine product bugs found during maintenance are defects, not doc drift.

---

## 4. The five verification stages

The verification runner (`scripts/verify.py`) tests the application across five progressive stages:

1. **Stage 1: Compile code (target < 2s)**
   Build and type check without running the application (`cargo check`, `tsc`).
   Command: `python3 scripts/verify.py --tier=1`

2. **Stage 2: Run unit tests (target < 10s)**
   Hermetic native unit tests in memory (`cargo test`, `pytest`, `npm test`).
   Command: `python3 scripts/verify.py --tier=2`

3. **Stage 3: Run CLI and check flags (target ~10–30s)**
   Run compiled binaries with argument combinations (`--help`, required arguments, missing flag errors). Launch an ephemeral server on a test port, check migrations, and scan for fake data.
   Command: `python3 scripts/verify.py --tier=3`

4. **Stage 4: Architecture and principles audit**
   Self-audit against `references/principles/`:
   - Canonical naming and layout (`minimize-reader-load.md`).
   - Atomic verifiable units (`sequence-verifiable-units.md`).
   - No premature abstractions (`subtract-before-you-add.md`).
   - Self-documenting interfaces (`type-system-discipline.md`).
   Command: `python3 scripts/verify.py --tier=4`

5. **Stage 5: Test user workflows and features (target ~1–3m)**
   Automate user workflows with headless scripts (Playwright, Puppeteer, Chrome DevTools Protocol, or CLI automation). The script clicks buttons, navigates views, triggers events, and saves screenshots and logs. The agent then inspects the captured output to verify visual layout, typography, and semantic correctness.
   Command: `python3 scripts/verify.py --tier=5`

Running `python3 scripts/verify.py` executes all five stages in sequence. On completion, the runner appends a run record to `~/.config/skills/usage.jsonl`.

---

## 5. Push determinism into code, reserve agents for judgment

Automate mechanical execution with deterministic code; reserve the agent for subjective evaluation and judgment:

- **Mechanical testing belongs in code**:
  Clicking buttons, checking button states, validating form fields, capturing screenshots, waiting for network responses, asserting DOM properties, and checking event feeds must be written into headless automation scripts (such as Playwright, Puppeteer, Chrome DevTools Protocol, curl, or test runners). Never ask an agent to manually click around when a script can do it deterministically.
- **Agents exercise judgment on the output**:
  The script executes deterministically; the agent inspects the resulting artifacts (screenshots, output text, network logs) to evaluate:
  1. Visual layout and typography: does the interface look clean and well-proportioned? Is there text truncation, misalignment, or badge overlap?
  2. Semantic plausibility: are the values, counts, and response texts correct and meaningful in domain context?
  3. User flow: does the interaction feel intuitive, complete, and responsive?


