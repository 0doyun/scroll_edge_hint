import 'package:flutter/widgets.dart';

import 'types.dart';

enum _ScreenEdge { top, bottom, left, right }

Widget buildDefaultEdgeHint(
  BuildContext context,
  EdgeHintSide side,
  Axis axis,
  AxisDirection axisDirection,
  double opacity,
  double extent,
  Color color,
) {
  final _ScreenEdge edge = _resolveScreenEdge(side, axisDirection);

  final Alignment begin;
  final Alignment end;
  final double? width;
  final double? height;

  switch (edge) {
    case _ScreenEdge.top:
      begin = Alignment.topCenter;
      end = Alignment.bottomCenter;
      width = null;
      height = extent;
      break;
    case _ScreenEdge.bottom:
      begin = Alignment.bottomCenter;
      end = Alignment.topCenter;
      width = null;
      height = extent;
      break;
    case _ScreenEdge.left:
      begin = Alignment.centerLeft;
      end = Alignment.centerRight;
      width = extent;
      height = null;
      break;
    case _ScreenEdge.right:
      begin = Alignment.centerRight;
      end = Alignment.centerLeft;
      width = extent;
      height = null;
      break;
  }

  return SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: <Color>[
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    ),
  );
}

_ScreenEdge _resolveScreenEdge(EdgeHintSide side, AxisDirection axisDirection) {
  switch (axisDirection) {
    case AxisDirection.down:
      return side == EdgeHintSide.leading
          ? _ScreenEdge.top
          : _ScreenEdge.bottom;
    case AxisDirection.up:
      return side == EdgeHintSide.leading
          ? _ScreenEdge.bottom
          : _ScreenEdge.top;
    case AxisDirection.right:
      return side == EdgeHintSide.leading
          ? _ScreenEdge.left
          : _ScreenEdge.right;
    case AxisDirection.left:
      return side == EdgeHintSide.leading
          ? _ScreenEdge.right
          : _ScreenEdge.left;
  }
}
