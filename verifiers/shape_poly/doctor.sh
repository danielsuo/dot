#!/bin/bash
set -euo pipefail
which /google/bin/releases/peninsula-laze-cli/laze >/dev/null || (echo "Missing laze" && exit 1)
echo "shape_poly environment OK"
