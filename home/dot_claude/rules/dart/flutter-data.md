---
paths:
  - "**/*.dart"
---

# Dart Networking and Serialization

Applies to code performing HTTP calls or JSON mapping.

## Requests

- Parse URLs with `Uri.parse(...)`. Do not pass raw strings where a `Uri` is expected.
- Import with a prefix: `import 'package:http/http.dart' as http;`.
- Inject the `http.Client` through the constructor. A class that news up its own client cannot be tested without a network.
- For POST/PUT set `'Content-Type': 'application/json; charset=UTF-8'` and encode the body with `jsonEncode`.

## Responses

- **Throw on failure; never return `null`.** A `null` return leaves `FutureBuilder` unable to enter its error state, producing a spinner that never resolves. Success is 200 for GET/PUT/DELETE, 201 for POST.
- Include the status code in the thrown message. `Failed to load photos. Status: 404` is actionable; `Failed to load photos` is not.
- Cast the `dynamic` from `jsonDecode` at the boundary — `as Map<String, dynamic>` or `as List<dynamic>` — rather than letting `dynamic` propagate inward.

## Models

- Plain classes with `final` fields, a `factory Model.fromJson(Map<String, dynamic>)`, and a `Map<String, dynamic> toJson()`.
- Prefer a map pattern in `fromJson` over field-by-field casts — it validates shape and destructures in one step, and throws `FormatException` on a payload that does not match:

```dart
factory User.fromJson(Map<String, dynamic> json) => switch (json) {
  {'id': int id, 'name': String name} => User(id: id, name: name),
  _ => throw const FormatException('Failed to load User.'),
};
```

## Isolates

Parsing that exceeds a frame budget (~16ms) — typically arrays of hundreds of objects — belongs in `compute(parseFn, body)`. The function passed must be top-level or static; closures and instance methods cannot cross an isolate boundary.

## Platform permissions

Network access requires `<uses-permission android:name="android.permission.INTERNET" />` in `AndroidManifest.xml`, and `com.apple.security.network.client` in both `DebugProfile.entitlements` and `Release.entitlements` on macOS. A request that fails only on device is usually this.
