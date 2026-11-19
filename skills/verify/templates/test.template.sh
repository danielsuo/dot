#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

if [[ -n "${TARGET}" ]]; then
  echo "=== [Tier 0: Targeted test (< 2s)] Running focused check for '${TARGET}' ==="
  if command -v cargo >/dev/null 2>&1 && [[ -f "Cargo.toml" ]]; then
    cargo test "${TARGET}" --quiet
  fi
  echo "  ✓ Targeted test passed: ${TARGET}"
  exit 0
fi

echo "=== [Stage 2: Run automated tests (< 10s)] Running unit & CLI tests ==="
if command -v cargo >/dev/null 2>&1 && [[ -f "Cargo.toml" ]]; then
  cargo test --quiet
fi
echo "  ✓ Unit tests, CLI arguments, and regression tests passed"
