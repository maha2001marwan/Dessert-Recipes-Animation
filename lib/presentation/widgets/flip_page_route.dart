import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Opens a new page with a shallow 3D "page turn": the incoming screen
/// rotates in around its leading (reading-start) edge — a book page
/// settling flat — instead of a plain fade or slide.
///
/// Deliberately used only where the destination screen has **no Hero**
/// flying into it (Favorites, Related Recipes): a Hero flight and an
/// independent 3D rotation of the whole page running at the same time
/// would fight each other visually, since the Hero flies in a straight
/// line while the page itself is tumbling. The main recipe-card → detail
/// transition keeps its existing Hero-friendly fade instead.
PageRouteBuilder<T> flipPageRoute<T>({
  required WidgetBuilder builder,
  Duration duration = const Duration(milliseconds: 460),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 340),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final Alignment hinge = AlignmentDirectional.centerStart.resolve(Directionality.of(context));
      final CurvedAnimation curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) {
          final double t = curved.value.clamp(0.0, 1.0).toDouble();
          // Settles from edge-on (~80°, all but invisible) down to flat.
          final double angle = (1 - t) * (math.pi / 2.25);
          return Opacity(
            opacity: t,
            child: Transform(
              alignment: hinge,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0013)
                ..rotateY(angle),
              child: child,
            ),
          );
        },
      );
    },
  );
}
