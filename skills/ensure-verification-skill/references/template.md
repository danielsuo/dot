# Verification templates

Use these minimal templates when scaffolding a verification suite for a project.

---

## 1. Environment doctor (`scripts/doctor.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Environment health check ==="

# Check toolchain
if command -v cargo >/dev/null 2>&1; then
  echo "  ✓ cargo available: $(cargo --version)"
elif command -v python3 >/dev/null 2>&1; then
  echo "  ✓ python3 available: $(python3 --version)"
fi

echo "=== All prerequisites ready ==="
```

---

## 2. Five-stage verification runner (`scripts/verify.py`)

```python
#!/usr/bin/env python3
"""Verification suite runner implementing five stages."""

import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone

def run_stage_1_compile(src_root: str) -> bool:
    print("\n[Stage 1: Compile code (< 2s)] Checking compile and syntax...")
    # Example: cargo check or tsc
    print("  ✓ Compile and syntax checks passed")
    return True

def run_stage_2_unit(src_root: str) -> bool:
    print("\n[Stage 2: Run unit tests (< 10s)] Running in-memory unit tests...")
    # Example: cargo test or pytest
    print("  ✓ Unit tests passed")
    return True

def run_stage_3_cli(port: int) -> bool:
    print(f"\n[Stage 3: Run CLI and check flags (~10-30s)] Checking CLI flags...")
    # Example: app --help, required flags, test port
    print("  ✓ CLI contract checks passed")
    return True

def run_stage_4_principles_audit(src_root: str) -> bool:
    print("\n[Stage 4: Architecture and principles audit] Checking principles...")
    # Check naming, atomic changes, and self-documenting flags
    print("  ✓ Principles self-audit passed")
    return True

def run_stage_5_e2e(port: int) -> bool:
    print(f"\n[Stage 5: Test user workflows (~1-3m)] Running automated user workflow...")
    # Headless automation script clicks buttons, navigates views, captures screenshots
    print("  ✓ User workflows executed; evidence captured for agent inspection")
    return True

def log_receipt(skill_name: str, stages_run: list, success: bool, duration_ms: float):
    log_dir = os.path.expanduser("~/.config/skills")
    os.makedirs(log_dir, exist_ok=True)
    record = {
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "skill": skill_name,
        "action": "verify",
        "stages": stages_run,
        "status": "ok" if success else "failed",
        "duration_ms": duration_ms
    }
    try:
        with open(os.path.join(log_dir, "usage.jsonl"), "a") as f:
            f.write(json.dumps(record) + "\n")
    except Exception:
        pass

def main():
    parser = argparse.ArgumentParser(description="Verification suite")
    parser.add_argument("--tier", type=int, choices=[1, 2, 3, 4, 5], help="Run stage 1..5")
    parser.add_argument("--port", type=int, default=8080, help="Test port")
    parser.add_argument("--src-root", type=str, default=".", help="Source root")
    args = parser.parse_args()

    start_time = time.time()
    stages = [args.tier] if args.tier else [1, 2, 3, 4, 5]
    print(f"=== Starting verification suite (Stages: {stages}) ===")

    ok = True
    executed = []
    if 1 in stages and ok:
        executed.append(1)
        ok = run_stage_1_compile(args.src_root)
    if 2 in stages and ok:
        executed.append(2)
        ok = run_stage_2_unit(args.src_root)
    if 3 in stages and ok:
        executed.append(3)
        ok = run_stage_3_cli(args.port)
    if 4 in stages and ok:
        executed.append(4)
        ok = run_stage_4_principles_audit(args.src_root)
    if 5 in stages and ok:
        executed.append(5)
        ok = run_stage_5_e2e(args.port)

    duration_ms = round((time.time() - start_time) * 1000, 2)
    log_receipt("verify-app", executed, ok, duration_ms)

    if not ok:
        print(f"\n❌ Verification failed in {duration_ms}ms")
        sys.exit(1)
    print(f"\n✅ All stages {executed} passed in {duration_ms}ms")

if __name__ == "__main__":
    main()
```

---

## 3. Feature specification format (`features/<feature>.md`)

```markdown
# Feature: Search Notes

## Capabilities
Filter notes in real time by title or tag.

## User path
Open search bar with `/`, type query string, view matching notes list.

## Automation
Headless script types query into search input and asserts matching items render.

## Assertions
1. Empty query displays all notes.
2. Query matching tag filters list to matching items.
3. Query matching nothing displays empty state text.
```
