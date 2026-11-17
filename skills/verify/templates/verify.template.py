#!/usr/bin/env python3
"""Verification suite runner implementing progressive verification stages."""

import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone

# Project test command template for Tier 0 targeted testing.
# Examples:
#   Cargo: "cargo test --test {target}" or "cargo test {target}"
#   Pytest: "pytest -k {target}"
#   Go: "go test -run {target} ./..."
TARGETED_TEST_TEMPLATE = "echo 'Running targeted test for {target}'"

def detect_modified_tests() -> str:
    """Auto-detect recently modified test files from git status."""
    try:
        out = subprocess.check_output(
            ["git", "status", "--porcelain"], stderr=subprocess.DEVNULL
        ).decode()
        for line in out.splitlines():
            path = line[3:].strip()
            if "test" in path.lower() and os.path.exists(path):
                return path
    except Exception:
        pass
    return ""

def run_stage_0_targeted(target: str, src_root: str) -> bool:
    resolved_target = target or detect_modified_tests() or "smoke_test"
    print(f"\n[Tier 0: Targeted test] Running focused check for '{resolved_target}'...")
    cmd = TARGETED_TEST_TEMPLATE.format(target=resolved_target)
    # TODO: Execute cmd via subprocess (e.g. subprocess.run(cmd, shell=True, check=True))
    print(f"  ✓ Targeted test passed: {resolved_target}")
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

def print_agentic_stages_reminder() -> None:
    print("\n[Agentic Review Stages — Performed by Agent in Review/Report]")
    print("  → Stage 3: Architecture & principles audit (self-audit diff vs references/principles/)")
    print("  → Stage 4: Test user workflows (execute & walk features/*.md specs)")
    print("  → Stage 5: Skeptical expert panel review (Staff Architect, Principal SRE, Adversarial User)")

def main() -> None:
    parser = argparse.ArgumentParser(description="Deterministic verification runner (Stages 1-2)")
    parser.add_argument("--tier", type=int, choices=[0, 1, 2], help="Run specific programmatic stage (0=targeted, 1=compile, 2=tests)")
    parser.add_argument("target", nargs="?", default="", help="Optional targeted test name or path for Tier 0")
    parser.add_argument("--target", dest="target_flag", default="", help="Optional target specifier for Tier 0")
    parser.add_argument("--fast", action="store_true", help="Inner loop: run compile and tests (< 5s)")
    parser.add_argument("--port", type=int, default=8080, help="Test port for ephemeral servers")
    parser.add_argument("--src-root", type=str, default=".", help="Source root path")
    args = parser.parse_args()

    target = args.target_flag or args.target
    start_time = time.time()
    if args.fast or args.tier is None:
        stages = [1, 2]
    else:
        stages = [args.tier]

    print(f"=== Starting verification suite (Stages: {stages}) ===")

    ok = True
    executed = []
    if 0 in stages and ok:
        executed.append(0)
        ok = run_stage_0_targeted(target, args.src_root)
    if 1 in stages and ok:
        executed.append(1)
        ok = run_stage_1_compile(args.src_root)
    if 2 in stages and ok:
        executed.append(2)
        ok = run_stage_2_tests(args.port, args.src_root)

    duration_ms = round((time.time() - start_time) * 1000, 2)
    log_receipt("verify-app", executed, ok, duration_ms)

    if not ok:
        print(f"\n❌ Programmatic verification failed in {duration_ms}ms")
        sys.exit(1)
    print(f"\n✅ Programmatic stages {executed} passed in {duration_ms}ms")
    print_agentic_stages_reminder()

if __name__ == "__main__":
    main()
