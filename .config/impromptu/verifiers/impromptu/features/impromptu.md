# Feature: Impromptu & Blimp Agent Harness

## Capabilities

1. `imp`: Open-source CLI harness providing one-shot prompt execution (`-p`) and interactive REPL (`-i`).
2. `blimp`: Google-internal Beekeeper child process bridge (`--agent-bin`) forwarding all `imp` flags via `clap` flattening and connecting to real Gemini models via Beyond Stubby RPC.
3.  `maybe_build_system_prompt`: Reactive system prompt ingestion reading
    `~/.config/impromptu/agents.md` with mtime-based reactive disk cache
    invalidation.

## User Paths

- Standalone CLI: `imp -p "What is the capital of Japan?"`
- Interactive REPL: `imp -i`
-   Interactive Beekeeper Bridge: `blimp --id <ID> --board <HOST:PORT> -i`
- Beekeeper Supervisor: `blimp --id <ID> --board <HOST:PORT> --model gemini-flash-next --prompt "..."`

## Assertions

1. `imp` has zero dependencies on Google-internal code or Beekeeper.
2. `blimp` exposes 100% of flags defined in `imp`.
3. `blimp --dry-run` validates arguments and exits cleanly with code 0.
4.  `blimp -i` runs an interactive REPL reading from stdin until `exit` or
    `quit`.
5.  `BeyondBackend` maps `gemini-flash-next` to live
    `models/gemini-3-flash-preview` and returns real tokens.
6.  `maybe_build_system_prompt()` reloads the prompt when disk mtime advances
    and caches with 0ms overhead when unchanged.
7.  Sentinel file (`SWARM_STOP_FILE`) triggers immediate graceful termination.
