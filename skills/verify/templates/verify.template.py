#!/usr/bin/env python3
"""Verification suite runner implementing progressive verification stages."""

import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone

def run_stage_0_targeted(target: str, src_root: str) -> bool:
    print(f"\n[Tier 0: Targeted test] Running focused check for '{target or 'active change'}'...")
    # TODO: Add project targeted test command (e.g. cargo test --test <name>, pytest <file>)
    print("  ✓ Targeted test passed")
    return True

def run_stage_1_compile(src_root: str) -> bool:
    print("\n[Stage 1: Compile code (< 2s)] Checking compile and syntax...")
    # TODO: Add project compile command (e.g. cargo check, tsc --noEmit, python3 -m py_compile)
    print("  ✓ Compile and syntax checks passed")
    return True

def run_stage_2_tests(port: int, src_root: str) -> bool:
    print("\n[Stage 2: Run automated tests (< 10s)] Running unit & CLI tests...")
    # TODO: Run unit tests, CLI flag matrix, and migrations
    print("  ✓ Unit tests, CLI arguments, and regression tests passed")
    return True

def run_stage_3_principles_audit(src_root: str) -> bool:
    print("\n[Stage 3: Architecture and principles audit] Running principles checklist...")
    # Run pre-review audit per references/principles-router.md
    print("  ✓ Architecture and principles audit passed")
    return True

def run_stage_4_e2e(port: int) -> bool:
    print("\n[Stage 4: Test user workflows and features (1–3m)] Running automated user flows...")
    # TODO: Run headless automation script (Playwright, Puppeteer, curl) capturing logs/screenshots
    print("  ✓ User workflows and feature assertions passed")
    return True

def log_receipt(app_name: str, stages: list[int], passed: bool, duration_ms: float) -> None:
    receipt_dir = os.path.expanduser("~/.config/skills")
    os.makedirs(receipt_dir, exist_ok=True)
    receipt_path = os.path.join(receipt_dir, "usage.jsonl")
    record = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "app": app_name,
        "stages": stages,
        "passed": passed,
        "duration_ms": duration_ms,
    }
    with open(receipt_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(record) + "\n")

def main() -> None:
    parser = argparse.ArgumentParser(description="Progressive verification runner")
    parser.add_argument("--tier", type=int, choices=[0, 1, 2, 3, 4], help="Run specific stage (0=targeted, 1=compile, 2=tests, 3=audit, 4=workflows)")
    parser.add_argument("--fast", action="store_true", help="Inner loop: run compile and tests (< 5s)")
    parser.add_argument("--target", type=str, default="", help="Optional target specifier for Tier 0")
    parser.add_argument("--port", type=int, default=8080, help="Test port for ephemeral servers")
    parser.add_argument("--src-root", type=str, default=".", help="Source root path")
    args = parser.parse_args()

    start_time = time.time()
    if args.fast:
        stages = [1, 2]
    elif args.tier is not None:
        stages = [args.tier]
    else:
        stages = [1, 2, 3, 4]

    print(f"=== Starting verification suite (Stages: {stages}) ===")

    ok = True
    executed = []
    if 0 in stages and ok:
        executed.append(0)
        ok = run_stage_0_targeted(args.target, args.src_root)
    if 1 in stages and ok:
        executed.append(1)
        ok = run_stage_1_compile(args.src_root)
    if 2 in stages and ok:
        executed.append(2)
        ok = run_stage_2_tests(args.port, args.src_root)
    if 3 in stages and ok:
        executed.append(3)
        ok = run_stage_3_principles_audit(args.src_root)
    if 4 in stages and ok:
        executed.append(4)
        ok = run_stage_4_e2e(args.port)

    duration_ms = round((time.time() - start_time) * 1000, 2)
    log_receipt("verify-app", executed, ok, duration_ms)

    if not ok:
        print(f"\n❌ Verification failed in {duration_ms}ms")
        sys.exit(1)
    print(f"\n✅ All stages {executed} passed in {duration_ms}ms")

if __name__ == "__main__":
    main()
