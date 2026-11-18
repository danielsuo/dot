# Impromptu Verification Instructions & Invariants

## Architecture & Boundaries
- Open-source core (`src/`): Zero internal Google or Beekeeper dependencies.
- Google internal code (`google/src/`): Pure extensions (Beyond Stubby RPC, Beekeeper bridge).
- Consolidated integration test: `tests/impromptu_test.rs`.

## Verification Stages
- Stage 1: Fast compilation check (`verify-cmd compile`, < 2s).
- Stage 2: Automated unit & integration tests (`verify-cmd test`, < 10s).
- Tier 0: Focused targeted testing (`verify-cmd test <target>`, < 2s).
- Stage 2b: Diff-scoped mutation testing (`verify-cmd mutants`).
- Stages 3-5: Agentic verification against `features/impromptu.md`.
