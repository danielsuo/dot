# Xbox TPU Hard Isolation & Trajectory Audit Verifier

## Core Invariants
1. **Hard VFIO Single-Chip Isolation (`cl/1025582404`)**:
   - `TpuChipLeaseModule` (`assistant/boq/lamda/execution_box/service/tpu/tpu_chip_lease_module.cc`) leases 1 exclusive slot (`0..N-1`) per sandbox and sets `TPU_VISIBLE_CHIPS="0"` inside VFIO-subset-isolated sandboxes while preserving `TPU_CHIP_ID=<slot>` for host attribution.
   - `GvisorSandboxAdapter` (`assistant/boq/lamda/execution_box/sandbox/gvisor_sandbox_adapter.cc`) resolves logical slot `chip_idx` to the sorted host PCI VFIO IOMMU group ID (`/sys/bus/pci/devices/*/iommu_group` + `/dev/vfio/<group_id>`, e.g. `11, 12, 66, 67`) before populating `TPUSpec.unsafe_tpu_device_subset`.
2. **Primary TPU ML Sandbox Image (`cl/1025582403`)**:
   - `Dockerfile` installs `torch==2.9.0` (CPU wheel), `torch_xla==2.9.0`, and `libtpu==0.0.21` isolated at `/usr/local/lib/torch_xla_libtpu/libtpu.so` alongside `jax[tpu]`.
   - `sitecustomize.py` checks numeric `/dev/vfio/<group_id>` entries before enabling `PJRT_DEVICE=TPU`, sets `TPU_ACCELERATOR_TYPE` / `TPU_PROCESS_BOUNDS=1,1,1` / `TPU_WORKER_ID=0` / `TPU_WORKER_HOSTNAMES=localhost` under `TPU_SKIP_MDS_QUERY=1`, and disables the ALTS HLO breakpoint debugger server (`--tpu_hlo_breakpoint_debugger_server_enabled=false`).
3. **Permanent Live Trajectory Audit (`audit-model-trajectories`)**:
   - Every live experiment verification must run `verify live --xid=<BEYOND_XID> --server-xid=<REBOX_XID>` (backed by Elder Veliz's `configs/users/elderveliz/_agents/skills/audit-model-trajectories` skill and `scripts/render_audit_report.py`), auditing S2 `/s2/xid/<XID>/training_samples` (`NOT IS_NAN` guarded, `reward_all_safe`, sanitized `reward_all_metrics` JSON, verbatim `s2.record_number` ADE deep links) and `xbox_server` Analog execution logs, and passing `--lint-html` with zero static errors.

## Commands
- `verify doctor`: Check Blaze, S2, F1-SQL, ADE, Analog CLIs, and Elder Veliz's `audit-model-trajectories` skill files.
- `verify compile`: Build `tpu_chip_lease_module`, `gvisor_sandbox_adapter`, and `sitecustomize_test`.
- `verify test`: Run all 3 unit test targets + `audit_trajectories.py --self-test`.
- `verify mutants`: Verify all 7 hard-isolation & runtime test oracles.
- `verify live --xid=<BEYOND_XID> [--server-xid=<REBOX_XID>] [--require-completed-episodes]`: Execute the 6-stage `audit-model-trajectories` S2 + Analog audit and compile + lint `xbox_tpu_trajectory_audit.html`.
