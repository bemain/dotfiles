---
name: dart-pub-conflicts
description: Resolve Dart/Flutter dependency version conflicts and audit stale packages. Use when `pub get` or `pub upgrade` fails to resolve, or a package is retracted or discontinued.
---

# Resolving Pub Dependency Conflicts

## Why conflicts happen

Pub enforces a single resolved version of every package across the whole transitive graph. That prevents runtime type mismatches between two copies of a library, and it is also why one over-tight constraint anywhere can block the entire resolution.

`pubspec.yaml` holds constraints; `pubspec.lock` holds the resolved versions. Fix conflicts by changing constraints, not by pinning.

## Read `dart pub outdated` correctly

The four columns mean different things and the fix differs per column:

- **Current** — what `pubspec.lock` holds now.
- **Upgradable** — the newest version your existing constraints allow. `dart pub upgrade` reaches this without editing `pubspec.yaml`.
- **Resolvable** — the newest version reachable if you widen the constraint, given everything else in the graph. Requires a `pubspec.yaml` edit.
- **Latest** — newest published. If Latest exceeds Resolvable, something else in the graph is holding you back; find it with `dart pub deps`.

## Fixing a failed resolution

**Never delete `pubspec.lock` wholesale.** It resolves the error by upgrading everything at once, converting one known conflict into an unknown number of behavior changes.

Instead, delete only the offending package's block from `pubspec.lock` and run `dart pub get`. Pub then re-resolves that single entry — the correct move for a retracted version.

If that fails, the constraint is coming from a dependency rather than from you. Run `dart pub deps` to find which package requires the incompatible range, then widen or bump that package in `pubspec.yaml`.

## Upgrading deliberately

```bash
dart pub upgrade              # move to Upgradable
dart pub upgrade --tighten    # raise lower bounds in pubspec.yaml to what resolved
```

For a major bump, edit the constraint in `pubspec.yaml` to match the Resolvable column (`^0.11.0` → `^0.12.1`), then `dart pub upgrade`.

After any upgrade, run `dart analyze` for breaking API changes and `dart test` for behavioral regressions. A resolution that succeeds is not the same as an upgrade that works.

## Constraint hygiene

- Caret syntax (`^1.2.3`) for dependencies — allows non-breaking updates during resolution.
- Tighten `dev_dependencies` lower bounds to what you actually use; loose dev constraints add resolution work for no benefit.
- `dart pub get --enforce-lockfile` in CI, so CI builds what you tested.
