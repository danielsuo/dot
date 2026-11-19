# The 24 Poteto Engineering Principles — Review Reference

Canonical progressive-disclosure manual for `review/SKILL.md`. Full individual manuals live in `$(find-skills-root)/../references/principles/<slug>.md` (or `~/dot/references/principles/<slug>.md`). Every review finding must cite at least one `[Principle: <slug>]` from the 24 slugs below.

---

## Lens 1 — Premise, Subtraction & First Principles

### 1. `attack-the-premise`
- **Core rule**: Question whether the problem, constraint, or layer is framed right before evaluating how cleanly it was built.
- **Review smells**: Complex machinery compensating for a self-imposed constraint; adding configuration to preserve broken behavior; automating a workflow that should be deleted.
- **Diagnostic test**: *"What if we didn't need this at all? Which assumption breaks if we delete it?"*

### 2. `subtract-before-you-add`
- **Core rule**: Remove complexity before building; leave the system simpler and behind the same or smaller surface than you found it.
- **Review smells**: New CLI flags, config keys, optional parameters, or guard clauses for speculative edge cases; stubs/empty reference files left behind; adding new features alongside unpruned legacy scaffolding.
- **Diagnostic test**: *"Was removal sequenced before construction, and is every added knob demanded by observed usage?"*

### 3. `laziness-protocol`
- **Core rule**: Write the least new code needed; check stdlib, workspace helpers, and 5-line inline functions before building abstractions.
- **Review smells**: Hand-rolled parsers, retry loops, custom CLI argument indexers, or generic mini-frameworks with a single call site.
- **Diagnostic test**: *"Does an existing library or 5 lines of boring code replace this entire module?"*

### 4. `redesign-from-first-principles`
- **Core rule**: Integrate new requirements as if they had been foundational assumptions from day one, propagating cleanly across types, docs, and invariants.
- **Review smells**: Special-case booleans, mode flags, or override hooks bolted onto an older design whose invariants contradict the new requirement.
- **Diagnostic test**: *"If we wrote this module from scratch knowing this requirement, would this seam or branch exist?"*

### 5. `exhaust-the-design-space`
- **Core rule**: Enumerate candidate designs and UX interactions systematically rather than shipping the first working shape.
- **Review smells**: Awkward API ergonomics, leaky abstractions, or clunky UI state transitions that reflect implementation order rather than deliberate choice.
- **Diagnostic test**: *"Were cleaner points in the design space overlooked because the first prototype compiled?"*

### 6. `experience-first`
- **Core rule**: When implementation convenience conflicts with consumer delight (end user, API caller, or next maintainer), choose consumer delight.
- **Review smells**: Cryptic error messages, leaky internal flags exposed to callers, rough edge transitions, or ten half-baked controls instead of three sharp ones.
- **Diagnostic test**: *"How does this feel to the caller or maintainer who reads/invokes it cold tomorrow?"*

### 7. `foundational-thinking`
- **Core rule**: Sequence work by structural leverage — get load-bearing data models, schemas, and boundaries right before building features on top.
- **Review smells**: Piling new UI/API features onto a broken state representation while deferring the schema fix to a future TODO.
- **Diagnostic test**: *"Does this harden the foundation or compound the cost of fixing it later?"*

---

## Lens 2 — Domain Model, Types & Boundaries

### 8. `model-the-domain`
- **Core rule**: Encode domain rules in data structures so invalid states are unrepresentable instead of scattering conditionals across files.
- **Review smells**: Growing `if/else` chains; two booleans that must stay in sync; temporal phase-named modules (`load` -> `validate` -> `transform` -> `save`) repeating domain checks at each step.
- **Diagnostic test**: *"Would a state machine, discriminated union, registry table, or reducer delete these branches?"*

### 9. `type-system-discipline`
- **Core rule**: Make the compiler reject impossible states, swapped primitives, and unhandled variants; derive types from authoritative schemas.
- **Review smells**: Raw `String`/`i64` passed around for distinct concepts (`UserId` vs `TaskId`); hand-rolled structs duplicating a proto/SQL/JSON schema; stringly-typed status checks.
- **Diagnostic test**: *"Can two semantically distinct arguments be accidentally swapped and still compile?"*

### 10. `boundary-discipline`
- **Core rule**: Parse external data once at trust boundaries into typed domain models (functional core, imperative shell); never leak transport/storage/framework types across public surfaces.
- **Review smells**: Raw JSON/RPC/CLI maps threaded deep into business logic; redundant nil/format checks deep inside trusted call chains; business logic entangled with I/O or HTTP frameworks.
- **Diagnostic test**: *"Is this data crossing a trust boundary right now? Can the core logic be a pure function `(State, Input) -> (State, Effects)`?"*

### 11. `minimize-reader-load`
- **Core rule**: Optimize for two independent axes — **layers to trace** (indirections) and **state to hold** (mutable/hidden context).
- **Review smells**: Single-caller wrappers; adapters with one implementation; adjacent layers that repeat the same method signatures without changing the abstraction; synced fields that could be derived purely.
- **Diagnostic test**: *"Can a new reader answer 'where does X come from?' and 'what can change X?' in under 30 seconds?"*

---

## Lens 3 — State, Concurrency, Root Causes & Migrations

### 12. `separate-before-serializing-shared-state`
- **Core rule**: Eliminate shared mutable write targets first (per-actor owned files/keys merged at read time); serialize structurally only when a single target is a real domain invariant.
- **Review smells**: Multiple workers mutating different keys of one shared `state.json`; relying on prose instructions ("don't edit X concurrently") instead of lockfiles, CAS, or single-writer ownership.
- **Diagnostic test**: *"Do these actors actually need the same mutable object, or independent owned facts merged on read?"*

### 13. `fix-root-causes`
- **Core rule**: Trace the causal chain to why the broken state arose; fix the root invariant and audit sibling instances of the same defect class.
- **Review smells**: Adding retries, `sleep`s, larger timeouts, nil guards, or `try/catch` around a symptom without explaining why the upstream invariant failed.
- **Diagnostic test**: *"Why was that value null/stale in the first place, and where else does the same pattern exist?"*

### 14. `encode-lessons-in-structure`
- **Core rule**: Encode recurring rules in types, linters, schemas, or tests rather than prose comments; once structural, delete the redundant prose instruction.
- **Review smells**: `// IMPORTANT: callers must remember to call init() first` comments where a typestate/builder or lint check would make misuse impossible.
- **Diagnostic test**: *"Can a compiler, schema, or test enforce this rule automatically so humans/agents never have to remember it?"*

### 15. `migrate-callers-then-delete-legacy-apis`
- **Core rule**: When internal APIs evolve without external compatibility commitments, migrate every caller and delete the legacy API in the same arc.
- **Review smells**: Deprecated internal helpers kept alive "just in case"; `foo_v2` shipped alongside `foo`; compatibility shims and dual code paths doubling test burden.
- **Diagnostic test**: *"Who outside this repo requires the old signature? If nobody, why isn't the old path deleted in this diff?"*

### 16. `outcome-oriented-execution`
- **Core rule**: Optimize for clean end-state architecture rather than enshrining awkward transitional compatibility bridges.
- **Review smells**: Permanent feature flags or adapter shims introduced solely to keep intermediate refactor steps friction-free after the migration finishes.
- **Diagnostic test**: *"Does every surviving line belong to the intended end-state architecture?"*

### 17. `make-operations-idempotent`
- **Core rule**: Scripts, migrations, setup routines, and CLI commands must produce the exact same result whether run once or N times, including after partial failure.
- **Review smells**: Bare `ln -s` (fails on rerun), `>>` appends without dedupe guards, `CREATE TABLE` without `IF NOT EXISTS`, or destructive steps before replacement artifacts are ready.
- **Diagnostic test**: *"What happens if this command crashes halfway through and is immediately re-run?"*

---

## Lens 4 — Behavioral Tests, Direct Proof & Numbers

### 18. `test-behavior-not-implementation`
- **Core rule**: Test observable contracts through the caller's interface; never pin private helpers, internal call order, or self-constructed mock echoes.
- **Review smells**: Tests that pass when production behavior is broken (hollow assertions, expected values computed by code under test, restated prompt/constant strings) or break on behavior-preserving refactors (over-mocked internals).
- **Diagnostic test (**Two-Edit Test**)**: *"1) Break the observable behavior — does the test fail? 2) Refactor internals while keeping outputs identical — does the test still pass?"*

### 19. `prove-it-works`
- **Core rule**: Verify the real thing directly via deterministic, rerunnable checks (`verify`); never infer correctness from proxies, mtimes, compilation alone, or fabricated data.
- **Review smells**: Claiming UI/runtime fixes from `"cargo check passed"`; hardcoded/synthetic/mock payloads in dashboards or benchmarks (`P0` blocker); unscripted one-off manual checks.
- **Diagnostic test**: *"Did a rerunnable command observe the live output directly, with verbatim exit-0 receipt?"*

### 20. `explain-the-number`
- **Core rule**: Every cited number, metric, latency, or speedup must state its numerator, denominator, population, window, and methodology.
- **Review smells**: Bare claims like `"2.4x faster"`, `"98% pass rate"`, or dashboard KPIs with unlabeled units, silent row exclusions, or mismatched baseline windows.
- **Diagnostic test**: *"Could another engineer reproduce this exact number from the stated query, denominator, and window?"*

---

## Lens 5 — Delivery Shape, Levers & Context Hygiene

### 21. `sequence-verifiable-units`
- **Core rule**: Scope changes into small, independently verifiable brackets (subtraction -> reshape -> failing test -> fix) where every unit ends green.
- **Review smells**: Entangled mega-diffs mixing mechanical moves, behavioral changes, and unrelated cleanups; code landing without its regression test.
- **Diagnostic test**: *"Can a reviewer verify each logical step cleanly without untangling unrelated edits?"*

### 22. `build-the-lever`
- **Core rule**: When work is non-trivial or spans multiple units, build and include the deterministic script, codemod, generator, or verifier check rather than hand-editing.
- **Review smells**: Dozens of hand-applied repetitive edits with subtle drift and no rerunnable check proving completeness.
- **Diagnostic test**: *"Can a reviewer rerun one deterministic script to verify every touched unit?"*

### 23. `guard-the-context-window`
- **Core rule**: Treat reader and model context as a scarce budget; keep diffs, prompts, skills, and artifacts dense and bounded.
- **Review smells**: Committed log dumps, verbose boilerplate prose in `SKILL.md` / docs, or sprawling copy-pasted test fixtures that obscure the invariant under test.
- **Diagnostic test**: *"Can 30% of the tokens/lines here be cut without losing a single invariant?"*

### 24. `never-block-on-the-human`
- **Core rule**: Resolve answerable questions through direct codebase research and give self-contained, immediately actionable review feedback.
- **Review smells**: Asking `"does caller X pass null here?"` instead of reading caller X; vague review comments (`"consider cleaning this up"`) with no concrete target shape.
- **Diagnostic test**: *"Did the reviewer verify every factual claim in code and state the exact fix?"*
