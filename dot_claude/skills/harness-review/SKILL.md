---
name: harness-review
description: Convene a panel of reviewer agents to grade skills against writing-great-skills criteria and consolidate the verdicts into a single HTML report.
disable-model-invocation: true
metadata:
  origin: AkzelchCC
---

# harness-review

Convene a **panel** of parallel reviewer agents. Each panelist grades a slice of the skill inventory against the writing-great-skills rubric and returns a markdown report. The orchestrator then synthesizes every report into one HTML page.

Use when auditing a non-trivial set of skills for design quality. For a single skill, read it yourself. For usage/freshness scans, use `/skill-stocktake`.

## Steps

### 1. Set up the workspace

Create `skills_eval/` in the current working directory if absent. Inside it, create `skills_eval/<UTC-timestamp>/` and bind it as `WORKSPACE`. All panelist reports and the final HTML land here.

**Done when:** `WORKSPACE` exists and is empty.

### 2. Inventory and slice

Enumerate every `SKILL.md` under review (default: every `SKILL.md` beneath `skills/`). Group them into 4–8 slices balanced by total line count of `SKILL.md` — one 600-line skill outweighs ten 50-line skills. Write `WORKSPACE/slices.md` listing each slice and its assigned skill paths.

**Done when:** every skill is in exactly one slice and `slices.md` reflects the assignment.

### 3. Brief the panel

Launch one Agent per slice, **in parallel**, `subagent_type: general-purpose`, model: sonnet. Each brief must contain:

- Instruction to invoke the Skill tool with `akzelchcc:writing-great-skills` and read its `GLOSSARY.md` before grading. If the Skill tool is unavailable, fall back to reading `skills/writing-great-skills/SKILL.md` and `skills/writing-great-skills/GLOSSARY.md`.
- The slice's skill paths.
- The rubric (see [Rubric](#rubric)) and the report format (see [Report format](#report-format)).
- Output path: `WORKSPACE/<slice-name>.md`.
- Hard rule: the panelist reviews, never edits, the skills.

**Done when:** every panelist has written its report file at the specified path. Re-launch any panelist that returns without one — do not paper over a missing report.

### 4. Read every report in full

Open each `WORKSPACE/<slice-name>.md` end-to-end before drafting any HTML. The report file is the source of truth; the panelist's chat summary is a paraphrase and must not be used as input to synthesis.

**Done when:** every report file has been read this turn.

### 5. Synthesize the HTML

Write `WORKSPACE/index.html`. Split into multiple linked pages only if a single page would exceed ~2000 rendered lines.

Required sections, in order:

1. **Summary table** — one row per skill: name, path, verdict, top issue, severity. Sortable is nice, not required.
2. **Failure-mode index** — one section per failure mode {premature completion, duplication, sediment, sprawl, no-op, weak leading word, wrong invocation tier, weak description}, each listing the skills that exhibit it.
3. **Per-skill detail** — anchored from the summary table, carrying the panelist's full findings and recommendation verbatim.

Style: factual, terse, no decorative prose. Inline CSS only — no external CDN, no JS framework.

**Done when:** `index.html` renders in a browser and every skill from `slices.md` appears in the summary table.

## Rubric

Each axis gets one of {pass, weak, fail} with a one-line reason.

| Axis | Pass means |
|------|-----------|
| Invocation tier | Model-invocation choice matches the skill's reach needs. User-invoked skills carry no trigger list in the description. |
| Description | Front-loads a leading word; one trigger per branch; no identity restated from the body. |
| Information hierarchy | Steps have checkable completion criteria. Reference is co-located. Progressive disclosure is used where branches diverge. |
| Granularity | Splits are justified by independent reach or by hiding post-completion steps — not split for its own sake. |
| Pruning | No duplicated meanings; every line passes the relevance and no-op tests. |
| Leading words | Repeated concepts collapse onto a pretrained word rather than being restated. |
| Failure modes | No observable premature-completion bait, sediment, or sprawl. |

## Report format

Each panelist writes a markdown file shaped exactly as below. No prose introduction, no closing remarks.

```markdown
# Panel report — slice <name>

## <skill-name>

- Path: <path>
- Verdict: {keep | improve | rework | retire}
- Axis grades: invocation=<p|w|f>, description=<p|w|f>, hierarchy=<p|w|f>, granularity=<p|w|f>, pruning=<p|w|f>, leading-words=<p|w|f>, failure-modes=<p|w|f>
- Top issue: <one sentence>
- Recommendation: <one to three sentences, concrete>
```
