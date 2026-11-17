# Scaffolding templates for verification skills

Use these templates when scaffolding a verification suite from scratch.

## 1. Directory layout

```
${SKILLS_ROOT}/verify-<app>/
├── SKILL.md
├── features/
│   ├── README.md
│   └── <feature>.md
└── scripts/
    ├── doctor.sh         # Fast health check (< 3s): compiler, tools, port
    ├── verify.py         # 5-stage runner (--tier=1|2|3|4|5)
    ├── parity_check.py   # Upstream database vs API validator
    └── lint_fake_data.py # Source scanner for fake data
```

## 2. Template: doctor.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Environment health check ==="

# Check toolchain
if command -v cargo >/dev/null 2>&1; then
  echo "  ✓ cargo available: $(cargo --version)"
elif command -v python3 >/dev/null 2>&1; then
  echo "  ✓ python3 available: $(python3 --version)"
else
  echo "  ✗ No supported toolchain found"
  exit 1
fi

echo "=== All prerequisites ready ==="
```

## 3. Template: verify.py

See `references/harness-template/verify.py` for the complete 5-stage verification runner implementing:
- Stage 1: Compile code (`cargo check`, `tsc`).
- Stage 2: Run unit tests (`cargo test`, `pytest`).
- Stage 3: Run CLI and check flags (flag combinations, test server).
- Stage 4: Architecture and principles audit (`references/principles/`).
- Stage 5: Test user workflows and features (headless browser/CLI scripts).
- Background receipt logging to `~/.config/skills/usage.jsonl`.
