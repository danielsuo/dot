#!/usr/bin/env bash
# Stage 2b: Diff-scoped mutation & oracle sensitivity verification
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
echo "=== [Stage 2b: Mutation & oracle sensitivity] Verifying fault injection kills ==="
/google/bin/releases/peninsula-laze-cli/laze test \
  --test_env=SDY_ALLOW_DYNAMIC_DIMS=1 \
  --test_filter="*mutation_sensitivity*" \
  //prototypes/gdm/users/dsuo/jax/aot:partir_shardy_poly_transformer_test
echo "  ✓ All injected shape-refinement, aliasing, and HLO/numerical mutants killed"
