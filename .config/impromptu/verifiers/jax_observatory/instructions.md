# JAX Observatory Verification Instructions & Invariants

## Architecture & Boundaries
- Rust dashboard server: Fast queries (< 50ms) across 113M+ jobs and 3M+ experiments.
- Scrubber & Horizon series: Zero fleet leakage, strict parity between daily and horizon series.
- Filtered metrics: Must match fleet bounds and pass consistency checks.

## Verification Stages
- Pre-flight: `verify-cmd doctor` (standalone health check).
- Stage 1: Fast compilation check (`verify-cmd compile`, < 2s).
- Stage 2: Automated tests (`verify-cmd test`, < 10s).
- Tier 0: Targeted testing (`verify-cmd test <target>`, < 2s).
- Stage 2b: Diff-scoped mutation testing (`verify-cmd mutants`).
- Stages 3-5: Agentic verification against `features/data-accuracy-and-sources.md`.
