import 'package:flutter/widgets.dart';

import 'types.dart';

const double kEdgeHintRangeEpsilon = 0.0001;

EdgeHintStrength calculateEdgeHintStrength(
  ScrollMetrics metrics, {
  required double fadeInDistance,
}) {
  final double minExtent = metrics.minScrollExtent;
  final double maxExtent = metrics.maxScrollExtent;

  if (maxExtent <= minExtent + kEdgeHintRangeEpsilon) {
    return EdgeHintStrength.zero;
  }

  final double safeDistance = fadeInDistance <= 0
      ? kEdgeHintRangeEpsilon
      : fadeInDistance;
  final double pixels = metrics.pixels;

  final double leadingStrength = ((pixels - minExtent) / safeDistance).clamp(
    0.0,
    1.0,
  );
  final double trailingStrength = ((maxExtent - pixels) / safeDistance).clamp(
    0.0,
    1.0,
  );

  return EdgeHintStrength(leading: leadingStrength, trailing: trailingStrength);
}
