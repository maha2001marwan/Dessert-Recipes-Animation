import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../data/models/recipe.dart';

/// `null` means "All".
typedef CategoryFilter = RecipeCategory?;

class _FilterOption {
  final CategoryFilter category;
  final String label;
  final IconData icon;
  const _FilterOption(this.category, this.label, this.icon);
}

/// A horizontally scrollable row of filter chips. Selecting one filters
/// the list below. Each chip carries a small category icon alongside its
/// label, and on top of [ChoiceChip]'s own color crossfade, gives a
/// quick tactile pop (scale bounce + haptic) the moment it *becomes*
/// selected — a small physical confirmation that the tap registered,
/// distinct from the list's own slide transition.
class CategoryFilterBar extends StatelessWidget {
  final CategoryFilter selected;
  final ValueChanged<CategoryFilter> onChanged;
  final Color accent;

  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    final List<_FilterOption> options = [
      _FilterOption(null, strings.categoryAll, Icons.apps_rounded),
      _FilterOption(RecipeCategory.cake, strings.categoryCake, Icons.cake_rounded),
      _FilterOption(RecipeCategory.pie, strings.categoryPie, Icons.bakery_dining_rounded),
      _FilterOption(RecipeCategory.cold, strings.categoryCold, Icons.icecream_rounded),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          return _FilterChip(
            label: option.label,
            icon: option.icon,
            selected: option.category == selected,
            accent: accent,
            onTap: () => onChanged(option.category),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  @override
  void didUpdateWidget(covariant _FilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.selected) HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    final Color labelColor = widget.selected ? Colors.white : semantics.bodyText;
    return AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        // A quick overshoot-and-settle: 1 → 1.1 → 1.0, driven by a sine
        // bump rather than a plain Tween so it reads as a single pop
        // instead of a slow grow.
        final double bump = _pop.value < 1 ? (1 - (2 * _pop.value - 1).abs()) : 0;
        final double scale = 1 + bump * 0.1;
        return Transform.scale(scale: scale, child: child);
      },
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 15, color: labelColor),
            const SizedBox(width: 5),
            Text(widget.label),
          ],
        ),
        selected: widget.selected,
        onSelected: (_) => _handleTap(),
        showCheckmark: false,
        selectedColor: widget.accent,
        backgroundColor: semantics.plainCardSurface,
        labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.w600),
        side: BorderSide(color: widget.accent.withOpacity(widget.selected ? 0 : 0.3)),
      ),
    );
  }
}
