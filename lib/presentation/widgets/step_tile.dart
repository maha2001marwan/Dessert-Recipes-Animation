import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../data/models/recipe.dart';

/// A preparation step row.
///
/// - In cooking mode the number badge is tappable and morphs into a
///   filled checkmark once completed ([AnimatedSwitcher] for the icon
///   swap, an implicit color animation for the badge fill).
/// - A thin vertical rail runs from this badge down through the row —
///   filled in accent color once the step is completed, otherwise a
///   faint track — so the whole list reads as a connected timeline
///   instead of separate, disconnected rows. (No cross-widget height
///   measurement needed: each tile only draws the segment for *its own*
///   row, sized to whatever that row's own height turns out to be.)
/// - While [isCurrent] (the first not-yet-completed step, only
///   meaningful in cooking mode), the badge gently pulses — a slow glow
///   breathing in and out — so it's obvious at a glance which step
///   you're on without reading every line.
class StepTile extends StatefulWidget {
  final RecipeStep step;
  final Color accentColor;
  final String languageCode;
  final bool completed;
  final bool interactive;
  final bool isLast;
  final bool isCurrent;
  final VoidCallback onToggle;

  const StepTile({
    super.key,
    required this.step,
    required this.accentColor,
    required this.languageCode,
    required this.completed,
    required this.interactive,
    required this.onToggle,
    this.isLast = false,
    this.isCurrent = false,
  });

  @override
  State<StepTile> createState() => _StepTileState();
}

class _StepTileState extends State<StepTile> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant StepTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCurrent != widget.isCurrent) {
      _syncPulse();
      if (widget.isCurrent) {
        // A light tick as the "you are here" focus lands on this step —
        // distinct from the firmer selectionClick a direct tap gives,
        // since this one wasn't a tap at all (it's the *previous* step
        // completing that moved focus here).
        HapticFeedback.lightImpact();
      }
    }
  }

  void _syncPulse() {
    if (widget.isCurrent) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;

    final Widget badge = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.completed ? widget.accentColor : widget.accentColor.withOpacity(0.22),
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: widget.completed
            ? const Icon(Icons.check, key: ValueKey('done'), color: Colors.white, size: 18)
            : Text(
                '${widget.step.number}',
                key: const ValueKey('num'),
                style: TextStyle(fontWeight: FontWeight.bold, color: semantics.sectionHeader),
              ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: GestureDetector(
        onTap: widget.interactive ? widget.onToggle : null,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            if (!widget.isLast)
              PositionedDirectional(
                start: 16.3,
                top: 34,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  width: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: widget.completed
                        ? widget.accentColor
                        : widget.accentColor.withOpacity(0.15),
                  ),
                ),
              ),
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                final double glow = widget.isCurrent
                    ? (0.10 + 0.14 * Curves.easeInOut.transform(_pulse.value))
                    : 0.0;
                final double badgeScale =
                    widget.isCurrent ? 1.0 + 0.05 * Curves.easeInOut.transform(_pulse.value) : 1.0;
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: widget.isCurrent ? widget.accentColor.withOpacity(glow) : null,
                  ),
                  padding: widget.isCurrent
                      ? const EdgeInsets.symmetric(vertical: 6, horizontal: 6)
                      : EdgeInsets.zero,
                  margin: widget.isCurrent
                      ? const EdgeInsets.symmetric(horizontal: 0)
                      : EdgeInsets.zero,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.scale(scale: badgeScale, child: badge),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color:
                                  widget.completed ? semantics.bodyText : semantics.stepText,
                              decoration:
                                  widget.completed ? TextDecoration.lineThrough : TextDecoration.none,
                              decorationColor: semantics.bodyText,
                            ),
                            child: Text(widget.step.text.resolve(widget.languageCode)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
