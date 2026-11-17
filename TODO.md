# TODO & Future Architecture Roadmap

## Event-Driven Agent Harness Architecture

An exploration into building an ambient, programmable event-driven harness that bridges repository events (VCS, filesystem, task lifecycle) with agent skills and deterministic verification.

### 1. Programmable Event Reactor
- **Decoupled Event Bus**: An open-ended topic hierarchy (`vcs/pre-commit`, `git/post-merge`, `file/changed`, `test/failed`, `user/correction`).
- **Structured Events**: Emitters (`emit-hook`) publish JSON payloads with topic, source, timestamp, and correlation IDs without blocking developer workflows.
- **Configurable Debounce & Filtering**: Groups rapid bursts of file modifications or git operations before dispatching downstream actions.

### 2. Dual-Execution Substrate (Scripts vs. Warm Agents)
- **Mode 1: Deterministic Local Execution (Zero LLM Overhead)**
  - For verification scripts (`verify.py`, `doctor.sh`, `cargo test`), actions run directly as native subshell commands.
  - **Latency**: Sub-second (<100ms). **Cost**: 0 LLM tokens.
- **Mode 2: Agentic Skills via Pluggable CLIs / Warm Workers**
  - For cognitive skills requiring reasoning (`maintain-verification-skill`, `create-verification-skill`), the harness avoids cold-start agent boots by delegating to:
    - **Headless Agent CLIs**: Invoking `claude -p "..."` or `gemini -p "..."` using their existing toolsets, system prompts, and execution environments.
    - **Warm Multi-Agent Pools**: Assigning tasks to already-running worker pools in swarm environments (e.g. Beekeeper) without spinning up cold processes.

### 3. Bidirectional Feedback Loop
- **Synchronous Gating**: Blocks invalid VCS operations (`pre-push`, `pre-upload`) with non-zero exit codes and actionable failure logs directly in the terminal.
- **Asynchronous Updates**: Streams background task progress and artifact links directly to collaborative task boards and threads.
- **Unified Telemetry**: Centralized usage and latency tracking logged to `~/.config/skills/usage.jsonl` for offline auditing via `skill-stats`.

### 4. Reference Implementations & Proven Rust Foundations
Rather than building an event reactor or watcher from scratch, future iterations should leverage established tools:
- **File Watching & Process Execution**: [`watchexec`](https://github.com/watchexec/watchexec) / [`cargo-watch`](https://github.com/watchexec/cargo-watch)
- **High-Performance Git Hooks**: [`lefthook`](https://github.com/evilmartians/lefthook)
- **In-Process Async Message Bus**: `tokio::sync::broadcast` / `bus`
- **Lightweight Local Pub/Sub**: `zenoh` / `rumqttd`

### 5. Declarative Hook Schema (`hooks.json` Specification)
Archived schema for declarative lifecycle event hooks and skill mappings across VCS and agent harnesses:

```json
{
  "version": 1,
  "description": "Declarative lifecycle event hooks and skill mappings for agent environments",
  "hooks": {
    "on_session_start": {
      "description": "Fires when an agent begins a task or session; establishes environment readiness",
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

