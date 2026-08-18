import 'package:flutter/material.dart';

/// A number that transitions with a vertical slide-crossfade whenever it
/// changes, instead of snapping — used for small live counters (e.g.
/// "3 ingredients left") where a flat instant swap would feel abrupt.
class AnimatedCountLabel extends StatefulWidget {
  final int count;
  final String Function(int count) labelBuilder;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const AnimatedCountLabel({
    super.key,
    required this.count,
    required this.labelBuilder,
    required this.color,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
  });

  @override
  State<AnimatedCountLabel> createState() => _AnimatedCountLabelState();
}

class _AnimatedCountLabelState extends State<AnimatedCountLabel> {
  bool _increasing = false;

  @override
  void didUpdateWidget(covariant AnimatedCountLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _increasing = widget.count > oldWidget.count;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Offset begin = _increasing ? const Offset(0, -0.6) : const Offset(0, 0.6);
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Text(
          widget.labelBuilder(widget.count),
          key: ValueKey<int>(widget.count),
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
