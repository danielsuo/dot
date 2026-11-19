#!/usr/bin/env bash
# Stage 2: Unit tests + audit-model-trajectories HTML renderer self-test
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WS="${WORKSPACE_ROOT:-$(pwd)}"
MODE="lease"
if [[ -f "${WS}/assistant/boq/lamda/execution_box/service/tpu/BUILD" ]]; then
  MODE="lease"
elif [[ -f "${WS}/cloud/gvisor/api/gvisor_sandbox.cc" ]] && grep -q "wait_for_first_available_tpu" "${WS}/cloud/gvisor/api/gvisor_sandbox.cc"; then
  MODE="gvisor_flock"
else
  WS="/google/src/cloud/dsuo/xbox_hard_isolation/google3"
  MODE="lease"
fi

TARGET="${1:-}"
if [[ -n "${TARGET}" ]]; then
  echo "=== [Tier 0: Targeted test] Running '${TARGET}' in ${WS} ==="
  cd "${WS}"
  /google/bin/releases/arca9-local-blaze-cli/blaze-for-agents test "${TARGET}"
  exit 0
fi

echo "=== [Stage 2: Automated tests] Running Xbox TPU unit suites (${MODE}) & trajectory audit self-test ==="
cd "${WS}"
if [[ "${MODE}" == "gvisor_flock" ]]; then
  /google/bin/releases/arca9-local-blaze-cli/blaze-for-agents test \
    //cloud/gvisor/api:gvisor_sandbox_test \
    //assistant/boq/lamda/execution_box/sandbox:gvisor_sandbox_adapter_test
else
  /google/bin/releases/arca9-local-blaze-cli/blaze-for-agents test \
    //assistant/boq/lamda/execution_box/service/tpu:tpu_chip_lease_module_test \
    //assistant/boq/lamda/execution_box/sandbox:gvisor_sandbox_adapter_test \
    //learning/gemini/rex/projects/code/jetski_agent/contrib/mlebench/xbox_image:sitecustomize_test
fi

python3 -P "${SCRIPT_DIR}/audit_trajectories.py" --self-test
echo "  ✓ All Xbox TPU unit tests and audit-model-trajectories self-test passed"
