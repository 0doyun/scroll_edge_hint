import 'package:flutter/widgets.dart';

enum EdgeHintEdges { leading, trailing, both }

enum EdgeHintEffect { overlayFade }

enum EdgeHintSide { leading, trailing }

@immutable
class EdgeHintStrength {
  const EdgeHintStrength({required this.leading, required this.trailing});

  final double leading;
  final double trailing;

  static const zero = EdgeHintStrength(leading: 0, trailing: 0);

  bool isCloseTo(EdgeHintStrength other, {double epsilon = 0.01}) {
    return (leading - other.leading).abs() <= epsilon &&
        (trailing - other.trailing).abs() <= epsilon;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is EdgeHintStrength &&
        other.leading == leading &&
        other.trailing == trailing;
  }

  @override
  int get hashCode => Object.hash(leading, trailing);

  @override
  String toString() {
    return 'EdgeHintStrength(leading: $leading, trailing: $trailing)';
  }
}

typedef EdgeHintBuilder =
    Widget Function(
      BuildContext context,
      EdgeHintSide side,
      Axis axis,
      AxisDirection axisDirection,
      double opacity,
      double extent,
      Color color,
    );
