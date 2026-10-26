---
name: align-vocabulary
description: Aligns a markdown file's vocabulary to the canonical deep-modules design language in CLAUDE.md. Invoke with a file path.
disable-model-invocation: true
---

Align a target file to the canonical vocabulary defined in `CLAUDE.md` and `skills/codebase-design/SKILL.md`. Every substitution must be grammatically integrated — sentences should read as if written with the correct term from the start. Do not change meaning, purpose, or tone.

## Canonical substitutions

| Drifting term | Canonical term | Notes |
|---|---|---|
| component, unit | **module** | Scale-agnostic — function, class, package, or tier-spanning slice. |
| service | **module** | Only when referring to a code unit. Leave unchanged when referring to a deployed process. |
| boundary | **seam** | "boundary" is overloaded with DDD's bounded context. |
| API | **interface** | "Interface" covers types, invariants, error modes, ordering, and config — not just the type signature. |
| signature | **interface** | Only when the full interface meaning applies; leave unchanged in narrow type-signature contexts. |
| tight coupling / tightly coupled | shallow modules at a wrong seam | Describe the structural cause, not the symptom. |
| high cohesion, low coupling | deep modules at a clean seam | |
| separation of concerns | depth / seam placement | Use whichever is precise for the context. |
| abstraction layer | seam | Only when describing where an interface lives. |
| pass-through, wrapper, forwarding layer | shallow module | |
| God object, God class | God module | |

## Steps

### 1. Read the file

Read the target file in full before making any changes.

### 2. Check for a redundant vocabulary section

Scan for any glossary or vocabulary section that restates terms already defined in `CLAUDE.md` (module, interface, depth, seam, adapter, leverage, locality, deletion test). If one is found, remove it and replace it with a single line:

> Use the design vocabulary defined in CLAUDE.md — module, interface, depth, seam, adapter, leverage, locality, deletion test.

Completion criterion: no vocabulary definitions remain that duplicate CLAUDE.md.

### 3. Substitute drifting terms

Work through the file applying the substitutions table. For each hit:

- Rewrite the sentence so it reads naturally with the canonical term — do not swap words in isolation.
- Preserve the original sentence's meaning, purpose, and tone.
- When a term has a legitimate non-vocabulary meaning in context (e.g. "service" as a deployed process), leave it unchanged.

Completion criterion: every drifting term has been substituted or explicitly retained with a reason, and no sentence reads like a word was simply swapped in.

### 4. Edit the file

Apply all changes directly to the file.
