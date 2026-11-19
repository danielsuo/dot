#!/usr/bin/env bash
set -euo pipefail

echo "=== Environment health check ==="

# Check toolchain
if command -v cargo >/dev/null 2>&1; then
  echo "  ✓ cargo available: $(cargo --version)"
elif command -v python3 >/dev/null 2>&1; then
  echo "  ✓ python3 available: $(python3 --version)"
elif command -v node >/dev/null 2>&1; then
  echo "  ✓ node available: $(node --version)"
fi

echo "=== All prerequisites ready ==="
