#!/usr/bin/env bash
# Stage 4: Live trajectory audit via Elder Veliz's audit-model-trajectories skill
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "=== [Stage 4: Live Trajectory Audit] Running Elder Veliz audit-model-trajectories ==="
python3 -P "${SCRIPT_DIR}/audit_trajectories.py" "$@"
