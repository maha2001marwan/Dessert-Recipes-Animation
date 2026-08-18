import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_semantic_colors.dart';

/// A "− [count] +" stepper controlling how many servings the recipe is
/// scaled to. The count itself animates with a small vertical
/// slide-crossfade in the direction of the change (up when increasing,
/// down when decreasing) instead of a flat instant swap, and each
/// button gives a quick tactile press-scale + haptic tick — or, right
/// at the [minServings]/[maxServings] limit, a firm little shake
/// instead, so tapping a "disabled" button still gives *some* feedback
/// rather than doing nothing at all.
class ServingsStepper extends StatelessWidget {
  final int servings;
  final int baseServings;
  final Color accent;
  final ValueChanged<int> onChanged;

  static const int minServings = 1;
  static const int maxServings = 24;

  const ServingsStepper({
    super.key,
    required this.servings,
    required this.baseServings,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    final bool scaled = servings != baseServings;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          strings.adjustServings,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: semantics.bodyText),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.35)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepperButton(
                icon: Icons.remove_rounded,
                accent: accent,
                enabled: servings > minServings,
                onTap: () => onChanged(servings - 1),
              ),
              SizedBox(
                width: 42,
                child: _AnimatedServingsCount(
                  servings: servings,
                  scaled: scaled,
                  accent: accent,
                  titleColor: semantics.titleText,
                ),
              ),
              _StepperButton(
                icon: Icons.add_rounded,
                accent: accent,
                enabled: servings < maxServings,
                onTap: () => onChanged(servings + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedServingsCount extends StatefulWidget {
  final int servings;
  final bool scaled;
  final Color accent;
  final Color titleColor;

  const _AnimatedServingsCount({
    required this.servings,
    required this.scaled,
    required this.accent,
    required this.titleColor,
  });

  @override
  State<_AnimatedServingsCount> createState() => _AnimatedServingsCountState();
}

class _AnimatedServingsCountState extends State<_AnimatedServingsCount> {
  bool _increasing = true;

  @override
  void didUpdateWidget(covariant _AnimatedServingsCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.servings != widget.servings) {
      _increasing = widget.servings > oldWidget.servings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Offset begin = _increasing ? const Offset(0, 0.6) : const Offset(0, -0.6);
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) {
          return SlideTransition(
            position: Tween<Offset>(begin: begin, end: Offset.zero).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
        child: Text(
          '${widget.servings}',
          key: ValueKey<int>(widget.servings),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.scaled ? widget.accent : widget.titleColor,
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatefulWidget {
  final IconData icon;
  final Color accent;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.accent,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enabled) {
      HapticFeedback.selectionClick();
      widget.onTap();
    } else {
      // At the limit: a firm little "nope" shake instead of doing
      // nothing at all, so the tap still gets *some* acknowledgement.
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) {
          final double raw = _shake.value;
          final double decay = 1 - raw;
          final double dx = raw <= 0 ? 0 : math.sin(raw * math.pi * 6) * decay * 4;
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: AnimatedScale(
          scale: _pressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.enabled ? widget.accent.withOpacity(0.12) : Colors.transparent,
            ),
            child: Icon(
              widget.icon,
              size: 17,
              color: widget.enabled ? widget.accent : widget.accent.withOpacity(0.25),
            ),
          ),
        ),
      ),
    );
  }
}
