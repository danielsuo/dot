#!/bin/bash
set -euo pipefail
WORKSPACE_ROOT="${WORKSPACE_ROOT:-/google/src/files/head/depot/google3}"
cd "${WORKSPACE_ROOT}"

TARGET="${1:-}"
if [[ -n "${TARGET}" ]]; then
  echo "=== [Tier 0: Targeted test] Running focused check for '${TARGET}' ==="
  /google/bin/releases/peninsula-laze-cli/laze test "${TARGET}"
  echo "  ✓ Targeted test passed: ${TARGET}"
  exit 0
fi

echo "=== [Stage 2: Run automated tests] Running shape_poly tests ==="
/google/bin/releases/peninsula-laze-cli/laze test //prototypes/gdm/users/dsuo/jax/aot:poly_refine_compile_test
echo "  ✓ All fast tests passed"
