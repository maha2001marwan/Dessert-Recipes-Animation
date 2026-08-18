import 'package:flutter/material.dart';

/// Fades and slides [child] upward during the [start]-[end] slice of
/// [controller]'s 0..1 timeline. The slide direction is a plain vertical
/// offset (up), which reads correctly in both LTR and RTL since it never
/// moves horizontally.
class StaggeredFadeSlide extends StatelessWidget {
  final Animation<double> controller;
  final double start;
  final double end;
  final double slideOffset;
  final Widget child;

  const StaggeredFadeSlide({
    super.key,
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.slideOffset = 22,
  }) : assert(end > start);

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation curved = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start.clamp(0.0, 1.0).toDouble(),
        end.clamp(0.0, 1.0).toDouble(),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) {
        final double v = curved.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * slideOffset),
            child: child,
          ),
        );
      },
    );
  }
}
