import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Flight-shuttle builder used by the plate/photo Hero.
///
/// Flutter's default Hero already interpolates size and position for us.
/// This builder layers one extra full rotation on top of that, plus a
/// spring/overshoot "landing bounce" concentrated in the last 30% of the
/// flight, giving the plate a lively, physics-like pop as it arrives.
Widget plateFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero destinationHero = toHeroContext.widget as Hero;
  const Interval landCurve = Interval(0.7, 1.0, curve: Curves.elasticOut);

  return AnimatedBuilder(
    animation: animation,
    child: destinationHero.child,
    builder: (context, child) {
      final double rawT = animation.value;
      final double spinT = Curves.easeOutCubic.transform(rawT);
      final double spin = spinT * 2 * math.pi;
      final double angle = flightDirection == HeroFlightDirection.push ? spin : -spin;
      final double land = landCurve.transform(rawT);
      final double extraScale = 0.9 + 0.1 * land;
      return Transform.scale(
        scale: extraScale,
        child: Transform.rotate(angle: angle, child: child),
      );
    },
  );
}

/// Flight-shuttle builder used by the colored background Hero (the card
/// rectangle that expands into the detail header). Hero only tweens
/// size/position; this clips the flying rectangle with an animated
/// [BorderRadius] so the *shape* morphs too — fully-rounded card corners
/// becoming a bottom-only-rounded header.
Widget backgroundFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero destinationHero = toHeroContext.widget as Hero;
  final CurvedAnimation curved = CurvedAnimation(
    parent: animation,
    // Settles a hair *before* the plate (which keeps animating to 1.0
    // with an elastic landing bounce) — the two layers arriving a beat
    // apart reads as depth/parallax instead of one flat, single-timed
    // flight (reference video analysis, idea bank #9).
    curve: const Interval(0.0, 0.88, curve: Curves.easeInOutCubic),
  );

  const BorderRadius cardRadius = BorderRadius.all(Radius.circular(26));
  const BorderRadius headerRadius = BorderRadius.only(
    bottomLeft: Radius.circular(34),
    bottomRight: Radius.circular(34),
  );

  final bool isPush = flightDirection == HeroFlightDirection.push;
  final BorderRadius begin = isPush ? cardRadius : headerRadius;
  final BorderRadius end = isPush ? headerRadius : cardRadius;

  return AnimatedBuilder(
    animation: curved,
    child: destinationHero.child,
    builder: (context, child) {
      final BorderRadius radius = BorderRadius.lerp(begin, end, curved.value)!;
      return ClipRRect(borderRadius: radius, child: child);
    },
  );
}
