---
name: grilling
description: A relentless interview to sharpen a plan or design, which also creates docs (ADRs and ubiquitous language glossary) as you go.
disable-model-invocation: true
user-invoked: true
tags:
  - engineering
  - architecture
  - design
  - adr
---

# Grilling (with Docs)

A relentless interview to stress-test and sharpen a plan, architecture, or design, while actively capturing domain terminology (`GLOSSARY.md`) and architectural decision records (`docs/adr/`) as decisions crystallize.

---

## 1. The Grilling Protocol (Relentless Interrogation)

Interview the user relentlessly until you reach a crystal-clear shared understanding. Model the problem space as a **design tree**: every foundational decision branches into subsequent technical decisions that hang off it.

### Round-by-Round Execution
Work the design tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask *now* without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before moving to the next round.

Format each round strictly as:

```markdown
❓ **Q1** - **<question title>**: <question body, explaining the trade-off and choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, explaining the trade-off and choices>

➡️ <your recommended answer>
```

- **Phrasing rule**: Word each question so that answering "yes" or "agree" accepts your recommended answer.
- **Tree evolution**: Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock downstream questions. Recompute the frontier and ask the next round. A question whose answer depends on an open question in the current round belongs to a *later* round.
- **Finding facts**: Finding facts is your job, never the user's. When a frontier question needs environmental facts (codebase, schemas, configs, APIs), look them up or dispatch a sub-agent. Never ask the user for anything you can look up yourself.
- **Completion criteria**: The interview concludes when the frontier is empty: every branch of the design tree is visited, nothing is left silently assumed, and the user confirms a shared understanding.

---

## 2. Active Domain Modeling & Glossary Maintenance

Actively build and sharpen the project's domain model throughout the grilling session. Challenge ambiguous terms, invent edge-case scenarios, and record terms immediately when they crystallize.

### In-Flight Modeling Disciplines
1. **Challenge against the glossary**: When the user uses a term that conflicts with existing definitions in `GLOSSARY.md`, call it out immediately:
   > *"The glossary defines 'X' as A, but you seem to mean B. Which is it?"*
2. **Sharpen fuzzy language**: When vague or overloaded terms arise, propose a precise canonical term:
   > *"You said 'account': do you mean Customer or User? Those have distinct invariants."*
3. **Probe concrete scenarios**: Stress-test domain relationships with edge-case scenarios. Force explicit boundaries between concepts.
4. **Cross-reference code**: When the user describes how a system functions, verify against the actual implementation:
   > *"The implementation rejects partial cancellations, but you mentioned partial cancellation is supported. Which is correct?"*
5. **Update `GLOSSARY.md` inline**: Update `GLOSSARY.md` immediately as terms are settled. Do not batch updates at the end. Keep `GLOSSARY.md` strictly focused on domain concepts and devoid of implementation noise.

### `GLOSSARY.md` Structure
```markdown
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
A customer's confirmed request to purchase goods or services.
_Avoid_: Purchase, transaction

**Customer**:
A verified person or organization placing orders.
_Avoid_: Client, buyer, account
```

- **Single vs Multi-Context**: If `GLOSSARY-MAP.md` exists at the root, map contexts accordingly (`src/<context>/GLOSSARY.md`). Otherwise, maintain a single root `GLOSSARY.md`.

---

## 3. Architectural Decision Records (ADRs)

Capture significant architectural and design choices as lightweight ADRs in `docs/adr/`. Create the directory lazily upon the first record.

### The 3-Gate Rule for ADRs
Only offer to write an ADR when **all three** criteria are satisfied:
1. **Hard to reverse**: The cost of changing your mind later is significant (e.g. database choice, protocol contract, storage layout).
2. **Surprising without context**: A future engineer reading the code would wonder *"why on earth was it built this way?"*
3. **Result of a real trade-off**: There were viable alternatives, and one was deliberately chosen for specific reasons.

*If any criterion is missing, skip the ADR.*

### ADR Format (`docs/adr/0001-slug.md`)
```markdown
# {Short Title of Decision}

{1-3 sentences: context, decision, and why.}

## Considered Options (Optional)
- Option A: {Brief summary and why rejected}
- Option B: {Brief summary and why chosen}

## Consequences (Optional)
- {Non-obvious downstream implications}
```
Number sequentially: `0001-slug.md`, `0002-slug.md`, incrementing from the highest existing file.
