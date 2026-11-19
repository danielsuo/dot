#!/usr/bin/env bash
# Stage 1: Compile code (< 2s)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(pwd)}"
LAZE_BIN="/google/bin/releases/peninsula-laze-cli/laze"
SERVER_TARGET="//experimental/users/dsuo/jax/observatory:server"
CRON_TARGET="//experimental/users/dsuo/jax/observatory/cron:job"
CRON_DEPLOYED_BIN="/usr/local/google/home/dsuo/bin/jax_rollup_job"

echo "=== [Stage 1: Compile code (< 2s)] Checking compile and syntax ==="
cd "${WORKSPACE_ROOT}"
"${LAZE_BIN}" build "${SERVER_TARGET}" "${CRON_TARGET}"

# Verify or rebuild deployed cron binary
CRON_BLAZE_BIN="blaze-bin/experimental/users/dsuo/jax/observatory/cron/job"
if [[ -f "${CRON_BLAZE_BIN}" ]]; then
  if [[ ! -f "${CRON_DEPLOYED_BIN}" ]] || [[ "${CRON_BLAZE_BIN}" -nt "${CRON_DEPLOYED_BIN}" ]]; then
    echo "[compile] Deploying freshly compiled cron binary to ${CRON_DEPLOYED_BIN}..."
    cp -f "${CRON_BLAZE_BIN}" "${CRON_DEPLOYED_BIN}"
    chmod +x "${CRON_DEPLOYED_BIN}"
  fi
fi

# Invariant: verify deployed binary contains the is_restart schema and binary freshness
if [[ -f "${CRON_DEPLOYED_BIN}" ]]; then
  if grep -q "is_restart" <(strings "${CRON_DEPLOYED_BIN}"); then
    :
  else
    echo "  ✗ FAIL: Deployed cron binary ${CRON_DEPLOYED_BIN} missing 'is_restart' schema definition" >&2
    exit 1
  fi
fi

echo "  ✓ Compile checks passed (laze build succeeded, cron binary up-to-date with is_restart schema)"
