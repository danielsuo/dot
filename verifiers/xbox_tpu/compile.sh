#!/usr/bin/env bash
# Stage 1: Build Xbox TPU chip lease module, gVisor subset adapter, and mlebench image shims
set -euo pipefail

echo "=== [Stage 1: Compile] Building Xbox TPU targets via blaze-for-agents ==="

WS="${WORKSPACE_ROOT:-$(pwd)}"
if [[ -f "${WS}/assistant/boq/lamda/execution_box/service/tpu/BUILD" ]]; then
  cd "${WS}"
  /google/bin/releases/arca9-local-blaze-cli/blaze-for-agents build \
    //assistant/boq/lamda/execution_box/service/tpu:tpu_chip_lease_module \
    //assistant/boq/lamda/execution_box/sandbox:gvisor_sandbox_adapter \
    //learning/gemini/rex/projects/code/jetski_agent/contrib/mlebench/xbox_image:sitecustomize_test
elif [[ -f "${WS}/cloud/gvisor/api/gvisor_sandbox.cc" ]] && grep -q "wait_for_first_available_tpu" "${WS}/cloud/gvisor/api/gvisor_sandbox.cc"; then
  cd "${WS}"
  /google/bin/releases/arca9-local-blaze-cli/blaze-for-agents build \
    //cloud/gvisor/api:gvisor_sandbox \
    //cloud/gvisor/sentry:sentry \
    //assistant/boq/lamda/execution_box/sandbox:gvisor_sandbox_adapter
else
  WS="/google/src/cloud/dsuo/xbox_hard_isolation/google3"
  cd "${WS}"
  /google/bin/releases/arca9-local-blaze-cli/blaze-for-agents build \
    //assistant/boq/lamda/execution_box/service/tpu:tpu_chip_lease_module \
    //assistant/boq/lamda/execution_box/sandbox:gvisor_sandbox_adapter \
    //learning/gemini/rex/projects/code/jetski_agent/contrib/mlebench/xbox_image:sitecustomize_test
fi

echo "  ✓ Compile passed (${WS})"
