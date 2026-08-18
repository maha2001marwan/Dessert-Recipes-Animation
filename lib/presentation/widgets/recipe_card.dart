import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../data/models/recipe.dart';
import '../controllers/favorites_controller.dart';
import 'floating_plate.dart';
import 'hero_flight.dart';
import 'shine_sweep.dart';

/// A single card in the recipe list.
///
/// Layers, bottom to top:
/// 1. Colored (or plain) background — Hero'd into the detail header.
///    Flashes in from white the first time the card appears (a fast
///    scroll shouldn't feel like content loading in raw, unstyled).
/// 2. Title + description — plain, not part of any Hero. Positioned on
///    the *start* side (left in LTR, right in RTL) via
///    [AlignmentDirectional] so the layout mirrors correctly for Arabic.
/// 3. The overflowing plate on the *end* side — Hero'd, rotates with
///    scroll, drifts with a subtle parallax offset, and — independently
///    of all that — floats gently on its own clock with a white ring, a
///    glassy highlight and a detached breathing shadow (see
///    [FloatingImagePlate]).
///
/// The whole card also has its own entrance animation, a one-shot light
/// sweep after it settles, and a tactile press-scale + ripple on tap.
///
/// Entrance direction is scroll-aware (see the reference video analysis,
/// sections 1.3 and 1.4): cards that appear while the list is scrolling
/// *down* fade + slide up from below, like every other list. Cards that
/// appear while scrolling *back up* instead unfold with a brief 3D tilt
/// around their top edge, like a lid opening — a deliberately different
/// directional cue, not just the same animation played backwards.
class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final int index;
  final String languageCode;
  final VoidCallback onTap;
  final ValueListenable<double> plateRotation;
  final ValueListenable<double> scrollOffset;
  final ValueListenable<bool> isScrollingUp;
  /// Optional: enables long-press-to-favorite with a heart-burst overlay.
  /// `null` leaves long-press doing nothing, same as before this existed.
  final FavoritesController? favoritesController;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.index,
    required this.languageCode,
    required this.onTap,
    required this.plateRotation,
    required this.scrollOffset,
    required this.isScrollingUp,
    this.favoritesController,
  });

  static const double cardHeight = 160;
  static const double imageSize = 150;
  static const double imageTop = 50; // ~40px overflow below the card
  static const double bottomSpacing = 30;
  static const double cardRadius = 26;

  /// The fixed vertical space every item occupies in the list — used to
  /// estimate each card's nominal scroll position for the parallax effect
  /// without needing any RenderBox lookups.
  static const double itemExtent = imageTop + imageSize + bottomSpacing;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final bool _unfoldFromTop;
  bool _revealed = false;
  bool _pressed = false;
  late final int _delayMs;
  late final AnimationController _quickFavoriteBurst;

  @override
  void initState() {
    super.initState();
    // Snapshot the scroll direction *at the moment this card is first
    // built* — that's effectively "as it enters the viewport" for a
    // lazily-built ListView.builder.
    _unfoldFromTop = widget.isScrollingUp.value;
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _delayMs = (55 * widget.index).clamp(0, 380).toInt();
    Future.delayed(Duration(milliseconds: _delayMs), () {
      if (!mounted) return;
      setState(() => _revealed = true);
      _entrance.forward();
    });
    _quickFavoriteBurst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    _quickFavoriteBurst.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
    HapticFeedback.selectionClick();
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  void _handleTap() {
    setState(() => _pressed = false);
    widget.onTap();
  }

  void _handleLongPress() {
    final FavoritesController? controller = widget.favoritesController;
    if (controller == null) return;
    HapticFeedback.mediumImpact();
    controller.toggle(widget.recipe.id);
    _quickFavoriteBurst.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final bool colored = widget.recipe.hasCardColor;
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;

    final Widget cardBody = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(RecipeCard.cardRadius),
          splashColor: colored
              ? Colors.white.withOpacity(0.22)
              : widget.recipe.color.withOpacity(0.15),
          highlightColor: Colors.transparent,
          onTapDown: _handleTapDown,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          onLongPress: widget.favoritesController == null ? null : _handleLongPress,
          child: SizedBox(
            height: RecipeCard.imageTop + RecipeCard.imageSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // --- Layer 1: colored / plain background ---------
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _CardBackground(
                    recipe: widget.recipe,
                    colored: colored,
                    plainSurface: semantics.plainCardSurface,
                    revealed: _revealed,
                  ),
                ),

                // --- Layer 2: title + description (start side) ---
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: RecipeCard.cardHeight,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 22, top: 20, end: 12),
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: FractionallySizedBox(
                        widthFactor: 0.58,
                        alignment: AlignmentDirectional.topStart,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.recipe.title.resolve(widget.languageCode),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.15,
                                color: colored ? Colors.white : semantics.titleText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.recipe.shortDescription.resolve(widget.languageCode),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.3,
                                color: colored
                                    ? Colors.white.withOpacity(0.85)
                                    : semantics.bodyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Layer 3: overflowing, floating, rotating,
                //              parallaxed, Hero'd plate (end side) ----
                PositionedDirectional(
                  end: 16,
                  top: RecipeCard.imageTop,
                  child: Hero(
                    tag: 'recipe-image-${widget.recipe.id}',
                    flightShuttleBuilder: plateFlightShuttleBuilder,
                    child: _AnimatedPlate(
                      recipe: widget.recipe,
                      size: RecipeCard.imageSize,
                      index: widget.index,
                      rotation: widget.plateRotation,
                      scrollOffset: widget.scrollOffset,
                    ),
                  ),
                ),

                // --- Layer 4: long-press-to-favorite heart burst,
                //              centered over the whole card ----------
                if (widget.favoritesController != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _quickFavoriteBurst,
                          builder: (context, _) {
                            final double raw = _quickFavoriteBurst.value;
                            if (raw <= 0.0 || raw >= 1.0) return const SizedBox.shrink();
                            final double growT = (raw / 0.5).clamp(0.0, 1.0).toDouble();
                            final double scale =
                                0.3 + Curves.easeOutBack.transform(growT) * 0.9;
                            final double fadeT = raw < 0.5
                                ? 1.0
                                : (1 - (raw - 0.5) / 0.5).clamp(0.0, 1.0).toDouble();
                            return Opacity(
                              opacity: fadeT,
                              child: Transform.scale(
                                scale: scale,
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: 56,
                                  shadows: [Shadow(color: Colors.black38, blurRadius: 14)],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: RecipeCard.bottomSpacing),
      child: AnimatedBuilder(
        animation: _entrance,
        builder: (context, child) {
          final double t = Curves.easeOutCubic.transform(_entrance.value);

          // Section 1.3 (scrolling down): plain fade + slide up.
          // Section 1.4 (scrolling up, "الفرق الأساسي"): a brief 3D
          // unfold around the top edge instead — same perspective-matrix
          // idea as the reference analysis, just expressed with
          // Transform instead of a raw Matrix4 the caller has to build.
          final double rotationX = _unfoldFromTop ? (1 - t) * -0.34 : (1 - t) * 0.14;
          final double slideY = _unfoldFromTop ? (1 - t) * -18 : (1 - t) * 26;
          final Alignment pivot = _unfoldFromTop ? Alignment.topCenter : Alignment.bottomCenter;

          return Opacity(
            opacity: t,
            child: Transform(
              alignment: pivot,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(rotationX),
              child: Transform.translate(offset: Offset(0, slideY), child: child),
            ),
          );
        },
        child: ShineSweep(
          delay: Duration(milliseconds: _delayMs + 320),
          child: _TouchTilt(child: cardBody),
        ),
      ),
    );
  }
}

/// A light, physical-feeling tilt that follows the finger while pressing
/// the card — like tipping a real photo card in your hand — and springs
/// back once released (reference video analysis, idea bank #2).
///
/// Deliberately built on [Listener] rather than [GestureDetector]:
/// `Listener` observes raw pointer events without entering the gesture
/// arena, so it can never "steal" the tap from the [InkWell] beneath it —
/// the card's primary job (opening the recipe) always keeps working.
class _TouchTilt extends StatefulWidget {
  final Widget child;
  const _TouchTilt({required this.child});

  @override
  State<_TouchTilt> createState() => _TouchTiltState();
}

class _TouchTiltState extends State<_TouchTilt> with SingleTickerProviderStateMixin {
  double _tiltX = 0;
  double _tiltY = 0;
  AnimationController? _springBack;

  @override
  void dispose() {
    _springBack?.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerMoveEvent event) {
    _springBack?.stop();
    setState(() {
      _tiltY = (_tiltY + event.delta.dx * 0.0009).clamp(-0.055, 0.055).toDouble();
      _tiltX = (_tiltX - event.delta.dy * 0.0009).clamp(-0.055, 0.055).toDouble();
    });
  }

  void _release() {
    final double fromX = _tiltX;
    final double fromY = _tiltY;
    if (fromX == 0 && fromY == 0) return;
    _springBack?.dispose();
    final AnimationController controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _springBack = controller;
    controller.addListener(() {
      final double eased = Curves.elasticOut.transform(controller.value);
      if (!mounted) return;
      setState(() {
        _tiltX = fromX * (1 - eased);
        _tiltY = fromY * (1 - eased);
      });
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: RepaintBoundary(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0016)
            ..rotateX(_tiltX)
            ..rotateY(_tiltY),
          child: widget.child,
        ),
      ),
    );
  }
}

class _CardBackground extends StatelessWidget {
  final Recipe recipe;
  final bool colored;
  final Color plainSurface;
  final bool revealed;
  const _CardBackground({
    required this.recipe,
    required this.colored,
    required this.plainSurface,
    required this.revealed,
  });

  @override
  Widget build(BuildContext context) {
    final Widget fill = colored
        ? Hero(
            tag: 'recipe-bg-${recipe.id}',
            flightShuttleBuilder: backgroundFlightShuttleBuilder,
            child: Container(height: RecipeCard.cardHeight, color: recipe.color),
          )
        : Container(height: RecipeCard.cardHeight, color: plainSurface);

    return Container(
      decoration: colored
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RecipeCard.cardRadius),
        child: Stack(
          children: [
            fill,
            // Section 1.5: on a fast scroll, cards should never look like
            // they "lag" in blank/white before their color loads — so we
            // make that momentary blankness intentional and smooth
            // instead of accidental: a plain white veil that fades away
            // the moment the card is revealed, never covering it again.
            if (colored)
              IgnorePointer(
                child: AnimatedOpacity(
                  opacity: revealed ? 0 : 1,
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOut,
                  child: Container(height: RecipeCard.cardHeight, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Combines the slow scroll-linked rotation with a subtle parallax drift:
/// each card's nominal position is `index * itemExtent`, so how far the
/// current [scrollOffset] has moved past that position tells us how far
/// through the viewport this card has traveled — driving a small vertical
/// offset without ever needing a RenderBox lookup.
///
/// The [FloatingImagePlate] underneath adds its own continuous,
/// scroll-independent float, ring and shadow — this widget only ever
/// applies the *scroll-driven* transforms on top of it.
class _AnimatedPlate extends StatelessWidget {
  final Recipe recipe;
  final double size;
  final int index;
  final ValueListenable<double> rotation;
  final ValueListenable<double> scrollOffset;

  const _AnimatedPlate({
    required this.recipe,
    required this.size,
    required this.index,
    required this.rotation,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: scrollOffset,
      builder: (context, offset, child) {
        final double estimatedItemTop = index * RecipeCard.itemExtent;
        final double delta = offset - estimatedItemTop;
        final double parallax = (delta * 0.05).clamp(-10.0, 10.0).toDouble();
        return Transform.translate(
          offset: Offset(0, parallax),
          child: child,
        );
      },
      child: ValueListenableBuilder<double>(
        valueListenable: rotation,
        builder: (context, angle, child) {
          return Transform.rotate(angle: angle, child: child);
        },
        child: FloatingImagePlate(
          imageUrl: recipe.imageUrl,
          size: size,
          phase: index,
        ),
      ),
    );
  }
}
