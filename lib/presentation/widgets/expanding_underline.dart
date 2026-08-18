import 'package:flutter/material.dart';

/// A short gradient underline that grows from 0 to [width] during the
/// [start]-[end] slice of [controller]'s timeline — a small flourish
/// beneath section headers like "INGREDIENTS" / "STEPS". Uses a plain
/// [Container] width (not Positioned), so it grows symmetrically from
/// its start edge in both LTR and RTL automatically.
class ExpandingUnderline extends StatelessWidget {
  final Animation<double> controller;
  final double start;
  final double end;
  final Color color;
  final double width;

  const ExpandingUnderline({
    super.key,
    required this.controller,
    required this.start,
    required this.end,
    required this.color,
    this.width = 40,
  });

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
      builder: (context, child) {
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            margin: const EdgeInsets.only(top: 6),
            height: 3,
            width: width * curved.value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(colors: [color, color.withOpacity(0.15)]),
            ),
          ),
        );
      },
    );
  }
}
