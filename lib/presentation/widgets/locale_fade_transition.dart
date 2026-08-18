import 'package:flutter/material.dart';
import '../../core/localization/locale_controller.dart';

/// Wraps the whole app in a brief fade+scale "dip" that plays every time
/// the language changes — softening what would otherwise be an abrupt,
/// jarring flip (text direction, every string, everything at once).
///
/// Deliberately *not* an [AnimatedSwitcher]-style widget swap: this only
/// wraps the existing child in [Opacity]/[Transform.scale], so the
/// underlying widget tree (and all its state — scroll position, open
/// panels, everything) is never torn down and rebuilt. Only the paint
/// output dips and recovers.
class LocaleFadeTransition extends StatefulWidget {
  final LocaleController controller;
  final Widget child;

  const LocaleFadeTransition({super.key, required this.controller, required this.child});

  @override
  State<LocaleFadeTransition> createState() => _LocaleFadeTransitionState();
}

class _LocaleFadeTransitionState extends State<LocaleFadeTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late Locale _lastLocale = widget.controller.value;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleLocaleChange);
  }

  void _handleLocaleChange() {
    if (widget.controller.value != _lastLocale) {
      _lastLocale = widget.controller.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleLocaleChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final double raw = _controller.value;
        // Triangular curve: dips down through the midpoint, then
        // recovers — 0 → 1 → 0 across the controller's own 0..1 range.
        final double dip = raw < 0.5 ? raw * 2 : (1 - raw) * 2;
        final double eased = Curves.easeInOut.transform(dip.clamp(0.0, 1.0).toDouble());
        final double opacity = (1 - eased * 0.55).clamp(0.0, 1.0).toDouble();
        final double scale = 1 - eased * 0.02;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}
