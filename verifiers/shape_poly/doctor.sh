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

test -x /google/bin/releases/peninsula-laze-cli/laze || {
  echo "Missing /google/bin/releases/peninsula-laze-cli/laze" >&2
  exit 1
}
test -f "${WORKSPACE_ROOT}/prototypes/gdm/users/dsuo/jax/aot/partir_shardy_poly_transformer_test.py" || {
  echo "Missing partir_shardy_poly_transformer_test.py in ${WORKSPACE_ROOT}" >&2
  exit 1
}
test -f "${WORKSPACE_ROOT}/prototypes/gdm/deployment/poly_config_export/mpmd_refine.py" || {
  echo "Missing poly_config_export/mpmd_refine.py in ${WORKSPACE_ROOT}" >&2
  exit 1
}
echo "shape_poly environment OK (WORKSPACE_ROOT=${WORKSPACE_ROOT})"
