#!/usr/bin/env bash
# Stage 0: Pre-flight environment & tool check for Xbox TPU + audit-model-trajectories
set -euo pipefail

echo "=== [doctor] Checking Xbox TPU & audit-model-trajectories dependencies ==="

BLAZE_FOR_AGENTS="/google/bin/releases/arca9-local-blaze-cli/blaze-for-agents"
S2_CLI="/google/bin/releases/gemini-agents-s2/s2_cli"
F1_SQL="/google/bin/releases/f1-team/public/f1-sql"
ADE_CLI="/google/bin/releases/ade-agent-cli/ade-agent-cli"
ANALOG_CLI="/google/bin/releases/analog-cli/google-analog"
AUDIT_SKILL_DIR="/google/src/files/head/depot/configs/users/elderveliz/_agents/skills/audit-model-trajectories"

for bin in "${BLAZE_FOR_AGENTS}" "${S2_CLI}" "${F1_SQL}" "${ADE_CLI}" "${ANALOG_CLI}"; do
  if [[ ! -x "${bin}" ]]; then
    echo "  ✗ Missing executable: ${bin}" >&2
    exit 1
  fi
done

for req_file in \
  "${AUDIT_SKILL_DIR}/SKILL.md" \
  "${AUDIT_SKILL_DIR}/scripts/render_audit_report.py" \
  "${AUDIT_SKILL_DIR}/references/capture_and_schema.md"; do
  if [[ ! -r "${req_file}" ]]; then
    echo "  ✗ Missing Elder Veliz audit-model-trajectories asset: ${req_file}" >&2
    exit 1
  fi
done

echo "  ✓ All CLIs and Elder Veliz audit-model-trajectories skill assets verified"
