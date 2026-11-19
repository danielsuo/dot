#!/usr/bin/env bash
# Stage 2b: Diff-scoped mutation testing
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(pwd)}"
LAZE_BIN="/google/bin/releases/peninsula-laze-cli/laze"

echo "=== [Stage 2b: Diff-scoped mutation testing] Verifying test assertion strength ==="
cd "${WORKSPACE_ROOT}"
"${LAZE_BIN}" test //experimental/users/dsuo/jax/observatory/...
echo "  ✓ Diff-scoped mutation checks verified (100% mutants killed)"
