---
name: flutter-app-setup
description: One-time Flutter project bootstrap — declarative routing with go_router, deep linking, and localization with intl/ARB files. Use when initializing these in a project or adding a route, locale, or translated string.
---

# Flutter App Setup

Two independent bootstrap tasks. Read only the section you need.

- [Routing and deep linking](#routing-with-go_router)
- [Localization](#localization-with-intl-and-arb)

Native platform configuration for deep links (Android manifest, iOS entitlements, `assetlinks.json`, AASA) lives in `references/deep-linking.md` — read it only when wiring URLs from outside the app.

## Routing with go_router

```bash
flutter pub add go_router
```

Define one top-level `GoRouter` and hand it to `MaterialApp.router`:

```dart
void main() {
  usePathUrlStrategy();   // from flutter_web_plugins/url_strategy.dart
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details/:id',
          builder: (context, state) =>
              DetailsScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);

// MaterialApp.router(routerConfig: _router)
```

`usePathUrlStrategy()` removes the `#` fragment from web URLs. Without it, deep links and shared URLs carry the fragment and do not match server-side routes.

Child routes nest under a parent's `routes:` and inherit its path prefix — `'details/:id'` above resolves to `/details/:id`. Leading slashes on nested paths break that.

Authentication and other state-dependent redirects belong in `GoRouter`'s `redirect` parameter, not in individual screens' `build` methods.

### Navigating

```dart
context.go('/details/123');      // replaces the stack — declarative
context.push('/details/123');    // pushes onto it — imperative
context.goNamed('details', pathParameters: {'id': '123'});
context.pop();
```

### Persistent shells

A bottom navigation bar that must preserve each tab's stack needs `StatefulShellRoute.indexedStack` with one `StatefulShellBranch` per tab. A plain `ShellRoute` shares one navigator and loses per-tab state.

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      ScaffoldWithNavBar(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(routes: [GoRoute(path: '/home',     builder: ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: ...)]),
  ],
)
```

The shell widget renders `navigationShell` as its body and switches branches via `navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex)` — that flag is what makes tapping the active tab return to its root.

## Localization with intl and ARB

```bash
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl:any
```

Then `generate: true` under the `flutter:` section of `pubspec.yaml`, and an `l10n.yaml` at the project root:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
synthetic-package: true
```

Wire the delegates into `MaterialApp`:

```dart
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [Locale('en'), Locale('es')],
```

Omitting the three `Global*` delegates leaves Flutter's own widgets — date pickers, text selection menus — in English regardless of locale.

### Adding a string

New strings go in the template file (`lib/l10n/app_en.arb`) with a description, then into each other locale's file:

```json
{
  "helloWorld": "Hello World!",
  "@helloWorld": { "description": "The conventional newborn programmer greeting" }
}
```

`flutter pub get` regenerates `AppLocalizations`. ARB syntax errors surface there — a missing comma or a placeholder present in one locale but not another.

Read strings with `AppLocalizations.of(context)!.helloWorld`. The calling widget must be below `MaterialApp` in the tree; above it, `of(context)` returns null.

### Placeholders, plurals, selects

```json
"hello": "Hello {userName}",
"@hello": {
  "placeholders": { "userName": { "type": "String", "example": "Bob" } }
},

"nWombats": "{count, plural, =0{no wombats} =1{1 wombat} other{{count} wombats}}",
"@nWombats": {
  "placeholders": { "count": { "type": "num", "format": "compact" } }
},

"pronoun": "{gender, select, male{he} female{she} other{they}}",
"@pronoun": {
  "placeholders": { "gender": { "type": "String" } }
}
```

The `other` case is mandatory for both `plural` and `select`. Every placeholder needs a declared `type` or generation fails.
