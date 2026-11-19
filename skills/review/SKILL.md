---
name: review
description: >-
  Reviews code diffs, commits, branches, PRs, or Piper CLs against all 24
  poteto engineering principles (references/principles.md), domain invariants,
  behavioral test oracle strength, and verification proof. Auto-triggers on
  "review", "/review", "code review", "review my changes", "review CL",
  "review diff", or post-verify Reviewer Agent handoffs.
user-invoked: true
argument-hint: "[diff target, commit, branch, or CL]"
tags:
  - engineering
  - code-review
  - architecture
  - principles
---

# Review

Adversarial, high-signal code and architecture review grounded in the 24 poteto engineering principles ([`references/principles.md`](references/principles.md)). Evaluates whether a change solves the right problem at the right boundary with minimal surface area, unrepresentable invalid states, behavioral tests, and direct execution proof.

---

## 1. Execution Mode & Full-Context Gathering

1. **Fresh-Context Isolation**:
   - When triggered as a post-`verify` gate by an authoring agent, run in a **fresh-context subagent** (or dedicated `@reviewer` agent) so the audit is unanchored from author sunk cost.
   - When invoked directly by the user (`/review`), audit the requested diff, commit, branch, or CL in place.
2. **Never Review Blind Hunks** (`[Principle: never-block-on-the-human]`):
   - Read the complete diff (`git diff`, `hg diff`, `jj diff`, `g4 diff`, or `critique readonly diff <cl>`) **plus surrounding file context**, callers, types, `SPEC.md`, `GLOSSARY.md`, `docs/adr/`, and `./verifiers/` (or `verify path`).
   - Look up facts in the codebase yourself; never ask the author questions the repository already answers.

---

## 2. The 5 Review Lenses (All 24 Poteto Principles)

Load [`references/principles.md`](references/principles.md) (and read full manuals in `$(find-skills-root)/../references/principles/<slug>.md` when deep-diving a violation). Audit every change across all five lenses:

### Lens 1 — Premise, Subtraction & First Principles
- **`attack-the-premise`**: Does this solve the real problem, or build machinery around a broken assumption or symptom workaround? Ask whether the feature/layer should exist at all.
- **`subtract-before-you-add`**: Were flags, config keys, extra parameters, wrapper layers, or speculative guards added without observed need? Did deletion happen before construction? Flag dead stubs left behind.
- **`laziness-protocol`**: Did the author hand-roll a parser, retry loop, helper, or mini-framework where a stdlib primitive, existing repo helper, or 5-line function already works?
- **`redesign-from-first-principles`**: Was the new requirement integrated across types, invariants, and docs as if foundational from day one, or bolted onto the old shape with special-case branches?
- **`exhaust-the-design-space`**: On architectural or UX-feel decisions, did the change settle on the first working option instead of evaluating sharper alternatives?
- **`experience-first`**: Weigh ergonomics from the consumer's and next maintainer's perspective — tight core loop, clear error states, zero implementation-convenience leaks.
- **`foundational-thinking`**: Are load-bearing types, schemas, and invariants fixed before piling features on top of debt?

### Lens 2 — Domain Model, Types & Boundaries
- **`model-the-domain`**: Are invalid states unrepresentable via state machines, discriminated unions, lookup tables, or reducers? Flag growing `if/else` chains, synced booleans, and temporal phase-named modules (`load`/`validate`/`transform`).
- **`type-system-discipline`**: Are semantic primitives branded (`UserId` vs `OrderId`) rather than raw strings/ints? Are types derived from authoritative schemas instead of hand-rolled in parallel?
- **`boundary-discipline`**: Parse, don't validate: untrusted input (CLI, RPC, JSON, DB, env, files) is parsed once at the trust boundary into typed domain data; core logic stays pure (functional core / imperative shell) with zero transport/framework type leakage or redundant deep nil checks.
- **`minimize-reader-load`**: Apply the **30-second test** — can a new reader answer *"where does X come from?"* and *"what can change X?"* in under 30 seconds? Flag single-caller wrappers, pass-through layers that don't change the abstraction, broad shallow interfaces, and synced mutable state that should be derived.

### Lens 3 — State, Concurrency, Root Causes & Migrations
- **`separate-before-serializing-shared-state`**: When concurrent actors touch state, first ask whether sharing can be eliminated (per-actor owned files/keys merged at read time). Only when one shared target is a true invariant, require structural serialization (lockfiles, CAS, single-writer actor) — never prose conventions.
- **`fix-root-causes`**: Trace the causal chain on bug fixes. Reject symptom whack-a-mole (blind retries, timeouts, nil guards, catch-and-swallow) and verify sibling call sites for the same defect class.
- **`encode-lessons-in-structure`**: Convert prose warnings, doc caveats, and recurring review feedback into compile-time types, lint rules, schema constraints, or invariant tests — and delete redundant prose once structural.
- **`migrate-callers-then-delete-legacy-apis`**: When internal APIs change without external compatibility obligations, require migrating all callers and deleting the legacy path/shim in the same arc.
- **`outcome-oriented-execution`**: Ensure rewrites and migrations converge on the clean target architecture rather than preserving transitional compatibility scaffolding as permanent debt.
- **`make-operations-idempotent`**: Scripts, database migrations, setup hooks, and CLI commands must converge to the exact same state when run twice (`ln -sfn`, atomic temp-and-rename, upserts).

### Lens 4 — Behavioral Tests, Direct Proof & Numbers
- **`test-behavior-not-implementation`** (**The Two-Edit Test**): Judge every test against two imagined edits:
  1. *Break the behavior* (wrong return, skipped or doubled effect): if the test still passes, reject it as hollow/tautological (expected value computed by code under test, restated constants, synthetic self-asserted mocks).
  2. *Change the internals* (restructure private helpers/call order while keeping observable outputs identical): if the test fails, reject it as brittle implementation-pinning.
- **`prove-it-works`**: Reject proxy verification (`"it compiles"`, file mtimes, cached outputs, self-reports) and **block (`P0`) any fake, mock, synthetic, interpolated, or hardcoded data** in dashboards, benchmarks, or production paths. Require verbatim `verify` execution receipts (`exit 0`).
- **`explain-the-number`**: Every metric, latency, count, or speedup cited in code, UI, or CL descriptions must specify numerator, denominator, population, time window, and reproducible query/command provenance.

### Lens 5 — Delivery Shape, Levers & Context Hygiene
- **`sequence-verifiable-units`**: Changes must be scoped into coherent, independently checkable units (or clean commit stacks: subtraction -> reshape -> failing test -> fix) with code and tests landing together.
- **`build-the-lever`**: Non-trivial sweeps, codemods, data checks, or multi-file migrations should include the deterministic, rerunnable script or verifier that performs/proves the work instead of uncheckable hand-edits.
- **`guard-the-context-window`**: Flag committed build/log dumps, bloated prompts, redundant doc stubs, or sprawling diffs mixing unrelated churn.

---

## 3. Severity Taxonomy

- **`P0` (Blocker)**: Broken correctness, data loss/race, security/trust-boundary hole, fabricated/mock data in non-test outputs, hollow test masking a bug, or failing `verify` stage.
- **`P1` (High)**: Violation of core architecture/domain boundaries, symptom band-aid instead of root cause, zombie legacy shim left behind, brittle implementation-pinned tests, or unguarded shared mutable state.
- **`P2` (Medium)**: Unnecessary complexity, extra flags/layers (`subtract-before-you-add`, `minimize-reader-load`), unbranded primitive soup, non-idempotent script, or unexplained metric numbers.
- **`P3` (Low)**: Localized simplification, naming sharpness against `GLOSSARY.md`, or minor dead code removal.

Suppress rubber-stamp praise, diff narration, and whitespace/formatting nits already enforced by formatters (`verify compile`).

---

## 4. Output Contract

Lead **top-down** with the verdict (`APPROVE` or `CHANGES REQUESTED`), a 1–2 sentence architectural summary, and a clean `<html-inline>` summary table (when rendered in HTML-capable chat surfaces; otherwise a compact Markdown table — **never ASCII box art**), followed by prioritized findings (`P0` -> `P3`).

Every finding **must** include all four elements:
1. **Header**: `[P0|P1|P2|P3]` + clickable `file:line` link (e.g. `[path/to/file.rs:42](http://google3/path/to/file.rs;l=42)` in Google3, or repo-relative `[src/foo.rs:42](src/foo.rs#L42)`) + `[Principle: <slug>]`
2. **Violation**: Exact failure mode, invariant breach, or reader-load / state cost (1–3 sentences)
3. **Subtraction / Fix**: Specific code to delete, boundary/type to reshape, or behavioral test to add

If zero findings remain after auditing all five lenses, return `APPROVE` and list the concrete invariants, callers, and `verify` receipts verified.
