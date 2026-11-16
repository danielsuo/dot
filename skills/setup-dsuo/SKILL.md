---
name: setup-dsuo
description: "Adaptive setup skill for bootstrapping dsuo's personal agent environment, AGENTS.md symlinks, and cross-harness lifecycle hooks across workstations, repositories, and VCS/agent harnesses (Git, Fig/Mercurial, Jujutsu, Cursor, Claude Code, Swarm). Strictly relevance-gated: only installs hooks for detected tools. Prompts the user when paths or hook locations are ambiguous."
---

# Setup dsuo Personal Agent Environment & Harness Hooks

This skill provides an adaptive, interactive workflow to bootstrap and configure Daniel Suo's personal agent environment across workstations, project repositories, version control systems (Git, Fig/hg, Jujutsu), and AI agent harnesses (Cursor, Claude Code, Swarm).

Rather than relying on a rigid, brittle automation script, this skill is run adaptively by an agent who inspects the active environment, configures symlinks and hooks, and **prompts the user whenever a path or configuration location is ambiguous**.

---

## 1. Core Rule: Strict Relevance Gating (Zero Spurious Configurations)

**Never install configs or hooks for tools that are not active on the host**:
- If Cursor is absent (`~/.cursor` or `cursor` binary not found), **skip Cursor rules completely**; do not create empty `.cursor/` directories.
- If Claude Code / Gemini CLI is absent, skip their config directories.
- If Swarm is absent, skip Swarm instructions.
- If Jujutsu (`jj`) or Fig (`hg`) is absent, skip their respective hook entries.
Only wire up tools that are installed and verified present.

---

## 2. Step 1: Detect Active Harnesses & VCS Environments

Inspect the current working directory and host environment:
1. **Version Control Systems (VCS)**:
   - **Git**: Check if `git` is installed and if inside a Git repo (`git rev-parse --show-toplevel`).
   - **Fig / Mercurial (`hg`)**: Check if `hg` or `fig` is installed (`command -v hg`, `~/.hgrc`).
   - **Jujutsu (`jj`)**: Check if `jj` is installed (`command -v jj`, `.jj` directory, `~/.jjconfig.toml`).
2. **AI Agent Harnesses**:
   - **Cursor IDE**: Check for `~/.cursor`, `.cursor/rules/`, or `cursor` binary.
   - **Claude Code / Coding Assistants**: Check for `~/.claude/`, `~/.gemini/config/`, or `claude` binary.
   - **Swarm / Beekeeper**: Check for `~/.config/swarm/`, `prototypes/gdm/beekeeper/`, or running swarm supervisor.
3. **Dotfiles Root**: Locate `~/dot/` or check `DOTFILES_ROOT`.

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
   - Target: `~/.gemini/config/AGENTS.md` or `.claude/AGENTS.md`
   - Action: Symlink to `~/dot/AGENTS.md`.

---

## 4. Step 3: Configure Cross-Harness Lifecycle Hooks

Wire the Universal Lifecycle Hooks (`on_session_start`, `on_pre_review`, `on_user_correction`, `on_change_landed`) into detected VCS and agent tools:

### A. Git Lifecycle Hooks (if Git repo detected)
- **Local Pre-Push Gate (`.git/hooks/pre-push`)**:
  - Runs Tier 2 local verification (`python3 scripts/verify.py --tier=2` or project native test runner) before pushing code to remote branches.
- **Local Post-Merge Upkeep (`.git/hooks/post-merge`)**:
  - Automatically triggers `maintain-verification-skill` whenever upstream changes are merged into `main`.
- **Global Alternative (`git config --global core.hooksPath ~/.config/git/hooks/`)**:
  - Allows managing hooks globally across all repositories on the workstation.

### B. Fig / Mercurial (`hg`) Hooks (if Fig/hg detected)
In `~/.hgrc` (or local repo `.hg/hgrc`):
```ini
[hooks]
# Tier 2 pre-review verification gate before uploading a changelist
pre-upload = python3 $(find-skills-root)/verify-*/scripts/verify.py --tier=2

# Post-sync upkeep when pulling mainline updates
post-sync = python3 $(find-skills-root)/maintain-verification-skill/scripts/maintain.py --mode=upkeep
```

### C. Jujutsu (`jj`) Hooks & Aliases (if jj detected)
1. **Colocated Git Backend**: In Git-colocated repositories (`jj` with a `.git` store), `jj git push` automatically respects `.git/hooks/pre-push`.
2. **Alias Wrapper**: In `~/.jjconfig.toml` (or `~/.config/jj/config.toml`):
```toml
[aliases]
# Tier 2 verification gate before uploading or pushing
upload = ["util", "exec", "--", "bash", "-c", "python3 $(find-skills-root)/verify-*/scripts/verify.py --tier=2 && jj piper upload \"$@\"", "--"]
```

### D. Cursor & Claude Code Hooks (if detected)
- Configures rules in `.cursor/rules/` to trigger `verify-<app>` on task completion and `maintain-verification-skill` on user feedback.

### E. Swarm / Beekeeper Supervisor Hooks (if detected)
- Confirms supervisor follow-up hooks in `task_followups.rs` dispatch maintenance when tasks transition to `done`.

---

## 5. Step 4: Mandatory User Prompt Gate (When Ambiguous)

Do **NOT** guess or hardcode speculative paths. If any of the following are true, **pause and prompt the user**:
- Multiple candidate repositories, workspaces, or client roots exist.
- A tool's configuration directory (e.g. Cursor, Claude, jj, or Swarm) is non-standard.
- Target hooks or config files already exist with custom human modifications (ask before overwriting).
- The user's preferred skills directory (`_agents/skills` vs `.cursor/skills` vs `.skills`) is ambiguous.

### Prompt Template:
> *"I am configuring your personal agent environment. I detected [detected harnesses and VCS: e.g. Git, Jujutsu, Swarm], but [ambiguous item, e.g. location of jj config or target repository root] is ambiguous. Where would you like me to install [item]?"*

---

## 6. Step 5: Verification & Health Check

1. Run `find-skills-root` and confirm the skills directory resolves cleanly.
2. Verify that `AGENTS.md` is readable from each configured harness location.
3. Verify that configured Git/Fig/jj hooks are executable and test their dry-run.
4. Report a clear summary of all configured symlinks, rules, and hooks to the user.
