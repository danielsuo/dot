---
name: setup-dsuo
description: "Adaptive setup skill for bootstrapping dsuo's personal agent environment, AGENTS.md symlinks, and cross-harness lifecycle hooks across workstations, repositories, and agent harnesses (Git, Cursor, Claude Code, Swarm). Prompts the user when paths or hook locations are ambiguous."
---

# Setup dsuo Personal Agent Environment & Harness Hooks

This skill provides an adaptive, interactive workflow to bootstrap and configure Daniel Suo's personal agent environment across workstations, project repositories, and AI agent harnesses (Cursor, Claude Code, Git, and Swarm).

Rather than relying on a rigid, brittle automation script, this skill is run adaptively by an agent who inspects the active environment, configures symlinks and hooks, and **prompts the user whenever a path or configuration location is ambiguous**.

---

## 1. Step 1: Detect Active Harnesses & Environment

Inspect the current working directory and host environment:
1. **Git Repository**: Check if the current directory or parent is inside a git repository (`git rev-parse --show-toplevel`).
2. **Cursor IDE**: Check for `~/.cursor`, `.cursor/rules/`, or `.cursorrules`.
3. **Claude Code / Gemini CLI**: Check for `~/.claude/`, `~/.gemini/config/`, or local agent configs.
4. **Swarm / Beekeeper**: Check for `~/.config/swarm/`, `prototypes/gdm/beekeeper/`, or running swarm supervisor.
5. **Dotfiles Root**: Locate `~/dot/` or check `DOTFILES_ROOT`.

---

## 2. Step 2: Establish Directives & System Prompt Symlinks

Ensure that `AGENTS.md` (the supreme behavioral doctrine) is dynamically linked into all active agent harnesses:

1. **Swarm Supervisor**:
   - Target: `~/.config/swarm/instructions.md`
   - Action: Symlink to `~/dot/AGENTS.md` (or copy if cross-filesystem).
2. **Cursor IDE**:
   - Target: `.cursor/rules/dsuo-mode.mdc` or `~/.cursor/rules/dsuo-mode.mdc`
   - Action: Create rule file importing or referencing `~/dot/AGENTS.md`.
3. **Claude Code / Coding Assistants**:
   - Target: `~/.gemini/config/AGENTS.md` or `.claude/AGENTS.md`
   - Action: Symlink to `~/dot/AGENTS.md`.

---

## 3. Step 3: Configure Cross-Harness Lifecycle Hooks

Set up the Universal Lifecycle Hooks (`on_session_start`, `on_pre_review`, `on_user_correction`, `on_change_landed`):

1. **Git Repository Hooks**:
   - Target: `.git/hooks/pre-push`
     - Action: Invokes Tier 2 local verification (`python3 scripts/verify.py --tier=2` or project native test runner) to prevent pushing broken code.
   - Target: `.git/hooks/post-merge`
     - Action: Invokes `maintain-verification-skill` whenever code merges into `main`.
2. **Cursor / Claude Code Hooks**:
   - Configure rule triggers to invoke `verify-<app>` on task completion and `maintain-verification-skill` on user feedback.
3. **Swarm / Beekeeper Supervisor Hooks**:
   - Verify supervisor post-task follow-up hooks in `task_followups.rs` are active for automatic maintenance when tasks reach `done`.

---

## 4. Step 4: Mandatory User Prompt Gate (When Ambiguous)

Do **NOT** guess or hardcode speculative paths. If any of the following are true, **pause and prompt the user**:
- Multiple candidate repositories or workspaces exist.
- A tool's configuration directory (e.g. Cursor, Claude, or Swarm) is in a non-standard location.
- Hook targets already exist with custom human modifications (ask before overwriting).
- The user's preferred skills directory (`_agents/skills` vs `.cursor/skills` vs `.skills`) is ambiguous.

### Prompt Template:
> *"I am configuring your personal agent environment. I detected [detected harnesses], but [ambiguous item, e.g. location of Cursor rules or target repository root] is ambiguous. Where would you like me to install [item]?"*

---

## 5. Step 5: Verification & Health Check

1. Run `find-skills-root` and confirm the skills directory resolves cleanly.
2. Verify that `AGENTS.md` is readable from each configured harness location.
3. Run `scripts/doctor.sh` if a verification skill is present.
4. Report a clear summary of all configured symlinks, rules, and hooks to the user.
