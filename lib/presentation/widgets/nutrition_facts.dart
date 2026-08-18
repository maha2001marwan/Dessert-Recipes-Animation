import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../data/models/recipe.dart';

/// A row of four small animated progress rings summarizing per-serving
/// nutrition — calories, protein, carbs and fat.
///
/// The rings are proportioned relative to a generous reference max for
/// each nutrient (not to each other), so a low-fat recipe actually shows
/// a mostly-empty fat ring instead of every ring always looking "full".
/// Each ring fills in with a bouncy stagger the first time it becomes
/// visible, driven by [reveal].
class NutritionFacts extends StatelessWidget {
  final NutritionEstimate nutrition;
  final Color accent;
  final Animation<double> reveal;

  const NutritionFacts({
    super.key,
    required this.nutrition,
    required this.accent,
    required this.reveal,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _NutritionRing(
            value: nutrition.caloriesPerServing.toDouble(),
            max: 650,
            label: strings.calories,
            display: '${nutrition.caloriesPerServing}',
            unit: 'kcal',
            color: accent,
            reveal: reveal,
            delayFraction: 0.0,
          ),
        ),
        Expanded(
          child: _NutritionRing(
            value: nutrition.proteinGrams.toDouble(),
            max: 20,
            label: strings.protein,
            display: '${nutrition.proteinGrams}',
            unit: 'g',
            color: const Color(0xFF4C9F70),
            reveal: reveal,
            delayFraction: 0.08,
          ),
        ),
        Expanded(
          child: _NutritionRing(
            value: nutrition.carbsGrams.toDouble(),
            max: 90,
            label: strings.carbs,
            display: '${nutrition.carbsGrams}',
            unit: 'g',
            color: const Color(0xFFE0A93E),
            reveal: reveal,
            delayFraction: 0.16,
          ),
        ),
        Expanded(
          child: _NutritionRing(
            value: nutrition.fatGrams.toDouble(),
            max: 30,
            label: strings.fat,
            display: '${nutrition.fatGrams}',
            unit: 'g',
            color: const Color(0xFFD9705B),
            reveal: reveal,
            delayFraction: 0.24,
          ),
        ),
      ],
    );
  }
}

class _NutritionRing extends StatelessWidget {
  final double value;
  final double max;
  final String label;
  final String display;
  final String unit;
  final Color color;
  final Animation<double> reveal;
  final double delayFraction;

  const _NutritionRing({
    required this.value,
    required this.max,
    required this.label,
    required this.display,
    required this.unit,
    required this.color,
    required this.reveal,
    required this.delayFraction,
  });

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    final CurvedAnimation curved = CurvedAnimation(
      parent: reveal,
      curve: Interval(
        delayFraction.clamp(0.0, 0.7).toDouble(),
        (delayFraction + 0.5).clamp(0.0, 1.0).toDouble(),
        curve: Curves.easeOutCubic,
      ),
    );
    final double fraction = (value / max).clamp(0.0, 1.0).toDouble();

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final double t = curved.value;
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.7 + 0.3 * t,
            child: Column(
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: fraction * t,
                      color: color,
                      trackColor: color.withOpacity(0.15),
                    ),
                    child: Center(
                      child: Text(
                        display,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: semantics.titleText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  unit,
                  style: TextStyle(fontSize: 10, color: semantics.bodyText.withOpacity(0.7)),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: semantics.bodyText,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter({required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 - 4;

    final Paint track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final Paint arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
