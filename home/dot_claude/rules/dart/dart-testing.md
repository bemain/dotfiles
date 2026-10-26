---
paths:
  - "**/*_test.dart"
  - "**/test/**/*.dart"
  - "**/integration_test/**/*.dart"
  - "**/test_driver/**/*.dart"
---

# Dart and Flutter Test Conventions

## Layout

- `test/` mirrors `lib/`. `lib/src/utils.dart` is tested by `test/src/utils_test.dart`.
- Every test file ends in `_test.dart`, or the runner skips it.
- Integration tests live in `integration_test/` at the package root. The default runner ignores that directory — pass it explicitly: `flutter test integration_test`.

## Library

Pure Dart uses `package:test`; Flutter uses `package:flutter_test`. Run with `dart test` and `flutter test` respectively. Do not import `package:test` into a Flutter test — it will not provide `WidgetTester`.

## Mocks

- `@GenerateNiceMocks([MockSpec<Dep>()])`, not `@GenerateMocks`. Nice mocks return sensible defaults instead of throwing `MissingStubError` on the first uninterested call.
- Generate with `dart run build_runner build`, import the result as `<name>_test.mocks.dart`.
- **Stub async returns with `thenAnswer((_) async => value)`, never `thenReturn`.** `thenReturn` on a `Future`-returning method throws at stub time. This is the most common mockito failure.
- Mock at an injected seam. If a class constructs its own `http.Client`, fix the constructor rather than reaching for a heavier mocking tool.

## Widget tests

- `pumpWidget` once to build. Wrap in `MaterialApp` or `Directionality` when the widget needs inherited theme or direction data.
- `pump()` advances one frame — right for a `setState` after a tap. `pumpAndSettle()` runs frames until none are scheduled — required for animations and transitions, and it hangs on an infinite animation (`PumpAndSettleTimedOutException` means you have one, or a perpetual loading spinner).
- Prefer `find.byKey(ValueKey(...))` for anything a test drives. `find.byType` and `find.text` are brittle against refactors and localization.
- Off-screen list items are not mounted. `scrollUntilVisible` before interacting, or the finder legitimately finds nothing.

## Assertions

Group with `group()`, share fixtures via `setUp()`. Assert with `expect()` and real matchers — `equals`, `throwsA`, `findsOneWidget`, `findsNothing`, `findsNWidgets(n)` — rather than hand-rolled boolean comparisons that report "false is not true" on failure.
