# Engineering principles router

Engineering principles are modular reference manuals located in `$(find-skills-root)/../references/principles/` (or `~/dot/references/principles/`). Use this router during Stage 4 verification and mid-flight development.

---

## 1. Pre-review principles checklist

Before declaring a task complete or moving code to review, run this 30-second audit:

1. **Canonical naming and layout** (`minimize-reader-load.md`): Is file naming standard? Is package layout canonical for the ecosystem (for example, `src/bin/imp.rs` rather than `src/imp_main.rs`)?
2. **Atomic verifiable units** (`sequence-verifiable-units.md`): Are code and verification tests in the same change? Can a reviewer verify everything in one step?
3. **No premature abstractions** (`subtract-before-you-add.md`): Did I add unused options, dead boilerplate, or unneeded helper scripts?
4. **Self-documenting interfaces** (`type-system-discipline.md`): Are CLI flags typed and declarative (for example, using standard libraries like `clap` rather than manual index loops)?
5. **Proof of execution** (`prove-it-works.md`): Did I execute the verification runner and include the exact terminal output receipt?

---

## 2. Situational principles router

For mid-flight situational routing during planning and coding, consult the active router table in `AGENTS.md` Section 3. Individual principle definition manuals are located in `$(find-skills-root)/../references/principles/` (or `~/dot/references/principles/`).
