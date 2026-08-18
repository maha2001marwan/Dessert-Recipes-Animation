import 'package:flutter/material.dart';

/// A single diagonal light streak that sweeps across [child] once, shortly
/// after it appears — the "glint" effect from a lot of modern card UIs.
///
/// Deliberately **not** repeating and **not** synchronized across cards:
/// a whole screen of cards glinting in perfect unison at once is
/// expensive to render and visually noisy, so every [ShineSweep] takes an
/// explicit [delay] the caller staggers per item (see [RecipeCard]).
///
/// Cheap when idle: outside the ~1.1s the sweep is actually running, this
/// returns [child] directly with no [ShaderMask] in the tree at all.
class ShineSweep extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const ShineSweep({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<ShineSweep> createState() => _ShineSweepState();
}

class _ShineSweepState extends State<ShineSweep> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        if (_controller.value <= 0.0 || _controller.value >= 1.0) {
          return child!;
        }
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double dx = _controller.value * bounds.width * 2.2 - bounds.width * 0.6;
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.transparent,
                Colors.white24,
                Colors.white54,
                Colors.white24,
                Colors.transparent,
              ],
              stops: const [0.35, 0.45, 0.5, 0.55, 0.65],
              transform: const GradientRotation(0.3),
            ).createShader(bounds.shift(Offset(dx, 0)));
          },
          child: child,
        );
      },
    );
  }
}
