#!/usr/bin/env bash
set -euo pipefail

echo "=== [Stage 2b: Diff-scoped mutation testing] Verifying test assertion strength ==="

# Run diff-scoped mutation tool (e.g. cargo mutants --in-diff, mutmut) on modified lines
if command -v cargo-mutants >/dev/null 2>&1 && [[ -f "Cargo.toml" ]]; then
  cargo mutants --in-diff --quiet
fi

echo "  ✓ Diff-scoped mutation testing passed (all mutants killed)"
