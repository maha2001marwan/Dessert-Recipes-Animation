import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_semantic_colors.dart';

/// A small dismissible banner explaining a discoverable-but-not-obvious
/// gesture (long-press, double-tap, etc.) — slides + fades in, and
/// collapses smoothly (not just an instant disappearance) when
/// dismissed, whether by the close button or by [autoDismissAfter]
/// elapsing on its own.
class GestureHintBanner extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDismiss;
  final Duration? autoDismissAfter;

  const GestureHintBanner({
    super.key,
    required this.message,
    required this.icon,
    required this.onDismiss,
    this.autoDismissAfter,
  });

  @override
  State<GestureHintBanner> createState() => _GestureHintBannerState();
}

class _GestureHintBannerState extends State<GestureHintBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    final Duration? auto = widget.autoDismissAfter;
    if (auto != null) {
      Future.delayed(auto, () {
        if (mounted) _dismiss();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    HapticFeedback.selectionClick();
    _controller.reverse().whenCompleteOrCancel(widget.onDismiss);
  }

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    final CurvedAnimation curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return SizeTransition(
      sizeFactor: curved,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: curved,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: semantics.plainCardSurface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 17, color: semantics.bodyText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(fontSize: 12.5, color: semantics.bodyText, height: 1.3),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _dismiss,
                  behavior: HitTestBehavior.opaque,
                  child: Icon(Icons.close_rounded, size: 16, color: semantics.bodyText.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
