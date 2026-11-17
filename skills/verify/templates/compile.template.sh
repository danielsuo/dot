#!/usr/bin/env bash
set -euo pipefail

echo "=== [Stage 1: Compile code (< 2s)] Checking compile and syntax ==="

# Project compile command (e.g. cargo check, tsc --noEmit, python3 -m py_compile)
if command -v cargo >/dev/null 2>&1 && [[ -f "Cargo.toml" ]]; then
  cargo check --quiet
elif command -v tsc >/dev/null 2>&1 && [[ -f "tsconfig.json" ]]; then
  tsc --noEmit
fi

echo "  ✓ Compile and syntax checks passed"
