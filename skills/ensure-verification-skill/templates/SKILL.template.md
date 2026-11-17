---
name: verify-<app>
description: "Verify <app> behavioral correctness, health, and engineering principles across five progressive stages."
---

# Verify <app>

Run verification commands from the repository root.

## 1. Quick commands

- Run full 5-stage verification suite:
  ```bash
  python3 scripts/verify.py
  ```
- Run environment health preflight:
  ```bash
  bash scripts/doctor.sh
  ```
- Run individual stages:
  ```bash
  python3 scripts/verify.py --tier=1  # Compile (< 2s)
  python3 scripts/verify.py --tier=2  # Unit tests (< 10s)
  python3 scripts/verify.py --tier=3  # CLI & flag audit (~10–30s)
  python3 scripts/verify.py --tier=4  # Architecture & principles (~10s)
  python3 scripts/verify.py --tier=5  # User workflows & features (~1–3m)
  ```

---

## 2. The five verification stages

1. **Stage 1: Compile code (target < 2s)**
   Build and type check without running the application (`<build_cmd>`).
2. **Stage 2: Run unit tests (target < 10s)**
   Hermetic native unit tests in memory (`<test_cmd>`).
3. **Stage 3: Run CLI and check flags (target ~10–30s)**
   Run compiled binaries with argument combinations, test flag errors, launch ephemeral server, scan for fake data.
4. **Stage 4: Architecture and principles audit**
   Run pre-review checklist and consult `$(find-skills-root)/ensure-verification-skill/references/principles-router.md` (which maps tasks to principles in `$(find-skills-root)/../references/principles/`).
5. **Stage 5: Test user workflows and features (target ~1–3m)**
   Automate user flows with headless scripts (capturing logs and screenshots); agent inspects layout, typography, and semantic correctness.

---

## 3. Pre-review principles checklist

Before declaring a task complete or moving code to review, run this 30-second audit:

1. **Canonical naming and layout** (`minimize-reader-load.md`): Is file naming standard? Is package layout canonical for the ecosystem?
2. **Atomic verifiable units** (`sequence-verifiable-units.md`): Are code and verification tests in the same change? Can a reviewer verify everything in one step?
3. **No premature abstractions** (`subtract-before-you-add.md`): Did I add unused options, dead boilerplate, or unneeded helper scripts?
4. **Self-documenting interfaces** (`type-system-discipline.md`): Are CLI flags typed and declarative?
5. **Proof of execution** (`prove-it-works.md`): Did I execute the verification runner and include the exact terminal output receipt?

Situational principles are located in `$(find-skills-root)/../references/principles/`. Consult `ensure-verification-skill/references/principles-router.md` for guidance.

---

## 4. Core mandate

**Push determinism into code, reserve agents for judgment**:
Automate mechanical testing (button clicks, network requests, form inputs, screenshot capture) in headless automation scripts. Use the agent to evaluate visual layout, typography, and semantic correctness.
