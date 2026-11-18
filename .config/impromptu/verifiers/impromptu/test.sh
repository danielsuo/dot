#!/usr/bin/env bash
# Stage 2: Run automated tests (< 10s)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(pwd)}"
BLAZE_BIN="/google/bin/releases/arca9-local-blaze-cli/blaze-for-agents"
TARGET_PATTERN="//prototypes/gdm/users/dsuo/impromptu/..."
IMP_TARGET="//prototypes/gdm/users/dsuo/impromptu:imp"
BLIMP_TARGET="//prototypes/gdm/users/dsuo/impromptu:blimp"

TARGET="${1:-}"

cd "${WORKSPACE_ROOT}"

if [[ -n "${TARGET}" ]]; then
  RESOLVED="${TARGET}"
  if [[ ! "${RESOLVED}" =~ ^// ]]; then
    CLEAN="${RESOLVED%.rs}"
    RESOLVED="//prototypes/gdm/users/dsuo/impromptu:${CLEAN}"
  fi
  echo "=== [Tier 0: Targeted test (< 2s)] Running focused check for '${RESOLVED}' ==="
  "${BLAZE_BIN}" test "${RESOLVED}"
  echo "  ✓ Targeted test passed: ${RESOLVED}"
  exit 0
fi

echo "=== [Stage 2: Run automated tests (< 10s)] Running unit tests & CLI contracts ==="

# 1. Hermetic in-memory unit tests
"${BLAZE_BIN}" test --nocheck_visibility "${TARGET_PATTERN}"
echo "  ✓ All hermetic unit and integration tests passed (exit code 0)"

# 2. imp execution check & flag extraction
IMP_HELP=$("${BLAZE_BIN}" run --nocheck_visibility "${IMP_TARGET}" -- --help)
IMP_FLAGS=($(echo "${IMP_HELP}" | grep -oE -- '--[a-zA-Z0-9-]+' | sort -u))
echo "  ✓ imp execution and flags validated (${#IMP_FLAGS[@]} flags found)"

# 3. blimp --help check
BLIMP_HELP=$("${BLAZE_BIN}" run --nocheck_visibility "${BLIMP_TARGET}" -- --help)
if ! echo "${BLIMP_HELP}" | grep -qE "Beekeeper|blimp"; then
  echo "  ✗ blimp --help failed" >&2
  exit 1
fi
echo "  ✓ blimp --help contract validated"

# 4. Programmatic flag forwarding check
BLIMP_FLAGS=($(echo "${BLIMP_HELP}" | grep -oE -- '--[a-zA-Z0-9-]+' | sort -u))
for flag in "${IMP_FLAGS[@]}"; do
  if ! echo " ${BLIMP_FLAGS[*]} " | grep -q " ${flag} "; then
    echo "  ✗ blimp is missing flag: ${flag}" >&2
    exit 1
  fi
done
echo "  ✓ All ${#IMP_FLAGS[@]} imp flags successfully exposed by blimp"

# 5. blimp dry-run validation
DRY_RUN=$("${BLAZE_BIN}" run --nocheck_visibility "${BLIMP_TARGET}" -- --id worker4-test --board 127.0.0.1:8799 --dry-run)
if ! echo "${DRY_RUN}" | grep -q "Dry-run preflight check passed"; then
  echo "  ✗ blimp --dry-run failed" >&2
  exit 1
fi
echo "  ✓ blimp preflight contract validated"

# 6. blimp interactive REPL exit lifecycle validation
INTERACTIVE_RUN=$(echo "exit" | "${BLAZE_BIN}" run --nocheck_visibility "${BLIMP_TARGET}" -- --id worker1-test --board 127.0.0.1:8799 -i)
if ! echo "${INTERACTIVE_RUN}" | grep -q "Interactive REPL started" || ! echo "${INTERACTIVE_RUN}" | grep -q "Exiting interactive REPL"; then
  echo "  ✗ blimp -i interactive REPL contract failed" >&2
  exit 1
fi
echo "  ✓ blimp interactive REPL contract validated"
