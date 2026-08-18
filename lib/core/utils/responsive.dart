import 'package:flutter/material.dart';

/// Small, dependency-free responsive helpers. The design is authored for
/// phone widths; on wider viewports (tablet/desktop/web) we cap the
/// content width and center it instead of letting cards stretch edge to
/// edge into an unreadable, oversized layout.
class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 700;
  static const double maxContentWidth = 520;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Centers [child] and caps its width on wide screens; passes it
  /// through unchanged on phones.
  static Widget centeredMaxWidth(BuildContext context, Widget child) {
    if (!isTablet(context)) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}
