#!/usr/bin/env bash
# Environment & Preflight Doctor for Impromptu & Blimp
set -euo pipefail

echo "=== Running Impromptu Environment Doctor ==="

# 1. Check Blaze CLI
BLAZE_BIN="/google/bin/releases/arca9-local-blaze-cli/blaze-for-agents"
if [[ -x "${BLAZE_BIN}" ]]; then
  echo "  ✓ blaze-for-agents found: ${BLAZE_BIN}"
else
  echo "  ✗ blaze-for-agents NOT found at ${BLAZE_BIN}"
  exit 1
fi

# 2. Check Python 3
if command -v python3 >/dev/null 2>&1; then
  PY_VER=$(python3 --version)
  echo "  ✓ Python 3 available: ${PY_VER}"
else
  echo "  ✗ python3 command not found"
  exit 1
fi

# 3. Check Workspace Context
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(pwd)}"
if [[ -d "${WORKSPACE_ROOT}" && "${WORKSPACE_ROOT}" =~ google3 ]]; then
  echo "  ✓ google3 workspace detected: ${WORKSPACE_ROOT}"
else
  echo "  ⚠ Warning: could not verify google3 workspace root from ${SCRIPT_DIR}"
fi

echo "=== Doctor Check Complete: All Prerequisites OK ==="

