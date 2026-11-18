---
name: specify
description: "Turn the current conversation and codebase understanding into a structured, production-ready specification (SPEC.md or docs/specs/): no interview, just synthesis of what you've already discussed."
disable-model-invocation: true
user-invoked: true
tags:
  - engineering
  - architecture
  - specification
  - design
---

# Specify (to-spec)

This skill takes the current conversation context, design decisions, and codebase understanding to produce a comprehensive specification document (e.g. `SPEC.md` or `docs/specs/<feature>.md`).

Do NOT interview the user; synthesize what you already know from the conversation and exploration.

---

## Process

1. **Codebase Exploration**:
   Explore the repository to understand the current state of the codebase. Respect existing architectural decision records (ADRs) and use the project's domain glossary vocabulary throughout the specification.

2. **Seam Identification**:
   Sketch out the seams at which you are going to test the feature.
   - Existing seams should always be preferred over new ones.
   - Use the highest seam possible.
   - The fewer seams across the codebase, the better (ideally one).
   - Check with the user that these seams match their expectations.

3. **Synthesize Specification**:
   Write the specification following the structure below into `SPEC.md` (or the project's designated specification path).

---

## Specification Template

```markdown
# Specification: <Feature / Component Name>

## Problem Statement
The problem that the user or system is facing, from the user's perspective.

## Solution
The high-level technical solution to the problem, from the user's perspective.

## User Stories
An extensive, numbered list covering all functional aspects of the feature.
Format:
1. As an <actor>, I want a <feature>, so that <benefit>

## Implementation Decisions
A concrete list of technical decisions:
- Modules to build, extend, or modify
- Module interfaces and signatures
- Technical clarifications and architectural tradeoffs
- Schema changes and data structures
- API contracts and protocols
- Specific behavioral interactions

Note: Do NOT include volatile code snippets or line numbers unless a prototype has produced an invariant data structure, reducer, or state machine that encodes a decision more precisely than prose.

## Testing Decisions
A rigorous list of testing decisions:
- External behavioral assertions (never assert on private implementation details)
- Target modules and test boundaries
- Prior art and reference test patterns in the codebase
- Verification harness commands and stages

## Out of Scope
Explicit list of non-goals and capabilities excluded from this milestone.

## Further Notes
Operational notes, follow-up milestones, or deployment considerations.
```
