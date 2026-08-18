import 'package:flutter/material.dart';
import '../../core/theme/app_semantic_colors.dart';

/// A lightweight shimmer placeholder: a soft light band sweeps
/// left-to-right across a themed grey box on a loop, shown while a
/// recipe photo is still loading — nicer than a bare spinner, and
/// correctly tinted for both light and dark mode.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: [
                semantics.shimmerBase,
                semantics.shimmerHighlight,
                semantics.shimmerBase,
              ],
              stops: const [0.4, 0.5, 0.6],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Container(color: semantics.shimmerBase),
    );
  }
}
