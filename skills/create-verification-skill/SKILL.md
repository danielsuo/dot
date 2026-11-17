---
name: create-verification-skill
description: "Generate a verification skill that drives an application like a user and proves behavior. Enforces compile checks, unit tests, CLI flags, user workflows, regression tests, and zero fake data."
---

# Create a verification skill

Every project needs a script to run the application and test its behavior. A smoke check that only tests HTTP 200 or checks that a process started does not catch regressions.

This skill creates a verification skill in `<skills-root>/verify-<app>/`. The generated skill tests compile errors, unit tests, CLI flag contracts, live user workflows, regression tests from past bugs, and data validity.

Resolve `<skills-root>` by running `SKILLS_ROOT=$(find-skills-root)` (or `find-skills-root --project`). Another agent will read the generated files without prior context on the application.

---

## 1. The four verification stages

The verification runner (`scripts/verify.py`) tests the application in four stages, ordered by time and complexity:

1. **Stage 1: Compile code (target < 2s)**
   Build and type check without running the application (`cargo check`, `tsc`, or language type checkers). Fails on syntax errors or missing dependencies before tests run.
   Command: `python3 scripts/verify.py --tier=1`

2. **Stage 2: Run unit tests (target < 10s)**
   Run hermetic native unit tests in memory (`cargo test`, `pytest`, `npm test`). Fails on logic bugs, parser errors, and unit regressions.
   Command: `python3 scripts/verify.py --tier=2`

3. **Stage 3: Run CLI and check flags (target ~10–30s)**
   Run the compiled binaries with argument combinations. Test `--help`, missing argument errors, and parameter bounds. Launch an ephemeral server on a test port, check database migrations, and scan source files for hardcoded fake data.
   Command: `python3 scripts/verify.py --tier=3`

4. **Stage 4: Test user workflows (target ~1–3m)**
   Test the user interface directly. For web apps, run browser automation (Playwright, Puppeteer, or Chrome DevTools Protocol), click buttons, fill forms, and check responsive views. For terminal apps, run interactive commands in a pseudo-terminal and assert output.
   Command: `python3 scripts/verify.py --tier=4`

By default, `python3 scripts/verify.py` runs all four stages in sequence and stops on the first failure. On completion, the runner appends a record with status and duration to `~/.config/skills/usage.jsonl`.

---

## 2. Core checks in the verification script

### Regression tests from past bugs
Never write assertions solely from the source code. Check the project chat history, bug tracker, and code reviews for past bugs and user complaints.
Common failure modes to test:
- UI elements that freeze when filters or drill-downs change.
- Missing data before a specific date cutoff.
- Duplicate labels or suffixes.
- Empty table rows or zero-drops.
- Race conditions on rapid clicks.

Every bug discovered becomes an explicit test in `scripts/verify.py`.

### Ground truth database comparison
If the application queries a database or upstream service (such as PostgreSQL, MySQL, SQLite, or an upstream API):
1. The verification script runs the database query directly.
2. The script compares the application API response against the database query output.
3. Assert that row counts, sums, and entity IDs match.

### Zero fake data check
The verification suite scans source files for:
- Mathematical scaling factors (such as `* 1.15` or `powf`).
- Hardcoded fallback arrays, dummy rows, or constant overrides.
- Mock data generators in production paths.

Any synthetic or mock data found in production code fails the check.

### Dynamic interaction tests
For user interfaces, test state updates during user interaction:
- Expand tree views and nested rows, then assert child elements render.
- Adjust timeline scrubbers and date pickers, then assert charts update.
- Type in search bars and toggle filters, then assert row counts change.
- Click table headers, then assert sort order changes.
- Check the browser console log and assert zero uncaught errors.

---

## 3. Step 0: Context gathering and user confirmation

Before creating the skill, gather recent context and confirm the plan with the user.

### Step 0A: Gather context
Read three sources:
1. Conversation history: check recent error messages, feature requests, and discussed bugs.
2. Git history: run `git log -n 10 --oneline` and `git diff HEAD~5 --stat` to identify modified files and active modules.
3. Task board: check the card description and open tickets for acceptance criteria.

### Step 0B: User confirmation gate
Present the summary to the user before writing code:
> "Here is what I gathered from your recent activity:
> - Recent commits and touched files: [summary]
> - Discovered features and fixes: [summary]
> Which specific features, bug fixes, or edge cases from your recent work should we verify?"

Wait for the user to reply before generating files.

---

## 4. File layout for the verification skill

Run `SKILLS_ROOT=$(find-skills-root)` to find the destination directory. Create `${SKILLS_ROOT}/verify-<app>/`:

```
${SKILLS_ROOT}/verify-<app>/
├── SKILL.md
├── features/
│   ├── README.md
│   └── <feature>.md
└── scripts/
    ├── doctor.sh         # Fast health check (< 3s): compiler, unit tests, port
    ├── verify.py         # 4-stage runner (--tier=1|2|3|4)
    ├── parity_check.py   # Upstream database vs API validator
    └── lint_fake_data.py # Source scanner for fake data
```

### Sections in `SKILL.md`
Write `${SKILLS_ROOT}/verify-<app>/SKILL.md` with YAML frontmatter and these sections:
- Launch: command to start the application from an empty data directory.
- Doctor: fast read-only check (`scripts/doctor.sh`) to confirm the compiler, process, and port are ready.
- Verification suite: how to run `scripts/verify.py` across stages 1 through 4.
- Drive: step-by-step instructions for testing the primary user workflows.
- Evidence: output to collect (terminal logs, command exit codes, screenshots).
- Cleanup: commands to stop spawned processes without deleting test logs.
- Helpers: description of each script in `scripts/`.

---

## 5. Document user features

Create `${SKILLS_ROOT}/verify-<app>/features/README.md` and one Markdown file per feature:
- Capabilities: list what the feature does.
- User path: how a user accesses the feature.
- Automation: selectors, clicks, and inputs used by the script.
- Assertions: checks that prove the feature updated state correctly.

---

## 6. Run the verification script

Before finishing:
1. Run `scripts/doctor.sh` and confirm it exits with code 0.
2. Run `scripts/verify.py` and confirm all four stages pass.
3. Confirm output logs and artifacts exist in the expected paths.
4. Stop all background processes.

