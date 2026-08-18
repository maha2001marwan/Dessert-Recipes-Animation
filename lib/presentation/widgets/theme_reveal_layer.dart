import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';

/// Wraps the whole app. Whenever [controller] records a new toggle, this
/// paints a shrinking "hole" — an inverse-circle mask filled with the
/// *previous* theme's background color — centered on the button the user
/// tapped. As the hole grows to cover the screen, the already-switched
/// new theme (rendered by [child] underneath) is progressively revealed,
/// producing a classic circular theme-switch animation without needing
/// any screenshot/texture capture.
class ThemeRevealLayer extends StatefulWidget {
  final ThemeController controller;
  final Widget child;

  const ThemeRevealLayer({super.key, required this.controller, required this.child});

  @override
  State<ThemeRevealLayer> createState() => _ThemeRevealLayerState();
}

class _ThemeRevealLayerState extends State<ThemeRevealLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  int _lastTick = 0;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _lastTick = widget.controller.revealTick;
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (widget.controller.revealTick == _lastTick) return;
    _lastTick = widget.controller.revealTick;
    if (widget.controller.revealOrigin == null) return;
    setState(() => _showOverlay = true);
    _animation
      ..reset()
      ..forward().whenComplete(() {
        if (mounted) setState(() => _showOverlay = false);
      });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showOverlay || widget.controller.revealOrigin == null) {
      return widget.child;
    }

    final Size screenSize = MediaQuery.sizeOf(context);
    final Offset origin = widget.controller.revealOrigin!;
    final double maxRadius = _maxRadiusFrom(origin, screenSize);
    final Color fromColor = widget.controller.revealFromColor ?? Colors.transparent;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final double radius =
                    Curves.easeInOutCubic.transform(_animation.value) * maxRadius;
                return ClipPath(
                  clipper: _InverseCircleClipper(center: origin, radius: radius),
                  child: ColoredBox(color: fromColor),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  double _maxRadiusFrom(Offset origin, Size screenSize) {
    final List<double> distances = [
      (origin - Offset.zero).distance,
      (origin - Offset(screenSize.width, 0)).distance,
      (origin - Offset(0, screenSize.height)).distance,
      (origin - Offset(screenSize.width, screenSize.height)).distance,
    ];
    return distances.reduce(math.max);
  }
}

class _InverseCircleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;
  _InverseCircleClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    final Path outer = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path hole = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    return Path.combine(PathOperation.difference, outer, hole);
  }

  @override
  bool shouldReclip(covariant _InverseCircleClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}
