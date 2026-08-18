import 'package:flutter/material.dart';

/// Whether [color] reads as visually "light" — used to decide if an
/// overlay button sitting on top of it needs a dark or a light icon.
bool isLightColor(Color color) => color.computeLuminance() > 0.5;

/// Badge + icon colors for a circular overlay button (back / favorite)
/// that must stay legible over any recipe accent color, in either theme.
class OverlayButtonColors {
  final Color badge;
  final Color icon;
  const OverlayButtonColors({required this.badge, required this.icon});

  factory OverlayButtonColors.forBackground(Color background) {
    final bool light = isLightColor(background);
    return OverlayButtonColors(
      badge: light ? Colors.black.withOpacity(0.16) : Colors.black.withOpacity(0.35),
      icon: light ? Colors.black87 : Colors.white,
    );
  }
}
