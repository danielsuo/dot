---
name: ensure-verification-skill
description: "Idempotently ensure a project has an up-to-date verification skill that tests behavior. If missing, scaffolds doctor and verify scripts; if present, updates feature coverage and runs the 5-stage pipeline."
---

# Ensure a verification skill

Every project needs an automated way to test application behavior. Running this skill ensures a working verification skill exists and stays aligned with the current codebase.

This skill is idempotent:
- **If the project has no verification skill**: it gathers context and scaffolds the verification suite.
- **If the project already has a verification skill**: it audits feature coverage against modified routes, prunes dead scenarios, and runs the verification suite.

Resolve `<skills-root>` by running `SKILLS_ROOT=$(find-skills-root)` (or `find-skills-root --project`).

---

## 1. Idempotent workflow

### Check for existing verification files
Check whether the project already has:
1. `scripts/doctor.sh` and `scripts/verify.py` in the repository root.
2. `<skills-root>/verify-<app>/SKILL.md` (or `.skills/verify-<app>/SKILL.md`).

### Path A: Project lacks a verification skill (create)
1. **Gather context (Step 0A)**:
   - Check conversation history for discussed bugs and recent features.
   - Run `git log -n 10 --oneline` and `git diff HEAD~5 --stat` to find touched modules.
   - Read the current task description for acceptance criteria.
2. **User confirmation gate (Step 0B)**:
   Present findings to the user before writing files:
   > "Here is what I gathered from your recent activity:
   > - Recent commits and touched files: [summary]
   > - Discovered features and fixes: [summary]
   > Which specific features, bug fixes, or edge cases from your recent work should we verify?"
   Wait for user confirmation.
3. **Scaffold files**:
   - `scripts/doctor.sh`: fast preflight check verifying compiler, tools, and ports.
   - `scripts/verify.py`: 5-stage runner testing compile, unit tests, CLI flags, principles, and user workflows.
   - `<skills-root>/verify-<app>/SKILL.md`: documentation for driving and verifying the app.
   - `<skills-root>/verify-<app>/features/`: Markdown specs for individual features.
4. **Execute**:
   Run `scripts/doctor.sh` and `scripts/verify.py` to confirm all stages pass.

### Path B: Project already has a verification skill (maintain)
1. **Audit feature coverage**:
   Compare files in `<skills-root>/verify-<app>/features/` and tests in `scripts/verify.py` against recently modified routes and modules (`git diff main --stat`).
2. **Add missing scenarios**:
   Add test assertions for newly added flags, endpoints, or features. If a bug was reported, write an explicit regression test reproducing it.
3. **Prune dead scenarios**:
   Remove verification checks for deleted routes or obsolete configuration options.
4. **Execute and calibrate**:
   Run `python3 scripts/verify.py` to ensure all five stages pass with zero false alarms.

---

## 2. The five verification stages

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

## 3. Push determinism into code, reserve agents for judgment

Automate mechanical execution with deterministic code; reserve the agent for subjective evaluation and judgment:

- **Mechanical testing belongs in code**:
  Clicking buttons, checking button states, validating form fields, capturing screenshots, waiting for network responses, asserting DOM properties, and checking event feeds must be written into headless automation scripts (such as Playwright, Puppeteer, Chrome DevTools Protocol, curl, or test runners). Never ask an agent to manually click around when a script can do it deterministically.
- **Agents exercise judgment on the output**:
  The script executes deterministically; the agent inspects the resulting artifacts (screenshots, output text, network logs) to evaluate:
  1. Visual layout and typography: does the interface look clean and well-proportioned? Is there text truncation, misalignment, or badge overlap?
  2. Semantic plausibility: are the values, counts, and response texts correct and meaningful in domain context?
  3. User flow: does the interaction feel intuitive, complete, and responsive?

---

## 4. File layout for the verification skill

```
${SKILLS_ROOT}/verify-<app>/
├── SKILL.md
├── features/
│   ├── README.md
│   └── <feature>.md
└── scripts/
    ├── doctor.sh         # Fast health check (< 3s): compiler, tools, port
    ├── verify.py         # 5-stage runner (--tier=1|2|3|4|5)
    ├── parity_check.py   # Upstream database vs API validator
    └── lint_fake_data.py # Source scanner for fake data
```
