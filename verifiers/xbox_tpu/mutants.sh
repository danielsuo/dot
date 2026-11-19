#!/usr/bin/env bash
# Stage 3: Structural invariant & regression-oracle checks for Xbox TPU hard isolation
set -euo pipefail

echo "=== [Stage 3: Mutation / Oracle Gate] Verifying hard-isolation test oracles ==="

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

python3 - "${WS}" "${MODE}" <<'PY'
from pathlib import Path
import sys

ws = Path(sys.argv[1])
mode = sys.argv[2]

if mode == "gvisor_flock":
    gs_cc = (ws / "cloud/gvisor/api/gvisor_sandbox.cc").read_text()
    gs_test = (ws / "cloud/gvisor/api/gvisor_sandbox_test.cc").read_text()
    adapter_cc = (ws / "assistant/boq/lamda/execution_box/sandbox/gvisor_sandbox_adapter.cc").read_text()
    checks = [
        ("WaitForFirstAvailableTPUDevice flock(LOCK_EX | LOCK_NB) in gvisor_sandbox.cc", "WaitForFirstAvailableTPUDevice" in gs_cc and "TryFlockFD(fd, LOCK_EX)" in gs_cc),
        ("PCI IOMMU group sorting & deduplication in GetTPUDeviceIndices", "std::sort(tpu_device_indices.begin(), tpu_device_indices.end())" in gs_cc),
        ("Mutual exclusion validation (wait_for_tpus_to_be_available vs wait_for_first_available_tpu)", "Cannot set both wait_for_tpus_to_be_available and" in gs_cc),
        ("TPUWaitForFirstAvailableAssignsChipsAndWaits unit test in gvisor_sandbox_test.cc", "TPUWaitForFirstAvailableAssignsChipsAndWaits" in gs_test),
        ("Xbox adapter forwarding gvisor_wait_for_first_available_tpu", "set_wait_for_first_available_tpu" in adapter_cc),
    ]
else:
    adapter_cc = (ws / "assistant/boq/lamda/execution_box/sandbox/gvisor_sandbox_adapter.cc").read_text()
    adapter_test = (ws / "assistant/boq/lamda/execution_box/sandbox/gvisor_sandbox_adapter_test.cc").read_text()
    lease_cc = (ws / "assistant/boq/lamda/execution_box/service/tpu/tpu_chip_lease_module.cc").read_text()
    lease_test = (ws / "assistant/boq/lamda/execution_box/service/tpu/tpu_chip_lease_module_test.cc").read_text()
    site_py = (ws / "learning/gemini/rex/projects/code/jetski_agent/contrib/mlebench/xbox_image/sitecustomize.py").read_text()
    site_test = (ws / "learning/gemini/rex/projects/code/jetski_agent/contrib/mlebench/xbox_image/sitecustomize_test.py").read_text()

    checks = [
        ("IOMMU group lookup in gvisor_sandbox_adapter.cc", "iommu_group" in adapter_cc and "host_iommu_groups[chip_idx]" in adapter_cc),
        ("Non-sequential Borg IOMMU group oracle (66, 67, 11, 12) in gvisor_sandbox_adapter_test.cc", "EXPECT_EQ(accel_spec.tpu().unsafe_tpu_device_subset(0), 11)" in adapter_test),
        ("Out-of-range subset rejection test in gvisor_sandbox_adapter_test.cc", "RejectsOutOfRangeTpuDeviceSubset" in adapter_test),
        ("Guest TPU_VISIBLE_CHIPS='0' under VFIO subset isolation in tpu_chip_lease_module.cc", 'tpu_options != nullptr ? "0"' in lease_cc),
        ("Guest TPU_VISIBLE_CHIPS='0' oracle in tpu_chip_lease_module_test.cc", '"TPU_VISIBLE_CHIPS"), "0"' in lease_test or 'env.at("TPU_VISIBLE_CHIPS"), "0"' in lease_test),
        ("Numeric /dev/vfio/<group> guard before PJRT_DEVICE=TPU in sitecustomize.py", "e.isdigit()" in site_py and "_TorchXlaLibtpuFinder" in site_py),
        ("CPU-only /dev/vfio/vfio vs numeric /dev/vfio/66 oracle in sitecustomize_test.py", 'self.assertIsNone(os.environ.get("PJRT_DEVICE"))' in site_test and "_TorchXlaLibtpuFinder" in site_test),
    ]

failed = [name for name, ok in checks if not ok]
if failed:
    for name in failed:
        print(f"  ✗ Missing oracle/invariant: {name}", file=sys.stderr)
    sys.exit(1)

for name, _ in checks:
    print(f"  ✓ {name}")
PY

echo "  ✓ All hard-isolation & trajectory runtime test oracles verified (${MODE})"
