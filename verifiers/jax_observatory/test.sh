#!/usr/bin/env bash
# Stage 2: Run automated tests (< 10s)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(pwd)}"
LAZE_BIN="/google/bin/releases/peninsula-laze-cli/laze"
PACKAGE_TARGET="//experimental/users/dsuo/jax/observatory/..."

TARGET="${1:-}"

cd "${WORKSPACE_ROOT}"

if [[ -n "${TARGET}" ]]; then
  RESOLVED="${TARGET}"
  if [[ ! "${RESOLVED}" =~ ^// ]]; then
    CLEAN="${RESOLVED%.rs}"
    RESOLVED="//experimental/users/dsuo/jax/observatory:${CLEAN}"
  fi
  echo "=== [Tier 0: Targeted test (< 2s)] Running focused check for '${RESOLVED}' ==="
  "${LAZE_BIN}" test "${RESOLVED}"
  echo "  ✓ Targeted test passed: ${RESOLVED}"
  exit 0
fi

echo "=== [Stage 2: Run automated tests (< 10s)] Running unit tests ==="
"${LAZE_BIN}" test "${PACKAGE_TARGET}"

# Invariant: verify server API health reflects valid shard schema conformance
echo "=== Checking server shard health and schema conformance ==="
python3 -c '
import json, sys, urllib.request
try:
    with urllib.request.urlopen("http://127.0.0.1:8088/api/health", timeout=5) as resp:
        data = json.loads(resp.read().decode("utf-8"))
        status = data.get("status", "")
        if status != "healthy":
            print(f"  ✗ FAIL: Server reports health status: {status} (expected healthy)!", file=sys.stderr)
            sys.exit(1)
        if not data.get("schema_conformance_ok", False):
            print("  ✗ FAIL: Server reports schema_conformance_ok is false!", file=sys.stderr)
            sys.exit(1)
        quarantined = data.get("quarantined_shards", 0)
        if quarantined > 0:
            print(f"  ✗ FAIL: Server reports quarantined_shards: {quarantined}!", file=sys.stderr)
            sys.exit(1)
        missing = data.get("missing_dates", [])
        if missing:
            print(f"  ✗ FAIL: Server reports missing_dates: {missing}!", file=sys.stderr)
            sys.exit(1)
        healthy = data.get("healthy_shards", 0)
        if healthy < 200:
            print(f"  ✗ FAIL: Suspiciously low healthy shards: {healthy}", file=sys.stderr)
            sys.exit(1)
        print(f"  ✓ Shard schema and integrity check passed: {healthy} healthy shards, 0 quarantined, 0 missing dates, status=healthy")

    # Invariant: sanity check daily metrics distribution to detect statistical anomalies / multi-task overcounting
    req = urllib.request.Request("http://127.0.0.1:8088/api/query?range=MAX")
    with urllib.request.urlopen(req, timeout=30) as resp:
        query_data = json.loads(resp.read().decode("utf-8"))
        ds = query_data.get("daily_series", [])
        if len(ds) >= 14:
            swe_vals = [r.get("tot_swe_yrs", 0.0) for r in ds]
            sorted_swe = sorted(swe_vals)
            median_swe = sorted_swe[len(sorted_swe) // 2]
            max_swe = sorted_swe[-1]
            # Flag any day with > 10x median SWE cost or > 5.0 SWE-Years as suspect data
            if max_swe > max(5.0, median_swe * 10.0):
                spike_idx = swe_vals.index(max_swe)
                spike_date = ds[spike_idx].get("date", "unknown")
                print(f"  ✗ FAIL: Suspect data anomaly detected on {spike_date}: {max_swe:.2f} SWE-Years (median: {median_swe:.2f} SWE-Years, > 10x outlier)!", file=sys.stderr)
                sys.exit(1)
            print(f"  ✓ Daily metrics sanity check passed: {len(ds)} days verified, median={median_swe:.3f} SWE-Yrs, max={max_swe:.3f} SWE-Yrs (no suspect spikes)")
except Exception as e:
    print(f"  [test] Note: Server check encountered error or server unreachable ({e}), failing stage gate", file=sys.stderr)
    sys.exit(1)
'
echo "  ✓ All hermetic unit and integration tests passed (exit code 0)"
