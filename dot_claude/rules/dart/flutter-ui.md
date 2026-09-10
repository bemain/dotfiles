---
paths:
  - "**/*.dart"
---

# Flutter UI Constraints

Applies to widget code. Ignore in pure Dart packages with no Flutter dependency.

## The layout contract

**Constraints go down. Sizes go up. Parent sets position.** Nearly every layout error is a failure of this negotiation:

- *"Vertical viewport was given unbounded height"* — a scrollable inside an unconstrained `Column`. Wrap it in `Expanded` (take remaining space) or `SizedBox` (fixed height).
- *"An InputDecorator...cannot have an unbounded width"* — a `TextField` in a `Row`. Wrap in `Expanded` or `Flexible`.
- *"RenderFlex overflowed"* — a child larger than its allocation. `Expanded` forces it to fit; `Flexible` lets it be smaller.
- *"Incorrect use of ParentData widget"* — `Expanded`/`Flexible` must be direct children of `Row`/`Column`/`Flex`; `Positioned` direct child of `Stack`.
- *"RenderBox was not laid out"* — cascading noise. Read further up the stack trace for the real violation.

## Adaptive layout

- Decide from available space, never from device identity. `LayoutBuilder`'s `constraints.maxWidth` for a subtree, `MediaQuery.sizeOf(context)` for the window.
- Do not branch on "phone vs tablet", and do not switch layouts on `MediaQuery.orientationOf` or `OrientationBuilder` near the root. Apps run in resizable windows, split screen, and picture-in-picture, where neither reflects usable space.
- Do not lock orientation. It letterboxes on foldables and fails Android large-format requirements.
- On wide screens, constrain rather than stretch: `ConstrainedBox(maxWidth:)` inside a `Center` for text and forms; `GridView.builder` with `SliverGridDelegateWithMaxCrossAxisExtent` for lists.
- Always `ListView.builder`/`GridView.builder` for lists of unknown or large length.

## Layering

Keep UI, data, and domain separate. A widget that fetches is a widget you cannot test.

- **View** — layout, animation, and routing only. Receives everything else from its ViewModel.
- **ViewModel** — `ChangeNotifier` exposing immutable state snapshots plus command methods. Repositories injected via constructor.
- **Repository** — single source of truth. Consumes services, returns domain models, owns caching and retry.
- **Service** — stateless wrapper over one external system (HTTP, database, plugin). Returns raw API models.
- **Use case** — only when logic clutters a ViewModel or is shared across several. Skip it for CRUD.

Group UI by feature (`ui/features/<name>/`), data and domain by type (`data/repositories/`, `domain/models/`).
