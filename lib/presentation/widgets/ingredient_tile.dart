import 'package:flutter/material.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../data/models/recipe.dart';

/// An ingredient row with a tappable, animated checkbox.
///
/// Checking it off no longer just snaps a `TextDecoration.lineThrough`
/// on — instead a thin line **draws itself** across the text, growing
/// from the reading-start edge (right-to-left in Arabic, left-to-right
/// in English, via [AlignmentDirectional] so it's correct either way)
/// like someone physically crossing the item off a paper list. Un-checking
/// draws it back off the same way.
class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final Color accentColor;
  final String languageCode;
  final bool checked;
  final VoidCallback onToggle;

  const IngredientTile({
    super.key,
    required this.ingredient,
    required this.accentColor,
    required this.languageCode,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(checked ? 0.12 : 0.3), width: 1),
          color: checked ? accentColor.withOpacity(0.06) : Colors.transparent,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? accentColor : Colors.transparent,
                border: Border.all(color: accentColor, width: 2),
              ),
              child: checked
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(
                      fontSize: 15,
                      color: checked ? semantics.bodyText : semantics.ingredientText,
                    ),
                    child: Text(ingredient.text.resolve(languageCode)),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: checked ? 1.0 : 0.0),
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, child) {
                          return FractionallySizedBox(
                            widthFactor: t.clamp(0.0, 1.0).toDouble(),
                            alignment: AlignmentDirectional.centerStart,
                            child: Container(
                              height: 1.4,
                              color: semantics.bodyText.withOpacity(0.75),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
