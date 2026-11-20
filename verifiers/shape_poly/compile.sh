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
/google/bin/releases/peninsula-laze-cli/laze build \
  //prototypes/gdm/users/dsuo/jax/aot/... \
  //prototypes/gdm/deployment/poly_config_export:poly_prefill_test \
  //prototypes/gdm/deployment/poly_config_export:mpmd_refine_main \
  //prototypes/gdm/deployment/poly_config_export:fragment_compile_main
