import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../data/models/localized_text.dart';

/// A tappable card that expands to reveal a chef's tip, with the chevron
/// rotating 180° and the body height/opacity animating open — a classic
/// accordion, but tuned (curve + duration) to match the rest of the
/// screen's motion instead of Flutter's flat default.
class ExpandableTipCard extends StatefulWidget {
  final LocalizedText tip;
  final String languageCode;
  final Color accent;

  const ExpandableTipCard({
    super.key,
    required this.tip,
    required this.languageCode,
    required this.accent,
  });

  @override
  State<ExpandableTipCard> createState() => _ExpandableTipCardState();
}

class _ExpandableTipCardState extends State<ExpandableTipCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _open = !_open);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.accent.withOpacity(_open ? 0.10 : 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: widget.accent.withOpacity(0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accent.withOpacity(0.18),
                  ),
                  child: Icon(Icons.lightbulb_rounded, size: 16, color: widget.accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.chefTip,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: semantics.titleText,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: Icon(Icons.expand_more_rounded, color: widget.accent),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                opacity: _open ? 1 : 0,
                duration: Duration(milliseconds: _open ? 320 : 120),
                curve: Curves.easeOut,
                child: _open
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          widget.tip.resolve(widget.languageCode),
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: semantics.bodyText,
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
