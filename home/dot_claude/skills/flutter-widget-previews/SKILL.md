---
name: flutter-widget-previews
description: Add interactive `@Preview` widget previews so UI components render in isolation without running the full app. Use when building or iterating on a reusable widget.
---

# Flutter Widget Previews

Renders a widget in isolation, hot-reloading as you edit, without booting the app or navigating to the screen. Requires Flutter 3.38+.

## Adding a preview

```dart
import 'package:flutter/widget_previews.dart';

@Preview(name: 'My Sample Text', group: 'Typography')
Widget mySampleText() => const Text('Hello, World!');
```

Valid targets are top-level functions, static methods, and public constructors or factories — all with **no required arguments**, returning `Widget` or `WidgetBuilder`. A widget whose constructor requires data needs a wrapper function that supplies sample data.

Stack multiple `@Preview` annotations on one target for multiple variants. Configure with `name`, `group`, `size`, `theme`, `brightness`.

## Viewing

In a supported IDE (Android Studio, IntelliJ, VS Code) the previewer starts automatically — open the "Flutter Widget Preview" tab. Toggle "Filter previews by selected file" to see previews beyond the active file.

From the CLI: `flutter widget-preview start`, which opens Chrome.

After editing global or static state, use the global hot restart button; for local widget state, the restart button on the individual preview card.

## Constraints of the preview environment

The previewer runs in a web environment, so:

- **No `dart:io`, `dart:ffi`, or native plugins** — including transitive dependencies. A widget that reaches one throws on invocation. Use conditional imports to substitute a stub in preview builds.
- **Asset paths must be package-qualified** for `dart:ui` `fromAsset` APIs: `packages/my_package/assets/img.png`, not `assets/img.png`.
- **Callback arguments must be public and const** to satisfy code generation.
- **Unconstrained widgets need an explicit `size:`** — the previewer otherwise constrains to roughly half the viewport, which misrepresents the layout.

## Shared configuration

Extend `Preview` to apply common wrappers (theme, padding, locale) across many widgets rather than repeating annotation arguments. Extend `MultiPreview` to expand one annotation into several variants:

```dart
final class MultiBrightnessPreview extends MultiPreview {
  const MultiBrightnessPreview({required this.name});
  final String name;

  @override
  List<Preview> get previews => const [
    Preview(brightness: Brightness.light),
    Preview(brightness: Brightness.dark),
  ];

  @override
  List<Preview> transform() => super.transform().map((p) {
    final b = p.toBuilder()
      ..group = 'Brightness'
      ..name = '$name - ${p.brightness!.name}';
    return b.toPreview();
  }).toList();
}
```

Override `transform()` when a preview's configuration must be computed at runtime — annotation arguments are `const`, so anything derived from a non-const value has to be built there.
