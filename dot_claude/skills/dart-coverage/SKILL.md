---
name: dart-coverage
description: Collect Dart or Flutter test coverage and produce an LCOV report. Use when asked for a coverage number, a coverage report, or to find untested code.
---

# Dart Test Coverage

## Standard path

```bash
dart pub add dev:coverage      # flutter pub add dev:coverage in a Flutter project
dart run coverage:test_with_coverage
```

That one script runs the suite, collects JSON from the VM, and writes both `coverage/coverage.json` and `coverage/lcov.info`. In a workspace/monorepo, name the test directories: `dart run coverage:test_with_coverage -- pkgs/foo/test pkgs/bar/test`.

Verify `coverage/lcov.info` exists and is non-empty before reporting a number.

## Reading the result

A file absent from the report was never imported by any test, which is different from being imported and untested — check the import graph before concluding code is uncovered.

For a human-readable summary: `genhtml coverage/lcov.info -o coverage/html` (requires `lcov` installed).

## Exclusions

Generated and untestable code should be excluded rather than left to drag the number down:

- `// coverage:ignore-line`
- `// coverage:ignore-start` / `// coverage:ignore-end`
- `// coverage:ignore-file`

These are honored only when the formatter runs with `--check-ignore`. The bundled `test_with_coverage` script passes it; a hand-rolled `format_coverage` invocation must include it or the directives are silently ignored.

## Manual collection

Only needed for branch/function-level metrics or control over isolate pausing. Three steps, VM service on a fixed port:

```bash
dart run --pause-isolates-on-exit --disable-service-auth-codes --enable-vm-service=8181 test &

dart run coverage:collect_coverage --wait-paused --uri=http://127.0.0.1:8181/ \
  -o coverage/coverage.json --resume-isolates

dart run coverage:format_coverage --packages=.dart_tool/package_config.json \
  --lcov -i coverage/coverage.json -o coverage/lcov.info --check-ignore
```

Append `--function-coverage` and `--branch-coverage` to the collect step for deeper metrics.
