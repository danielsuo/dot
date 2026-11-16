---
name: setup-dsuo
description: "Adaptive, idempotent setup skill for bootstrapping dsuo's personal agent environment, AGENTS.md symlinks, and cross-harness lifecycle hooks. Reads declarative ~/dot/hooks.json and maps hooks across detected VCS (Git, Fig/hg, Jujutsu) and agent harnesses (Cursor, Claude Code, Swarm). Safe to run multiple times. Prompts the user when paths or hook locations are ambiguous."
---

# Setup dsuo Personal Agent Environment & Harness Hooks

This skill provides an adaptive, interactive, and **strictly idempotent** workflow to bootstrap and configure Daniel Suo's personal agent environment across workstations, project repositories, version control systems (Git, Fig/hg, Jujutsu), and AI agent harnesses (Cursor, Claude Code, Swarm).

It reads the canonical declarative registry **`~/dot/hooks.json`** and maps those lifecycle events and attached skills into the active systems on the host machine.

---

## 1. Core Principles: Relevance Gating & Strict Idempotency

### A. Strict Relevance Gating (Zero Spurious Configurations)
**Never install configs or hooks for tools that are not active on the host**:
- If Cursor is absent (`~/.cursor` or `cursor` binary not found), **skip Cursor rules completely**; do not create empty `.cursor/` directories.
- If Claude Code / Gemini CLI is absent, skip their config directories.
- If Swarm is absent, skip Swarm instructions.
- If Jujutsu (`jj`) or Fig (`hg`) is absent, skip their respective hook entries.
Only wire up tools that are installed and verified present.

### B. Strict Idempotency (Safe to Re-Run Anytime)
`setup-dsuo` is designed to be **executed repeatedly** (e.g. when you add new hooks or skills to `hooks.json`):
- **Managed Delimiter Blocks**: In shared config files (like `~/.hgrc` or `~/.jjconfig.toml`), `setup-dsuo` only modifies sections wrapped in managed comments:
  ```ini
  # >>> BEGIN DSUO HOOKS (Managed by setup-dsuo - DO NOT EDIT MANUALLY)
  ...
  # <<< END DSUO HOOKS
  ```
- **Preserve User Customizations**: Any user aliases, personal config flags, or custom settings outside the managed block are strictly preserved.
- **Zero Line Duplication**: Re-running `setup-dsuo` updates or replaces the managed block in-place without appending duplicate entries.

---

## 2. Declarative Source of Truth: `~/dot/hooks.json`

The hooks, lifecycle events, and attached skills are defined in `~/dot/hooks.json`:

```json
{
  "version": 1,
  "description": "Declarative lifecycle event hooks and skill mappings for dsuo agent environments",
  "hooks": {
    "on_session_start": {
      "description": "Fires when an agent begins a task; establishes environment readiness",
      "action": "run_doctor",
      "command": "python3 $(find-skills-root)/verify-*/scripts/doctor.sh",
      "fail_mode": "warn"
    },
    "on_pre_review": {
      "description": "Fires before requesting review, uploading a CL, or pushing a branch; gates on verification",
      "action": "verify_tier_2",
      "command": "python3 $(find-skills-root)/verify-*/scripts/verify.py --tier=2",
      "fail_mode": "block"
    },
    "on_user_correction": {
      "description": "Fires when user provides feedback or points out a defect; converts to red regression test",
      "action": "maintain_verification_skill_repro",
      "skill": "maintain-verification-skill",
      "mode": "correction",
      "fail_mode": "prompt"
    },
    "on_change_landed": {
      "description": "Fires after code merges into main or task reaches done; harmonizes feature map",
      "action": "maintain_verification_skill_upkeep",
      "skill": "maintain-verification-skill",
      "mode": "upkeep",
      "fail_mode": "warn"
    }
  },
  "targets": {
    "git": {
      "pre-push": "on_pre_review",
      "post-merge": "on_change_landed"
    },
    "fig": {
      "pre-upload": "on_pre_review",
      "post-sync": "on_change_landed"
    },
    "jujutsu": {
      "upload": "on_pre_review"
    },
    "swarm": {
      "on_task_done": "on_change_landed",
      "on_thread_correction": "on_user_correction"
    },
    "cursor": {
      "pre_review_rule": "on_pre_review",
      "feedback_rule": "on_user_correction"
    }
  }
}
```

---

## 3. Step 1: Detect Active Harnesses & VCS Environments

Inspect the current working directory and host environment:
1. **Version Control Systems (VCS)**:
   - **Git**: Check if `git` is installed and if inside a Git repo (`git rev-parse --show-toplevel`).
   - **Fig / Mercurial (`hg`)**: Check if `hg` or `fig` is installed (`command -v hg`, `~/.hgrc`).
   - **Jujutsu (`jj`)**: Check if `jj` is installed (`command -v jj`, `.jj` directory, `~/.jjconfig.toml`).
2. **AI Agent Harnesses**:
   - **Cursor IDE**: Check for `~/.cursor`, `.cursor/rules/`, or `cursor` binary.
   - **Claude Code / Coding Assistants**: Check for `~/.claude/`, `~/.gemini/config/`, or `claude` binary.
   - **Swarm / Beekeeper**: Check for `~/.config/swarm/`, `prototypes/gdm/beekeeper/`, or running swarm supervisor.
3. **Dotfiles Root**: Locate `~/dot/` and read `~/dot/hooks.json`.

---

## 4. Step 2: Establish Directives & System Prompt Symlinks

For each **detected** agent harness, ensure that `AGENTS.md` (the supreme behavioral doctrine) is dynamically linked:

1. **Swarm Supervisor** (if Swarm present):
   - Target: `~/.config/swarm/instructions.md`
   - Action: Symlink to `~/dot/AGENTS.md` (or copy if cross-filesystem).
2. **Cursor IDE** (if Cursor present):
   - Target: `.cursor/rules/dsuo-mode.mdc` or `~/.cursor/rules/dsuo-mode.mdc`
   - Action: Create rule file referencing `~/dot/AGENTS.md`.
3. **Claude Code / Coding Assistants** (if Claude present):
   - Target: `~/.gemini/config/AGENTS.md` or `.claude/AGENTS.md`
   - Action: Symlink to `~/dot/AGENTS.md`.

---

## 5. Step 3: Map `hooks.json` to Detected Systems

`setup-dsuo` reads the `targets` block in `~/dot/hooks.json` and generates the corresponding hooks idempotently:

### A. Git Lifecycle Hooks (if Git repo detected)
- **Local Pre-Push Gate (`.git/hooks/pre-push`)**:
  - Mapped to `hooks.json` target `git.pre-push` (`on_pre_review`).
  - Runs Tier 2 local verification (`python3 scripts/verify.py --tier=2` or project native test runner) before pushing code.
- **Local Post-Merge Upkeep (`.git/hooks/post-merge`)**:
  - Mapped to `hooks.json` target `git.post-merge` (`on_change_landed`).
  - Automatically triggers `maintain-verification-skill` whenever upstream changes are merged into `main`.

### B. Fig / Mercurial (`hg`) Hooks (if Fig/hg detected)
In `~/.hgrc` (using managed delimiter blocks):
```ini
# >>> BEGIN DSUO HOOKS (Managed by setup-dsuo - DO NOT EDIT MANUALLY)
[hooks]
# Tier 2 pre-review verification gate before uploading a changelist
pre-upload = python3 $(find-skills-root)/verify-*/scripts/verify.py --tier=2

# Post-sync upkeep when pulling mainline updates
post-sync = python3 $(find-skills-root)/maintain-verification-skill/scripts/maintain.py --mode=upkeep
# <<< END DSUO HOOKS
```

### C. Jujutsu (`jj`) Hooks & Aliases (if jj detected)
1. **Colocated Git Backend**: In Git-colocated repositories (`jj` with a `.git` store), `jj git push` automatically respects `.git/hooks/pre-push`.
2. **Alias Wrapper**: In `~/.jjconfig.toml` (using managed delimiter blocks):
```toml
# >>> BEGIN DSUO HOOKS (Managed by setup-dsuo - DO NOT EDIT MANUALLY)
[aliases]
# Tier 2 verification gate before uploading or pushing
upload = ["util", "exec", "--", "bash", "-c", "python3 $(find-skills-root)/verify-*/scripts/verify.py --tier=2 && jj piper upload \"$@\"", "--"]
# <<< END DSUO HOOKS
```

### D. Cursor & Claude Code Hooks (if detected)
- Configures rules in `.cursor/rules/` to trigger `verify-<app>` on task completion and `maintain-verification-skill` on user feedback.

### E. Swarm / Beekeeper Supervisor Hooks (if detected)
- Confirms supervisor follow-up hooks in `task_followups.rs` dispatch maintenance when tasks transition to `done`.

---

## 6. Arbitrary Custom Hooks & Dynamic Extensions

`hooks.json` is not constrained to fixed events. Users can register **arbitrary custom lifecycle hooks**:

```json
{
  "hooks": {
    "on_build_failure": {
      "description": "Fires when local compiler or build action fails",
      "action": "auto_diagnose",
      "command": "python3 $(find-skills-root)/diagnose-build/run.py"
    },
    "on_schema_migration": {
      "description": "Fires when database schema or SDL files are modified",
      "action": "validate_schema_parity",
      "command": "python3 $(find-skills-root)/verify-*/scripts/parity_check.py"
    }
  }
}
```

Whenever custom hooks are defined in `hooks.json`, `setup-dsuo` dynamically attaches them to the corresponding tool targets (e.g. build wrappers, git pre-commit, or IDE editor events).

---

## 7. How `setup-dsuo` is Triggered (Agent Skill, Not a Shell Script)

`setup-dsuo` is strictly an **agent skill and procedural playbook**, not an executable binary or shell script. It is invoked and executed by the AI agent in two ways:

1. **Agent Self-Sync (On Configuration Changes)**:
   - Whenever an agent modifies `~/dot/hooks.json` or `~/dot/AGENTS.md`, the agent is **mandated to immediately execute the `setup-dsuo` procedure** as the conclusion of that turn, ensuring all local VCS hooks and IDE symlinks remain synchronized without human intervention.

2. **Explicit User Request / Slash Command**:
   - The user asks an agent to run `/setup-dsuo`, *"set up my agent environment"*, or *"sync my hooks"*.
   - The agent reads `~/dot/hooks.json`, inspects the current repository, and performs the idempotent mappings.

---

## 8. Step 4: Mandatory User Prompt Gate (When Ambiguous)

Do **NOT** guess or hardcode speculative paths. If any of the following are true, **pause and prompt the user**:
- Multiple candidate repositories, workspaces, or client roots exist.
- A tool's configuration directory (e.g. Cursor, Claude, jj, or Swarm) is non-standard.
- Target hooks or config files already exist with custom human modifications without managed delimiters (ask before editing).
- The user's preferred skills directory (`_agents/skills` vs `.cursor/skills` vs `.skills`) is ambiguous.

### Prompt Template:
> *"I am configuring your personal agent environment from ~/dot/hooks.json. I detected [detected harnesses and VCS: e.g. Git, Jujutsu, Swarm], but [ambiguous item, e.g. location of jj config or target repository root] is ambiguous. Where would you like me to install [item]?"*

---

## 9. Step 5: Verification & Health Check

1. Run `find-skills-root` and confirm the skills directory resolves cleanly.
2. Verify that `AGENTS.md` is readable from each configured harness location.
3. Verify that configured Git/Fig/jj hooks are executable and test their dry-run.
4. Report a clear summary of all configured symlinks, rules, and hooks to the user.
