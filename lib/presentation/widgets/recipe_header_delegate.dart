import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/recipe.dart';
import 'floating_plate.dart';
import 'hero_flight.dart';

/// The collapsing header used in the detail screen.
///
/// - The colored background (for recipes whose list card was colored)
///   carries the matching Hero tag so it visually continues the card's
///   background-expansion animation.
/// - The circular photo is the same [FloatingImagePlate] used in the
///   list — white ring, glassy highlight, independent float + breathing
///   shadow — plus a slow continuous "Ken Burns" zoom, so the header
///   feels alive even before the user scrolls at all. It also shrinks,
///   drifts upward and softly fades as the user scrolls down.
/// - Small decorative stickers drift around the photo, each on its own
///   float cycle so the header never feels perfectly mechanical.
/// All of this is driven directly by [shrinkOffset], so it tracks the
/// scroll gesture 1:1 in both directions.
class RecipeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Recipe recipe;

  /// Amount of *overscroll* past the top of the list, in logical pixels
  /// (0 when not overscrolling). Purely a visual flourish — the header's
  /// own extent never changes, only the photo zooms in a hair further,
  /// so pulling down on the detail screen feels elastic instead of dead.
  final ValueListenable<double> overscroll;

  /// 0..1 cooking-mode completion. The colored background gradually
  /// lightens toward white as this rises — a subtle "getting there"
  /// signal that doesn't require reading the progress banner text.
  /// Stays at 0 outside cooking mode.
  final ValueListenable<double> progress;

  /// Increments by one every time a step is freshly checked off in
  /// cooking mode. The header doesn't care about the number itself —
  /// only that it *changed* — and plays one ripple from the photo's
  /// center each time it does.
  final ValueListenable<int> rippleSignal;

  /// Called when the photo is double-tapped. `null` disables the
  /// gesture entirely (rather than wiring it to a no-op), so there's no
  /// dead double-tap handler sitting over the image for no reason.
  final VoidCallback? onDoubleTapFavorite;

  static const double maxHeaderExtent = 380;
  static const double minHeaderExtent = 140;
  static const double maxImageSize = 260;
  static const double minImageSize = 90;
  static const double maxImageTop = 70;
  static const double minImageTop = 26;
  static const BorderRadius headerRadius = BorderRadius.only(
    bottomLeft: Radius.circular(34),
    bottomRight: Radius.circular(34),
  );

  const RecipeHeaderDelegate({
    required this.recipe,
    required this.overscroll,
    required this.progress,
    required this.rippleSignal,
    this.onDoubleTapFavorite,
  });

  @override
  double get maxExtent => maxHeaderExtent;

  @override
  double get minExtent => minHeaderExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double t =
        (shrinkOffset / (maxHeaderExtent - minHeaderExtent)).clamp(0.0, 1.0).toDouble();
    final double currentHeight = lerpDouble(maxHeaderExtent, minHeaderExtent, t)!;
    final double imageSize = lerpDouble(maxImageSize, minImageSize, t)!;
    final double imageTop = lerpDouble(maxImageTop, minImageTop, t)!;
    final double imageOpacity = lerpDouble(1.0, 0.85, t)!;
    // Subtle depth cue as the header collapses: the photo drifts a hair
    // slower than the chrome around it, like the parallax on the list.
    final double imageParallax = t * 10;

    return SizedBox(
      height: currentHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: headerRadius,
              child: recipe.hasCardColor
                  ? Hero(
                      tag: 'recipe-bg-${recipe.id}',
                      flightShuttleBuilder: backgroundFlightShuttleBuilder,
                      child: ValueListenableBuilder<double>(
                        valueListenable: progress,
                        builder: (context, p, child) {
                          return Container(
                            color: Color.lerp(recipe.color, Colors.white, p * 0.35),
                          );
                        },
                      ),
                    )
                  : Container(color: recipe.color),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 1 - t,
              child: const _DecorativeStickers(),
            ),
          ),
          Positioned(
            top: imageTop - imageParallax,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: imageOpacity,
                child: _DoubleTapHeart(
                  onFavorite: onDoubleTapFavorite,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      _StepRipple(signal: rippleSignal, baseSize: imageSize),
                      ValueListenableBuilder<double>(
                        valueListenable: overscroll,
                        builder: (context, pull, child) {
                          // Elastic pull-to-stretch: only relevant while
                          // pinned at rest (t == 0) — once the user starts
                          // scrolling down, `pull` is naturally back at 0.
                          final double stretch = (pull / 90).clamp(0.0, 1.0).toDouble();
                          return Transform.scale(
                            scale: 1 + stretch * 0.14,
                            child: child,
                          );
                        },
                        child: Hero(
                          tag: 'recipe-image-${recipe.id}',
                          flightShuttleBuilder: plateFlightShuttleBuilder,
                          child: FloatingImagePlate(
                            imageUrl: recipe.imageUrl,
                            size: imageSize,
                            kenBurns: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant RecipeHeaderDelegate oldDelegate) {
    return oldDelegate.recipe.id != recipe.id;
  }
}

/// Plays one expanding, fading ring from the plate's center every time
/// [signal] changes value — a quiet "nice, logged" pulse each time a
/// step gets checked off in cooking mode. Renders nothing between
/// triggers (no idle `CustomPaint` sitting in the tree costing paint
/// time for no visual reason).
/// Double-tapping the photo favorites the recipe with a big heart
/// popping in and settling back out — the familiar Instagram-style
/// gesture. Always plays the pop (even if already favorited, same as
/// Instagram never *un*-likes on a double-tap), so it never feels like
/// the tap was ignored.
class _DoubleTapHeart extends StatefulWidget {
  final Widget child;
  final VoidCallback? onFavorite;

  const _DoubleTapHeart({required this.child, required this.onFavorite});

  @override
  State<_DoubleTapHeart> createState() => _DoubleTapHeartState();
}

class _DoubleTapHeartState extends State<_DoubleTapHeart> with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    HapticFeedback.mediumImpact();
    widget.onFavorite?.call();
    _burst.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: widget.onFavorite == null ? null : _handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          widget.child,
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _burst,
              builder: (context, _) {
                final double raw = _burst.value;
                if (raw <= 0.0 || raw >= 1.0) return const SizedBox.shrink();
                // Pops in with an overshoot across the first 55% of the
                // animation, then holds/fades through the rest.
                final double growT = (raw / 0.55).clamp(0.0, 1.0).toDouble();
                final double scale = 0.4 + Curves.easeOutBack.transform(growT) * 1.0;
                final double fadeT = raw < 0.55 ? 1.0 : (1 - (raw - 0.55) / 0.45).clamp(0.0, 1.0).toDouble();
                return Opacity(
                  opacity: fadeT,
                  child: Transform.scale(
                    scale: scale,
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 84,
                      shadows: [Shadow(color: Colors.black38, blurRadius: 18)],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRipple extends StatefulWidget {
  final ValueListenable<int> signal;
  final double baseSize;

  const _StepRipple({required this.signal, required this.baseSize});

  @override
  State<_StepRipple> createState() => _StepRippleState();
}

class _StepRippleState extends State<_StepRipple> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    widget.signal.addListener(_trigger);
  }

  void _trigger() {
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    widget.signal.removeListener(_trigger);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.value <= 0.0 || _controller.value >= 1.0) {
            return const SizedBox.shrink();
          }
          final double t = Curves.easeOut.transform(_controller.value);
          final double diameter = widget.baseSize * (1.0 + t * 0.7);
          final double opacity = (1 - t) * 0.55;
          return Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(opacity), width: 2.4),
            ),
          );
        },
      ),
    );
  }
}

class _DecorativeStickers extends StatelessWidget {
  const _DecorativeStickers();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          top: 24,
          left: 30,
          child: _FloatingSticker('🍃', phase: 0, durationMs: 2600, amplitude: 7),
        ),
        Positioned(
          top: 40,
          right: 40,
          child: _FloatingSticker('🍋', phase: 1, durationMs: 3200, amplitude: 9),
        ),
        Positioned(
          bottom: 30,
          left: 50,
          child: _FloatingSticker('🍃', phase: 2, durationMs: 3000, amplitude: 6),
        ),
        Positioned(
          bottom: 40,
          right: 60,
          child: _FloatingSticker('✨', phase: 3, durationMs: 2200, amplitude: 8),
        ),
      ],
    );
  }
}

/// A small decorative emoji that idles up and down on its own clock —
/// not tied to scroll — with a per-instance [phase], [durationMs] and
/// [amplitude] so a handful of them never move in lockstep.
class _FloatingSticker extends StatefulWidget {
  final String emoji;
  final int phase;
  final int durationMs;
  final double amplitude;

  const _FloatingSticker(
    this.emoji, {
    required this.phase,
    required this.durationMs,
    required this.amplitude,
  });

  @override
  State<_FloatingSticker> createState() => _FloatingStickerState();
}

class _FloatingStickerState extends State<_FloatingSticker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );
    final double startAt = (widget.phase % 4) / 4;
    _controller.forward(from: startAt);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = Curves.easeInOut.transform(_controller.value);
        final double dy = (t - 0.5) * widget.amplitude;
        final double angle = (t - 0.5) * 0.22;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(angle: angle, child: child),
        );
      },
      child: Opacity(
        opacity: 0.55,
        child: Text(widget.emoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
