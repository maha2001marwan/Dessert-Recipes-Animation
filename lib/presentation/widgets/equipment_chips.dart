import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../data/models/recipe.dart';

/// A horizontally-wrapped row of small pill chips for the tools a recipe
/// needs — each one pops in with its own tiny delay so the row reads as
/// a quick, organic cascade rather than a static block of text.
class EquipmentChips extends StatelessWidget {
  final List<KitchenTool> tools;
  final Color accent;
  final Animation<double> reveal;

  const EquipmentChips({
    super.key,
    required this.tools,
    required this.accent,
    required this.reveal,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(tools.length, (i) {
        final KitchenTool tool = tools[i];
        final CurvedAnimation curved = CurvedAnimation(
          parent: reveal,
          curve: Interval(
            (i * 0.12).clamp(0.0, 0.6).toDouble(),
            (i * 0.12 + 0.4).clamp(0.0, 1.0).toDouble(),
            curve: Curves.easeOutBack,
          ),
        );
        return AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final double t = curved.value.clamp(0.0, 1.0).toDouble();
            return Opacity(
              opacity: t,
              child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(strings.toolIcon(tool), size: 15, color: accent),
                const SizedBox(width: 6),
                Text(
                  strings.toolLabel(tool),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: semantics.bodyText,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
