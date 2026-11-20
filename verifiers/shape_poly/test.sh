#!/bin/bash
set -euo pipefail

if [[ -z "${WORKSPACE_ROOT:-}" ]]; then
  if [[ "${PWD}" == */google3* ]]; then
    WORKSPACE_ROOT="${PWD%%/google3*}/google3"
  elif [[ -d "/google/src/cloud/dsuo/worker3_task_1678/google3" ]]; then
    WORKSPACE_ROOT="/google/src/cloud/dsuo/worker3_task_1678/google3"
  else
    WORKSPACE_ROOT="/google/src/files/head/depot/google3"
  fi
fi

cd "${WORKSPACE_ROOT}"

TARGET="${1:-}"
if [[ -n "${TARGET}" ]]; then
  echo "=== [Tier 0: Targeted test] Running focused check for '${TARGET}' ==="
  /google/bin/releases/peninsula-laze-cli/laze test \
    --test_env=SDY_ALLOW_DYNAMIC_DIMS=1 \
    "${TARGET}"
  echo "  ✓ Targeted test passed: ${TARGET}"
  exit 0
fi

echo "=== [Stage 2: Run automated tests] Running shape_poly + PartIR/Shardy MPMD suites ==="
/google/bin/releases/peninsula-laze-cli/laze test \
  --test_env=SDY_ALLOW_DYNAMIC_DIMS=1 \
  //prototypes/gdm/users/dsuo/jax/aot:poly_refine_compile_test \
  //prototypes/gdm/deployment/poly_config_export:poly_prefill_test \
  //prototypes/gdm/users/dsuo/jax/aot:partir_shardy_poly_transformer_test
echo "  ✓ All shape_poly & PartIR/Shardy MPMD verification suites passed"
