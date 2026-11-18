#!/usr/bin/env bash
# Stage 1: Compile code (< 2s)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(pwd)}"
BLAZE_BIN="/google/bin/releases/arca9-local-blaze-cli/blaze-for-agents"
TARGET_PATTERN="//prototypes/gdm/users/dsuo/impromptu/..."

echo "=== [Stage 1: Compile code (< 2s)] Checking compile and syntax ==="
cd "${WORKSPACE_ROOT}"
"${BLAZE_BIN}" build --nocheck_visibility "${TARGET_PATTERN}"
echo "  ✓ Compile and syntax checks passed (blaze build succeeded)"

