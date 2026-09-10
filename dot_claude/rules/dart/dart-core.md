---
paths:
  - "**/*.dart"
  - "**/analysis_options.yaml"
---

# Dart Language Constraints

## Type soundness

- Never tighten a parameter type in an override without `covariant`. Return types may narrow; parameter types may not.
- Annotate generics explicitly. `<int>[]`, never a bare `[]` that infers `List<dynamic>` and fails at the assignment.
- Avoid implicit downcasts from `dynamic`. An explicit `as T` is acceptable only when the runtime type is guaranteed; otherwise it converts a static error into a `TypeError`.

## Null safety

- `late` is for non-nullable fields whose initialization the analyzer cannot prove, not for silencing the analyzer. If initialization is genuinely conditional, the type is nullable.
- Prefer `?.` and `??` over `!`. Each `!` is a claim you are asserting against the type system.
- Use `_` for non-binding locals and parameters rather than naming something you do not read.

## Errors vs exceptions

- Catch `Exception` subtypes. Never catch `Error` or its subtypes — `TypeError`, `ArgumentError`, and `StateError` signal bugs to fix, not conditions to handle. Enable `avoid_catching_errors`.
- Use `rethrow`, not `throw e`, to preserve the original stack trace.
- Do not swallow exceptions in low-level code. Let them reach a layer that can decide.

## Prefer pattern matching

- Producing a value: use a switch expression (`switch (x) { pattern => value, }`), not a switch statement with assignments.
- Type-dispatched behavior: `sealed` class + object patterns. The analyzer then enforces exhaustiveness, so a new subtype becomes a compile error rather than a silent fallthrough.
- Validating and destructuring in one step (JSON, records): map and list patterns, e.g. `if (data case {'user': [String name, int age]})`.
- Guard with `when` for conditions patterns cannot express. Reach for `default`/`_` only when a fallback is genuinely correct — on a sealed type it discards exhaustiveness checking.

## Before considering Dart work done

Run `dart analyze` (or `flutter analyze`). Apply `dart fix --apply` for mechanical lints, then `dart format .`. Treat a clean analyzer as the floor, not the goal.

Suppress a diagnostic only with a reason: `// ignore: <code>` on the line above, `// ignore_for_file: <code>` for generated code. Prefer excluding generated files wholesale via `analyzer: exclude:` over scattering ignores.
