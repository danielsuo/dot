---
name: explain
description: >-
  Explains technical concepts, architectures, codebases, protocols, or hardware
  with literal 10-year-old clarity, zero analogies, clean rendered visuals
  (inline SVG/HTML cards or rendered diagrams — never ASCII box art), and a
  strict high-level-first to concrete-details bullet structure. Also supports
  opt-in interactive step-by-step teaching when explicitly asked to teach. Use
  when the user says "explain", "/explain", "how does X work", "walk me through",
  "what is X", "break down X", or "teach me X".
user-invoked: true
argument-hint: "What should I explain?"
tags:
  - explanation
  - architecture
  - visualization
  - learning
---

# Explain

Explain any system, codebase, protocol, algorithm, or concept so a sharp 10-year-old can follow the **literal mechanics** on the first read — without ever dumbing down the truth or hiding behind metaphors.

---

## 1. Always-On Voice & Grounding Rules

1. **Ground in primary sources first**:
   - Read the real source files, protos, schemas, or specs before explaining; never guess from memory.
   - When referencing code in Google3 or Git-on-Borg, format every file/symbol/line citation as a clickable Code Search link (e.g. `[tpunetd_core.cc:401](http://google3/platforms/deepsea/software/superpod/routing/tpunetd/service/tpunetd_core.cc;l=401)`), never bare backticked paths.
2. **Literal 10-year-old clarity — HARD BAN on analogies**:
   - Write short, active sentences (`<subject> <concrete verb> <object>`): *reads, writes, maps, rejects, forwards, hashes*.
   - Define domain terms inline in one plain clause the first time they appear (e.g., *"an App VF (an unprivileged virtual PCIe slice mapped into the sandbox)"*).
   - **Never use analogies or metaphors**: No "traffic cops", "postal workers", "restaurant kitchens", "bouncers", "lockboxes", or "assembly lines". Analogies force the reader to map a fake system onto the real one and hide the exact boundary where bugs happen.
   - **Zero throat-clearing**: Start directly with the 1–2 sentence bottom line.

---

## 2. Mandatory Top-Down Structure (High-Level → Visual → Bullets → Details)

Follow this exact 4-part progression unless the question is a trivial 2-line factual check:

### Step 1: Bottom Line Up Front (1–2 sentences)
State plainly **what `X` is**, **what concrete problem it solves**, and **its single most important invariant or takeaway**.

### Step 2: Readable Rendered Visual (ZERO ASCII Art)
Give the reader a clean visual map of the components, data flow, or trade-offs immediately after the TL;DR.

- **Hard ban on ASCII art**: Never output `+---+`, `|   |`, `--->`, or Unicode box-drawing (`┌──┐`, `│`) diagrams. Monospace box art wraps, misaligns in proportional fonts, and breaks across narrow panes.
- **On HTML / Dashboard / Board surfaces supporting `<html-inline>`**:
  - Render an `<html-inline>` block containing either a crisp inline `<svg viewBox="...">` architecture/sequence diagram or structured HTML flow/comparison cards.
  - Use **only** theme-safe CSS variables so visuals stay crisp in both light and dark modes:
    - Surfaces & borders: `var(--sd-card)`, `var(--sd-soft)`, `var(--sd-bg)`, `var(--sd-bd)`, `var(--sd-card-bd)`
    - Text & accents: `var(--sd-fg)`, `var(--sd-muted)`, `var(--sd-accent)`, `var(--sd-working)`, `var(--sd-waiting)`, `var(--sd-bad)` (note: `var(--sd-code)` is foreground text tint only, never a background fill)
  - Enforce SVG legibility: `font-size >= 12px`, generous box padding (`>= 12px` horizontal margin around text), explicit `viewBox` with breathing room on all four edges, and orthogonal or clean curved (`<path>`) arrows with `<marker>` arrowheads that never cross through labels.
- **On Markdown / Repo / Google Docs surfaces**:
  - Use a rendered SVG/PNG diagram artifact or native ` ```mermaid ` block where the host surface renders Mermaid natively — never ASCII boxes.

### Step 3: High-Level Walkthrough (3–6 bold-lead bullets)
Walk through how `X` works end-to-end in causal order before touching edge cases:
- `**1. <Stage or Component>:** <one clear sentence stating the input, action, and output.>`
- Keep one idea per bullet so the entire flow scans in 10 seconds.

### Step 4: Zoom-In Details (Concrete Mechanics & Edge Cases)
Now unpack the exact mechanics that matter underneath:
- Concrete structs, RPC payloads, register/table layouts, or state transitions (with clickable Code Search links when explaining code).
- Constraints, failure modes, and sharp boundaries (*what `X` guarantees vs what it does NOT guarantee*).

---

## 3. Opt-In Interactive `teach` Sub-Mode

By default, **deliver the complete explanation in one turn** (do not withhold details or quiz the user unprompted).

Switch to **interactive teaching mode** *only* when the user explicitly asks to learn progressively (e.g., *"teach me X step-by-step"*, *"quiz me as we go"*, or *"set up a learning workspace for X"*):

1. **Conversational step-by-step**:
   - Scope each turn to **one** concept inside the user's zone of proximal development, formatted with the exact same zero-analogy, visual, high-level-first rules in Sections 1–2.
   - End each turn with **one** tight retrieval check or hands-on micro-task and wait for the user's reply before advancing.
2. **Stateful multi-session learning workspace** (only when explicitly requested for an ongoing course/workspace):
   - Ground lessons in `MISSION.md` ([references/mission-format.md](./references/mission-format.md)) and curated primary sources in `RESOURCES.md` ([references/resources-format.md](./references/resources-format.md)).
   - Maintain canonical terminology in `GLOSSARY.md` ([references/glossary-format.md](./references/glossary-format.md)), durable insights in `./learning-records/NNNN-slug.md` ([references/learning-record-format.md](./references/learning-record-format.md)), and self-contained HTML lessons in `./lessons/NNNN-slug.html` sharing `./assets/`.
