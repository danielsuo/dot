---
name: setup-dsuo
description: "Adaptive, idempotent setup skill for bootstrapping dsuo's personal agent environment, skills directories, and AGENTS.md symlinks. Detects active agent harnesses (Cursor, Claude Code, Swarm) and configures them to discover and execute personal and project skills seamlessly. Safe to run multiple times."
---

# Setup dsuo Personal Agent Environment & Skills

This skill provides an adaptive, interactive, and **strictly idempotent** workflow to bootstrap and configure Daniel Suo's personal agent environment across workstations, project repositories, and AI agent harnesses (Cursor, Claude Code, Swarm, Gemini CLI).

Its primary objective is to **make agent skills work seamlessly and reliably everywhere** by discovering active harnesses, creating necessary skill directory symlinks, configuring `AGENTS.md` behavioral doctrine, and ensuring health check diagnostics pass cleanly.

---

## 1. Core Principles: Relevance Gating & Strict Idempotency

### A. Strict Relevance Gating (Zero Spurious Configurations)
**Never install configs or rules for tools that are not active on the host**:
- If Cursor is absent (`~/.cursor` or `cursor` binary not found), **skip Cursor rules completely**; do not create empty `.cursor/` directories.
- If Claude Code / Gemini CLI is absent, skip their config directories.
- If Swarm / Beekeeper is absent, skip Swarm instructions.
Only configure tools that are installed and verified present.

### B. Strict Idempotency (Safe to Re-Run Anytime)
`setup-dsuo` is designed to be **executed repeatedly**:
- **Preserve User Customizations**: Any user rules, personal config flags, or custom settings are strictly preserved.
- **Symlink Idempotency**: Creates or refreshes symlinks using `ln -sfn` without creating nested symlinks or duplicating entries.

---

## 2. Step 1: Detect Active Harnesses & Skills Locations

Inspect the host environment and current working directory:
1. **AI Agent Harnesses**:
   - **Cursor IDE**: Check for `~/.cursor/`, `.cursor/rules/`, or `cursor` binary.
   - **Claude Code**: Check for `~/.claude/` or `claude` binary.
   - **Gemini CLI / Jetski**: Check for `~/.gemini/config/` or `gemini` binary.
   - **Swarm / Beekeeper**: Check for `~/.config/swarm/`, `prototypes/gdm/beekeeper/`, or running swarm supervisor.
2. **Skills Roots**:
   - User central skills root: `~/.config/skills/`
   - Personal dotfiles skills root: `~/dot/skills/`
   - Project repository skills root: `./skills/`, `._agents/skills/`, or `.cursor/skills/`

---

## 3. Step 2: Establish Directives & System Prompt Symlinks

For each **detected** agent harness, ensure that `AGENTS.md` (the supreme behavioral doctrine) is dynamically linked:

1. **Swarm Supervisor** (if Swarm present):
   - Target: `~/.config/swarm/instructions.md`
   - Action: Symlink to `~/dot/AGENTS.md` (or copy if cross-filesystem).
2. **Cursor IDE** (if Cursor present):
   - Target: `.cursor/rules/dsuo-mode.mdc` or `~/.cursor/rules/dsuo-mode.mdc`
   - Action: Create rule file referencing `~/dot/AGENTS.md`.
3. **Claude Code / Coding Assistants** (if Claude present):
   - Target: `~/.claude/AGENTS.md` or `~/.gemini/config/AGENTS.md`
   - Action: Symlink to `~/dot/AGENTS.md`.

---

## 4. Step 3: Wire Skill Discovery Across Harnesses

Ensure that each active harness knows where to discover personal and project skills:

1. **Personal Skills Symlink**:
   - Ensure `~/.config/skills/` contains symlinks to `~/dot/skills/*` (`setup-dsuo`, `ensure-verification-skill`).
2. **Cursor Integration**:
   - In Cursor workspaces, ensure `.cursor/rules/` references the active project skills or symlinks `skills/` if the project uses a custom directory.
3. **Claude Code / Gemini CLI Integration**:
   - Ensure `~/.claude/skills/` or `~/.gemini/skills/` includes symlinks to personal skills so slash commands and tool lookups resolve instantly.

---

## 5. Step 4: Mandatory User Prompt Gate (When Ambiguous)

Do **NOT** guess or hardcode speculative paths. If any of the following are true, **pause and prompt the user**:
- Multiple candidate repositories, workspaces, or client roots exist.
- A tool's configuration directory (e.g. Cursor, Claude, or Swarm) is non-standard.
- The user's preferred skills directory (`skills/` vs `_agents/skills` vs `.cursor/skills`) is ambiguous.

### Prompt Template:
> *"I am configuring your personal agent environment. I detected [detected harnesses: e.g. Cursor, Swarm], but [ambiguous item, e.g. target skills directory] is ambiguous. Where would you like me to install [item]?"*

---

## 6. Step 5: Verification & Health Check

1. Run `find-skills-root` and confirm the skills directory resolves cleanly to the intended root.
2. Verify that `AGENTS.md` is readable from each configured harness location.
3. Verify that `skill-stats` runs cleanly and reports telemetry from `~/.config/skills/usage.jsonl`.
4. Report a clear summary of all configured symlinks and active skills to the user.

