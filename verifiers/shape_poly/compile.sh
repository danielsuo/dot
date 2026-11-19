#!/bin/bash
set -euo pipefail
WORKSPACE_ROOT="${WORKSPACE_ROOT:-/google/src/files/head/depot/google3}"
cd "${WORKSPACE_ROOT}"
/google/bin/releases/peninsula-laze-cli/laze build //prototypes/gdm/users/dsuo/jax/aot/...
