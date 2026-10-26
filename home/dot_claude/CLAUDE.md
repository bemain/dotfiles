# Claude Code - Personal Configuration

## Memory System

- `MEMORY.md` is the index — always loaded. Each entry points to a file in `memory/`.
- Read linked memory files before starting work when they seem relevant.
- Save new memories immediately when: a user preference is stated, feedback is given, a project decision is made.
- Memory types: **user** (who they are), **feedback** (how to work), **project** (ongoing context), **reference** (where things live).
- Do not save ephemeral task state, code patterns already in the codebase, or git history.

## Response Style

- Terse. No trailing summaries after tool calls - the diff is visible.
- Do not tell me I am right all the time. Be critical. We're equals. Try to be neutral and objective.
- No emoji unless explicitly requested.
- One sentence per status update while working.
- Complete sentences, no unexplained shorthand.
- Prefer using browser agent skill over using playwright directly.
- When referencing code, include `file_path:line_number`.

## Code Style

- No comments unless the WHY is non-obvious.
- Comment the current state only, not changes made. The git log contains that.
- No error handling for scenarios that cannot happen.
- No features beyond what the task requires.

## Rules

Language- and framework-specific rules live in `rules/`, discovered recursively. A rule with no
frontmatter loads every session; one with `paths:` frontmatter loads only when a matching file is
read, so scope anything language-specific that way.

```markdown
---
paths:
  - "**/*.dart"
---
```

## Agents

Custom subagent definitions live in `agents/`. Use the Agent tool with `subagent_type` matching the agent filename slug.

When both `Grep` and `mgrep` are available, prefer `mgrep`.

## Tools

Use `mgrep` and `graphify` for codebase exploration and search. Never use `grep`, `cat`, `find`, or shell equivalents when `mgrep` is available.

## Code Navigation

Prefer LSP operations over grep for symbol lookups:
- `goToDefinition` - find where a symbol is defined.
- `findReferences` - find all usages of a symbol.
- Only use grep for literal string searches with no semantic intent.



# Codebase Design

Design **deep modules**: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface. The aim is leverage for callers, locality for maintainers, and testability for everyone.

Vocabulary - use these terms exactly: **module** (not component/service/unit), **interface** (not API/signature), **seam** (not boundary), **adapter**, **depth**, **leverage**, **locality**.

Full reference, diagrams, and testability patterns: `skills/codebase-design/SKILL.md`.


## Workflow

Before implementing anything: search GitHub code first, then check library docs (Context7 / vendor docs), then Exa only if those are insufficient. Check package registries before writing utility code — prefer adopting a proven library over hand-rolling.
