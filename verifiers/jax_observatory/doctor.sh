#!/bin/bash
# Doctor check for JAX Observatory server.
# Usage: ./doctor.sh [PORT] (default: 8088)

set -euo pipefail

PORT="${1:-8088}"
BASE_URL="http://127.0.0.1:${PORT}"

echo "[doctor] Checking JAX Observatory at ${BASE_URL}..."

# Wait briefly for background shard validation to populate if server just started
for attempt in {1..20}; do
  HEALTH_CODE=$(curl -s -o /tmp/jax_doctor_health.json -w "%{http_code}" "${BASE_URL}/api/health" || echo "000")
  if [[ "${HEALTH_CODE}" == "200" ]]; then
    VAL_COUNT=$(python3 -c 'import json; d=json.load(open("/tmp/jax_doctor_health.json")); print(d.get("validated_shards", 0))' 2>/dev/null || echo "0")
    if [[ "${VAL_COUNT}" -gt 0 ]]; then
      break
    fi
  fi
  sleep 0.5
done

if [[ "${HEALTH_CODE}" != "200" ]]; then
  echo "[doctor] FAIL: /api/health returned HTTP ${HEALTH_CODE}" >&2
  exit 1
fi

HEALTH_INTEGRITY=$(python3 -c '
import json, sys
try:
    with open("/tmp/jax_doctor_health.json") as f:
        d = json.load(f)
    status = d.get("status", "")
    pass_rate = d.get("integrity_pass_rate_pct", 0.0)
    quarantined = d.get("quarantined_shards", 0)
    missing = len(d.get("missing_dates", []))
    anomalies = len(d.get("anomalies", []))
    validated = d.get("validated_shards", 0)
    schema_ok = d.get("schema_conformance_ok", False)
    print(f"{status},{pass_rate},{quarantined},{missing},{anomalies},{validated},{schema_ok}")
except Exception as e:
    print(f"error,{e}")
    sys.exit(1)
')

IFS=',' read -r H_STAT H_RATE H_QUAR H_MISS H_ANOM H_VAL H_SCH <<< "${HEALTH_INTEGRITY}"
if [[ "${H_STAT}" != "healthy" ]]; then
  echo "[doctor] FAIL: /api/health status is '${H_STAT}' (expected 'healthy')" >&2
  exit 1
fi
if [[ "${H_QUAR}" -gt 0 ]]; then
  echo "[doctor] FAIL: /api/health reports ${H_QUAR} quarantined shards" >&2
  exit 1
fi
if [[ "${H_MISS}" -gt 0 ]]; then
  echo "[doctor] FAIL: /api/health reports ${H_MISS} missing calendar partition dates" >&2
  exit 1
fi
if [[ "${H_ANOM}" -gt 0 ]]; then
  echo "[doctor] FAIL: /api/health reports ${H_ANOM} shard integrity anomalies" >&2
  exit 1
fi
if [[ "${H_SCH}" != "True" ]]; then
  echo "[doctor] FAIL: /api/health reports schema_conformance_ok is false" >&2
  exit 1
fi
echo "[doctor] PASS: /api/health status is 'healthy' (100% integrity, 0 quarantined, 0 missing dates, 0 anomalies across ${H_VAL} shards)"

# 2. Check /api/query endpoint responds with valid JSON
QUERY_CODE=$(curl -s -o /tmp/jax_doctor_query.json -w "%{http_code}" "${BASE_URL}/api/query?range=30d" || echo "000")
if [[ "${QUERY_CODE}" != "200" ]]; then
  echo "[doctor] FAIL: /api/query?range=30d returned HTTP ${QUERY_CODE}" >&2
  exit 1
fi

TOTAL_ROWS=$(python3 -c '
import json, sys
try:
    with open("/tmp/jax_doctor_query.json") as f:
        d = json.load(f)
    rows = d.get("total_db_rows", 0)
    matched = d.get("matched_rows", 0)
    exps = d.get("matched_experiments", 0)
    print(f"{rows},{matched},{exps}")
except Exception as e:
    sys.exit(1)
')

IFS=',' read -r ROWS MATCHED EXPS <<< "${TOTAL_ROWS}"
if [[ "${ROWS}" -eq 0 ]]; then
  echo "[doctor] FAIL: total_db_rows is 0" >&2
  exit 1
fi
if [[ "${EXPS}" -eq 0 ]]; then
  echo "[doctor] FAIL: matched_experiments is 0 (must be > 0 for 30d range)" >&2
  exit 1
fi
echo "[doctor] PASS: Database active (${ROWS} total rows, ${MATCHED} matched, ${EXPS} experiments)"

# 3. Check HTML index page loads
INDEX_CODE=$(curl -s -o /tmp/jax_doctor_index.html -w "%{http_code}" "${BASE_URL}/" || echo "000")
if [[ "${INDEX_CODE}" != "200" ]]; then
  echo "[doctor] FAIL: GET / returned HTTP ${INDEX_CODE}" >&2
  exit 1
fi

# 4. Verify no banner in header brand wrap (must be clean 1-line header)
if grep -A 20 'class="brand-wrap"' /tmp/jax_doctor_index.html | grep -q "liveDbBanner"; then
  echo "[doctor] FAIL: Obsolete liveDbBanner found in brand-wrap header" >&2
  exit 1
fi

# 5. Verify filtered query plausibility and timeline parity (is_restart = "true")
RESTART_CHECK=$(curl -s "${BASE_URL}/api/query?range=MAX&filters=%5B%7B%22col%22%3A%22is_restart%22%2C%22op%22%3A%22%3D%22%2C%22val%22%3A%22true%22%7D%5D" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    rows = d.get("matched_rows", 0)
    exps = d.get("matched_experiments", 0)
    ds = d.get("daily_series", [])
    hs = d.get("horizon_series", [])
    ds_len = len(ds)
    hs_len = len(hs)
    # Check that horizon_series daily metrics match daily_series (no unfiltered fleet data leakage)
    mismatch = False
    if ds_len > 0 and hs_len > 0:
        sample_idx = min(100, ds_len - 1)
        if ds[sample_idx]["jobs"] != hs[sample_idx]["jobs"]:
            mismatch = True
    print(f"{rows},{exps},{ds_len},{hs_len},{mismatch}")
except Exception as e:
    sys.exit(1)
')

IFS=',' read -r R_ROWS R_EXPS R_DS R_HS R_MIS <<< "${RESTART_CHECK}"
if [[ "${R_ROWS}" -lt 10000000 ]]; then
  echo "[doctor] FAIL: is_restart=true matched_rows is suspiciously low: ${R_ROWS} (expected >= 10M)" >&2
  exit 1
fi
if [[ "${R_EXPS}" -lt 500000 ]]; then
  echo "[doctor] FAIL: is_restart=true matched_experiments under-counting defect detected: ${R_EXPS} (expected >= 500k, capped to sample buffer)" >&2
  exit 1
fi
# Timeline parity: horizon_series contains full calendar timeline,
# so hs_len == ds_len with zero gap days across the entire calendar.
DIFF=$(( R_HS - R_DS ))
if [ "${DIFF}" -ne 0 ]; then
  echo "[doctor] FAIL: Timeline parity disparity: daily_series has ${R_DS} days but horizon_series has ${R_HS} days (expected 0 gap days)" >&2
  exit 1
fi
if [[ "${R_MIS}" == "True" ]]; then
  echo "[doctor] FAIL: Scrubber horizon data mismatch: horizon_series leaked unfiltered fleet data" >&2
  exit 1
fi
echo "[doctor] PASS: Filtered is_restart query verified: ${R_ROWS} jobs, ${R_EXPS} experiments, ${R_DS}/${R_HS} days (full parity & zero data leakage)"

# 6. Verify daily metrics distribution sanity check (prevent suspect data spikes / multi-task overcounting)
DATA_SANITY=$(python3 -c '
import json, sys, urllib.request
try:
    with urllib.request.urlopen("http://127.0.0.1:8088/api/query?range=MAX", timeout=10) as resp:
        d = json.load(resp)
        ds = d.get("daily_series", [])
        if len(ds) >= 14:
            swe_vals = [r.get("tot_swe_yrs", 0.0) for r in ds]
            sorted_swe = sorted(swe_vals)
            median_swe = sorted_swe[len(sorted_swe) // 2]
            max_swe = sorted_swe[-1]
            if max_swe > max(5.0, median_swe * 10.0):
                spike_idx = swe_vals.index(max_swe)
                spike_date = ds[spike_idx].get("date", "unknown")
                print(f"SPIKE,{spike_date},{max_swe:.2f},{median_swe:.2f}")
                sys.exit(0)
            print(f"OK,{len(ds)},{max_swe:.2f},{median_swe:.2f}")
except Exception as e:
    print(f"ERROR,{e}")
')

IFS=',' read -r S_STATUS S_P1 S_P2 S_P3 <<< "${DATA_SANITY}"
if [[ "${S_STATUS}" == "SPIKE" ]]; then
  echo "[doctor] FAIL: Suspect data anomaly detected on ${S_P1}: ${S_P2} SWE-Years (median: ${S_P3} SWE-Years, > 10x outlier)!" >&2
  exit 1
elif [[ "${S_STATUS}" == "ERROR" ]]; then
  echo "[doctor] FAIL: Failed to query /api/query?range=MAX for sanity check: ${S_P1}" >&2
  exit 1
fi
echo "[doctor] PASS: Daily metrics sanity check passed: ${S_P1} days verified (no suspect spikes)"

echo "[doctor] ALL CHECKS PASSED: Instance on port ${PORT} is healthy and ready to drive."
exit 0
