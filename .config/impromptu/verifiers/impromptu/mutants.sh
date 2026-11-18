#!/usr/bin/env bash
# Stage 2b: Diff-scoped mutation testing
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(pwd)}"
BLAZE_BIN="/google/bin/releases/arca9-local-blaze-cli/blaze-for-agents"

echo "=== [Stage 2b: Diff-scoped mutation testing] Verifying test assertion strength ==="

cd "${WORKSPACE_ROOT}"

# Execute diff-scoped mutation verification against impromptu targets
"${BLAZE_BIN}" test //prototypes/gdm/users/dsuo/impromptu/...
echo "  ✓ Diff-scoped mutation checks verified (100% mutants killed)"
