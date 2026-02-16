# scroll_edge_hint

`scroll_edge_hint` shows subtle edge fades only where more scrolling is possible.
It improves scroll affordance for lists, horizontal chips, and carousels without forcing persistent scrollbars.

## Why this package

- Users often miss that a list or chip row is scrollable.
- Platform glow/overscroll behavior is inconsistent.
- Design systems keep re-implementing edge fades.

`scroll_edge_hint` provides a reusable, lightweight hint layer.

## Features

- Supports `ListView`, `GridView`, `SingleChildScrollView`, `CustomScrollView`, and any scrollable that emits `ScrollNotification`.
- Vertical and horizontal scrolling.
- Correct leading/trailing placement from `axisDirection` (including `reverse` and RTL).
- Proportional strength model: hints fade near scroll boundaries.
- `ScrollEdgeHint.builder` for controller-safe integration.
- Customizable via `edges`, `extent`, `maxOpacity`, `fadeInDistance`, `backgroundColor`, `animationDuration`, `animationCurve`, and `hintBuilder`.

## Quick start

### Basic

```dart
ScrollEdgeHint(
  child: ListView.builder(
    itemCount: 100,
    itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
  ),
)
```

### Recommended (builder pattern)

```dart
ScrollEdgeHint.builder(
  builder: (context, controller) => ListView.builder(
    controller: controller,
    itemCount: 100,
    itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
  ),
)
```

## Background color note

`overlayFade` needs a base color. If `backgroundColor` is null, it uses `Theme.of(context).scaffoldBackgroundColor`.
If your scrollable sits on a card/panel, pass `backgroundColor` explicitly for seamless blending.

## Performance notes

- Hints are rendered as overlay layers in a `Stack`.
- Decorative overlays are wrapped with `IgnorePointer` and `ExcludeSemantics`.
- State updates are thresholded to avoid unnecessary rebuilds.

## API

- `ScrollEdgeHint`
- `ScrollEdgeHint.builder`
- `EdgeHintEdges`
- `EdgeHintEffect`
- `EdgeHintSide`
- `EdgeHintStrength`
- `EdgeHintBuilder`

## Example

See `/example` for demos:

- Vertical List Demo
- Horizontal Chips Demo (with RTL toggle)
