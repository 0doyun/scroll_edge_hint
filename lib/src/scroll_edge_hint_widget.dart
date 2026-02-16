import 'package:flutter/material.dart';

import 'default_hint_builder.dart';
import 'strength_calculator.dart';
import 'types.dart';

class ScrollEdgeHint extends StatefulWidget {
  const ScrollEdgeHint({
    super.key,
    required this.child,
    this.controller,
    this.usePrimaryController = true,
    this.edges = EdgeHintEdges.both,
    this.effect = EdgeHintEffect.overlayFade,
    this.extent = 16.0,
    this.maxOpacity = 0.8,
    this.fadeInDistance,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 120),
    this.animationCurve = Curves.easeOut,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.hintBuilder,
    this.onStrengthChanged,
  }) : assert(extent >= 0),
       assert(maxOpacity >= 0 && maxOpacity <= 1),
       assert(fadeInDistance == null || fadeInDistance > 0),
       builder = null;

  const ScrollEdgeHint.builder({
    super.key,
    required this.builder,
    this.edges = EdgeHintEdges.both,
    this.effect = EdgeHintEffect.overlayFade,
    this.extent = 16.0,
    this.maxOpacity = 0.8,
    this.fadeInDistance,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 120),
    this.animationCurve = Curves.easeOut,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.hintBuilder,
    this.onStrengthChanged,
  }) : assert(extent >= 0),
       assert(maxOpacity >= 0 && maxOpacity <= 1),
       assert(fadeInDistance == null || fadeInDistance > 0),
       child = null,
       controller = null,
       usePrimaryController = false;

  final Widget? child;
  final ScrollController? controller;
  final bool usePrimaryController;
  final EdgeHintEdges edges;
  final EdgeHintEffect effect;
  final double extent;
  final double maxOpacity;
  final double? fadeInDistance;
  final Color? backgroundColor;
  final Duration animationDuration;
  final Curve animationCurve;
  final ScrollNotificationPredicate notificationPredicate;
  final EdgeHintBuilder? hintBuilder;
  final ValueChanged<EdgeHintStrength>? onStrengthChanged;
  final Widget Function(BuildContext context, ScrollController controller)?
  builder;

  bool get _usesBuilder => builder != null;

  @override
  State<ScrollEdgeHint> createState() => _ScrollEdgeHintState();
}

class _ScrollEdgeHintState extends State<ScrollEdgeHint> {
  static const double _strengthEpsilon = 0.01;

  EdgeHintStrength _strength = EdgeHintStrength.zero;
  Axis _axis = Axis.vertical;
  AxisDirection _axisDirection = AxisDirection.down;

  ScrollController? _ownedController;
  ScrollController? _primaryController;
  ScrollController? _listenedController;

  @override
  void initState() {
    super.initState();
    if (widget._usesBuilder) {
      _ownedController = ScrollController();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncControllerListener();
      _updateFromControllerIfAvailable();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _primaryController = widget.usePrimaryController
        ? PrimaryScrollController.maybeOf(context)
        : null;
    _syncControllerListener();
  }

  @override
  void didUpdateWidget(covariant ScrollEdgeHint oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget._usesBuilder != oldWidget._usesBuilder) {
      _ownedController?.dispose();
      _ownedController = widget._usesBuilder ? ScrollController() : null;
    }

    if (!widget.usePrimaryController) {
      _primaryController = null;
    }

    _syncControllerListener();
    _updateFromControllerIfAvailable();
  }

  @override
  void dispose() {
    _listenedController?.removeListener(_handleControllerTick);
    _ownedController?.dispose();
    super.dispose();
  }

  ScrollController? get _effectiveController {
    if (widget._usesBuilder) {
      return _ownedController;
    }
    return widget.controller ??
        (widget.usePrimaryController ? _primaryController : null);
  }

  void _syncControllerListener() {
    final ScrollController? next = _effectiveController;
    if (_listenedController == next) {
      return;
    }

    _listenedController?.removeListener(_handleControllerTick);
    _listenedController = next;
    _listenedController?.addListener(_handleControllerTick);
  }

  void _handleControllerTick() {
    _updateFromControllerIfAvailable();
  }

  void _updateFromControllerIfAvailable() {
    final ScrollController? controller = _effectiveController;
    if (controller == null || !controller.hasClients) {
      return;
    }
    _applyMetrics(controller.position);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) {
      return false;
    }
    _applyMetrics(notification.metrics);
    return false;
  }

  void _applyMetrics(ScrollMetrics metrics) {
    final EdgeHintStrength nextStrength = calculateEdgeHintStrength(
      metrics,
      fadeInDistance: widget.fadeInDistance ?? widget.extent,
    );

    if (nextStrength.isCloseTo(_strength, epsilon: _strengthEpsilon) &&
        _axis == metrics.axis &&
        _axisDirection == metrics.axisDirection) {
      return;
    }

    setState(() {
      _strength = nextStrength;
      _axis = metrics.axis;
      _axisDirection = metrics.axisDirection;
    });

    widget.onStrengthChanged?.call(nextStrength);
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController? effectiveController = _effectiveController;
    final Widget child = widget._usesBuilder
        ? widget.builder!(context, effectiveController!)
        : widget.child!;

    final ThemeData theme = Theme.of(context);
    final Color fallbackColor = theme.scaffoldBackgroundColor.a == 0
        ? theme.colorScheme.surface
        : theme.scaffoldBackgroundColor;
    final Color color = widget.backgroundColor ?? fallbackColor;

    final double leadingOpacity = _opacityFor(EdgeHintSide.leading);
    final double trailingOpacity = _opacityFor(EdgeHintSide.trailing);

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: Stack(
        children: <Widget>[
          child,
          _buildHint(
            side: EdgeHintSide.leading,
            opacity: leadingOpacity,
            color: color,
          ),
          _buildHint(
            side: EdgeHintSide.trailing,
            opacity: trailingOpacity,
            color: color,
          ),
        ],
      ),
    );
  }

  double _opacityFor(EdgeHintSide side) {
    final bool enabled = switch (widget.edges) {
      EdgeHintEdges.both => true,
      EdgeHintEdges.leading => side == EdgeHintSide.leading,
      EdgeHintEdges.trailing => side == EdgeHintSide.trailing,
    };

    if (!enabled) {
      return 0;
    }

    final double strength = side == EdgeHintSide.leading
        ? _strength.leading
        : _strength.trailing;
    return (widget.maxOpacity * strength).clamp(0, widget.maxOpacity);
  }

  Widget _buildHint({
    required EdgeHintSide side,
    required double opacity,
    required Color color,
  }) {
    final Widget content = TweenAnimationBuilder<double>(
      key: Key(
        side == EdgeHintSide.leading
            ? 'scroll_edge_hint_leading_animation'
            : 'scroll_edge_hint_trailing_animation',
      ),
      tween: Tween<double>(end: opacity),
      duration: widget.animationDuration,
      curve: widget.animationCurve,
      builder: (BuildContext context, double animatedOpacity, Widget? _) {
        final bool isCustomBuilder = widget.hintBuilder != null;
        final Widget hint = (widget.hintBuilder ?? buildDefaultEdgeHint)(
          context,
          side,
          _axis,
          _axisDirection,
          isCustomBuilder ? animatedOpacity : 1,
          widget.extent,
          color,
        );

        return Opacity(
          key: Key(
            side == EdgeHintSide.leading
                ? 'scroll_edge_hint_leading_opacity'
                : 'scroll_edge_hint_trailing_opacity',
          ),
          opacity: isCustomBuilder ? 1 : animatedOpacity,
          child: hint,
        );
      },
    );

    return Positioned(
      top: _topFor(side),
      bottom: _bottomFor(side),
      left: _leftFor(side),
      right: _rightFor(side),
      child: IgnorePointer(
        key: Key(
          side == EdgeHintSide.leading
              ? 'scroll_edge_hint_leading_hint'
              : 'scroll_edge_hint_trailing_hint',
        ),
        ignoring: true,
        child: ExcludeSemantics(child: content),
      ),
    );
  }

  double? _topFor(EdgeHintSide side) {
    if (_axis == Axis.horizontal) {
      return 0;
    }

    final bool anchoredToTop = switch (_axisDirection) {
      AxisDirection.down => side == EdgeHintSide.leading,
      AxisDirection.up => side == EdgeHintSide.trailing,
      AxisDirection.right || AxisDirection.left => true,
    };

    return anchoredToTop ? 0 : null;
  }

  double? _bottomFor(EdgeHintSide side) {
    if (_axis == Axis.horizontal) {
      return 0;
    }

    final bool anchoredToBottom = switch (_axisDirection) {
      AxisDirection.down => side == EdgeHintSide.trailing,
      AxisDirection.up => side == EdgeHintSide.leading,
      AxisDirection.right || AxisDirection.left => true,
    };

    return anchoredToBottom ? 0 : null;
  }

  double? _leftFor(EdgeHintSide side) {
    if (_axis == Axis.vertical) {
      return 0;
    }

    final bool anchoredToLeft = switch (_axisDirection) {
      AxisDirection.right => side == EdgeHintSide.leading,
      AxisDirection.left => side == EdgeHintSide.trailing,
      AxisDirection.down || AxisDirection.up => true,
    };

    return anchoredToLeft ? 0 : null;
  }

  double? _rightFor(EdgeHintSide side) {
    if (_axis == Axis.vertical) {
      return 0;
    }

    final bool anchoredToRight = switch (_axisDirection) {
      AxisDirection.right => side == EdgeHintSide.trailing,
      AxisDirection.left => side == EdgeHintSide.leading,
      AxisDirection.down || AxisDirection.up => true,
    };

    return anchoredToRight ? 0 : null;
  }
}
