import 'package:flutter/material.dart';
import 'recipe_image.dart';

/// A circular recipe photo that reads as a physical object floating in
/// space rather than a flat sticker glued to the card.
///
/// Three things create that illusion together (see the reference video
/// analysis, section 1.6):
/// 1. A thin white ring (`border`) separating the photo from whatever
///    color sits behind it.
/// 2. A soft top-left radial highlight suggesting a curved, glassy
///    surface.
/// 3. A **continuous, independent** float: the plate drifts a few
///    pixels up and down on its own clock (unrelated to scroll), while a
///    *detached* shadow blob underneath breathes in the opposite
///    direction — it widens and lightens as the plate rises, exactly
///    like something lit from above and lifting away from its shadow.
///
/// [phase] staggers the cycle (pass the card's index) so a screen full
/// of plates never bobs in perfect unison — that reads as organic
/// instead of mechanical.
class FloatingImagePlate extends StatefulWidget {
  final String imageUrl;
  final double size;
  final int phase;
  final bool kenBurns;
  final double amplitude;

  const FloatingImagePlate({
    super.key,
    required this.imageUrl,
    required this.size,
    this.phase = 0,
    this.kenBurns = false,
    this.amplitude = 5,
  });

  @override
  State<FloatingImagePlate> createState() => _FloatingImagePlateState();
}

class _FloatingImagePlateState extends State<FloatingImagePlate>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  // A brief one-shot "settle" on top of the continuous float: the plate
  // arrives already turned slightly away and gently rotates + fades into
  // its resting orientation, instead of just popping into place fully
  // formed. Purely a mount-time flourish — unrelated to the endless float
  // that follows.
  late final AnimationController _settle;

  @override
  void initState() {
    super.initState();
    // 3.4–4.4s per cycle, nudged per-card so nothing is perfectly in sync.
    final int durationMs = 3400 + (widget.phase % 5) * 220;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    final double startAt = (widget.phase % 7) / 7;
    _controller.forward(from: startAt);
    _controller.repeat(reverse: true);

    _settle = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    final int settleDelayMs = 90 + widget.phase.clamp(0, 10).toInt() * 45;
    Future.delayed(Duration(milliseconds: settleDelayMs), () {
      if (mounted) _settle.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double ringWidth = (widget.size * 0.035).clamp(4.0, 6.0).toDouble();

    final Widget plate = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: ringWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.kenBurns
                ? _KenBurnsImage(url: widget.imageUrl)
                : RecipeImage(url: widget.imageUrl),
            // Faint glassy highlight, upper-left — reinforces the sense
            // of a curved, lit surface rather than a flat photo.
            IgnorePointer(
              child: Align(
                alignment: const Alignment(-0.55, -0.65),
                child: FractionallySizedBox(
                  widthFactor: 0.85,
                  heightFactor: 0.85,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.32),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Isolates the (comparatively expensive) photo + border + gradient
    // highlight into its own compositing layer, so the 60fps float/tilt
    // transform above only has to move a cached texture around instead
    // of repainting the image and gradient every single frame.
    final Widget boundedPlate = RepaintBoundary(child: plate);

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _settle]),
      builder: (context, child) {
        final double t = Curves.easeInOut.transform(_controller.value);
        final double dy = (t - 0.5) * widget.amplitude * 2;
        final double tilt = (t - 0.5) * 0.06;
        final double settleT = Curves.easeOutCubic.transform(_settle.value);
        final double settleSpin = (1 - settleT) * -0.16;

        // The shadow moves opposite the plate: as the plate rises, the
        // shadow drifts further away, widens and lightens.
        final double shadowOffsetY = 14 - dy;
        final double shadowBlur = 16 + dy.abs() * 0.6;
        final double shadowOpacity = (0.26 - dy.abs() * 0.01).clamp(0.12, 0.28).toDouble();
        final double shadowWidth = widget.size * (0.62 + dy.abs() * 0.004);

        return Opacity(
          opacity: settleT,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0018)
                ..rotateX(tilt * 0.5)
                ..rotateZ(tilt * 0.3 + settleSpin),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: -shadowOffsetY,
                    child: IgnorePointer(
                      child: Container(
                        width: shadowWidth,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(shadowOpacity),
                              blurRadius: shadowBlur,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child!,
                ],
              ),
            ),
          ),
        );
      },
      child: boundedPlate,
    );
  }
}

/// A continuous, very slow zoom on the photo — used only for the large
/// header version of the plate, where the extra motion reads as alive
/// rather than distracting.
class _KenBurnsImage extends StatefulWidget {
  final String url;
  const _KenBurnsImage({required this.url});

  @override
  State<_KenBurnsImage> createState() => _KenBurnsImageState();
}

class _KenBurnsImageState extends State<_KenBurnsImage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat(reverse: true);
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
        final double scale = 1 + 0.06 * Curves.easeInOut.transform(_controller.value);
        return Transform.scale(scale: scale, child: child);
      },
      child: RecipeImage(url: widget.url),
    );
  }
}
