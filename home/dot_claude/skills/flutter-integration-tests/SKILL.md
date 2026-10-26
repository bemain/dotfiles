---
name: flutter-integration-tests
description: Set up and run Flutter end-to-end tests with the integration_test package and `flutter drive`, on device, Chrome, or Firebase Test Lab. Use for full app-flow tests, not single-widget tests.
---

# Flutter Integration Tests

Test conventions (file layout, finders, `pump` vs `pumpAndSettle`) come from the `dart-testing` rule, which loads automatically for files under `integration_test/`. This skill covers only what integration testing adds: the binding, the driver, and the run targets.

## Setup

```bash
flutter pub add 'dev:integration_test:{"sdk":"flutter"}'
flutter pub add 'dev:flutter_test:{"sdk":"flutter"}'
```

Two files are required beyond the test itself:

**`integration_test/app_test.dart`** — the test. Must call the integration binding before anything else, or the test runs as an ordinary widget test with no device:

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('increments the counter', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byKey(const ValueKey('increment')));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });
}
```

**`test_driver/integration_test.dart`** — the host driver:

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

Add `ValueKey`s to the widgets the test drives before writing the test.

## Running

```bash
# device or emulator
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

# Chrome — chromedriver --port=4444 must already be running in another terminal
flutter drive --driver=... --target=... -d chrome

# headless
flutter drive --driver=... --target=... -d web-server
```

Firebase Test Lab (Android) takes two APKs: `flutter build apk --debug`, then `./gradlew app:assembleAndroidTest`, then upload both.

## Interactive exploration

When the Dart/Flutter MCP server is available, explore before writing static assertions: `launch_app` to start and get the DTD URI, `get_widget_tree` to discover real keys and types, `tap`/`enter_text`/`scroll` to walk the flow. This finds wrong key names and unmounted widgets faster than a failing test run does.

Driving the app this way requires `enableFlutterDriverExtension()` before `runApp()` — put it in a dedicated `lib/main_test.dart` rather than shipping it in `lib/main.dart`.

## When a run fails

- **`PumpAndSettleTimedOutException`** — something animates forever. A looping animation, or a spinner that never resolves because a stubbed network call never completes.
- **Widget not found that should exist** — lazily built inside a `ListView`/`SliverList` and never mounted. `scrollUntilVisible` first.
- **Legacy `flutter_driver` tests** use `driver.waitFor`/`driver.tap`/`driver.scroll` instead of the `WidgetTester` API. Do not mix the two in one file.
