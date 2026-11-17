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

When encountering any of these situations during coding or review, read the corresponding principle in `$(find-skills-root)/../references/principles/`:

1. **Questioning task premise or asked to implement a questionable workaround** -> `attack-the-premise.md`
2. **Exposing cross-module contracts or passing untrusted inputs** -> `boundary-discipline.md`
3. **Performing repetitive manual steps or debugging toil** -> `build-the-lever.md`
4. **Fixing a bug and wanting to permanently prevent recurrence** -> `encode-lessons-in-structure.md`
5. **Evaluating architectural designs or choosing between alternatives** -> `exhaust-the-design-space.md`
6. **Designing APIs, CLI commands, or user-facing interactions** -> `experience-first.md`
7. **Displaying metrics, benchmarks, or telemetry counts** -> `explain-the-number.md`
8. **Tempted to patch a symptom or wrap an error in retry logic** -> `fix-root-causes.md`
9. **Tackling complex legacy spaghetti or feeling blocked by tech debt** -> `foundational-thinking.md`
10. **Handling large logs, sprawling diffs, or hitting context limits** -> `guard-the-context-window.md`
11. **About to write new helper code or checking if prior art exists** -> `laziness-protocol.md`
12. **Writing scripts, database migrations, or setup routines** -> `make-operations-idempotent.md`
13. **Modifying, deprecating, or replacing a live API contract** -> `migrate-callers-then-delete-legacy-apis.md`
14. **Writing documentation, comments, or change descriptions** -> `minimize-reader-load.md`
15. **Designing domain entities, state representations, or enum types** -> `model-the-domain.md`
16. **Waiting for human reply when safe forward progress can be made** -> `never-block-on-the-human.md`
17. **Refining task milestones or verifying outcome alignment** -> `outcome-oriented-execution.md`
18. **About to claim code completion or move a task to review** -> `prove-it-works.md`
19. **Realizing an existing architecture is fundamentally flawed** -> `redesign-from-first-principles.md`
20. **Managing shared mutable state, concurrency, or DB locks** -> `separate-before-serializing-shared-state.md`
21. **Scoping large multi-step changes into deliverable units** -> `sequence-verifiable-units.md`
22. **Tempted to add flags, options, config keys, or extra parameters** -> `subtract-before-you-add.md`
23. **Writing unit tests or mocking internal implementation methods** -> `test-behavior-not-implementation.md`
24. **Using untyped primitives, loose strings, or permissive types** -> `type-system-discipline.md`
