import 'package:flutter/material.dart';
import '../../core/theme/app_semantic_colors.dart';
import 'shimmer_box.dart';

/// A network image with a shimmer loading placeholder and a graceful
/// fallback icon if the image fails to load (e.g. no network access).
///
/// Whenever it's used inside a circular clip (every place it appears in
/// this app), the rectangular [ShimmerBox] gets clipped into a disc for
/// free, and once the image actually finishes loading it doesn't just
/// snap into place — it pops in with a tiny overshoot
/// ([Curves.easeOutBack]), the same "landing" feel used everywhere else
/// in this app.
class RecipeImage extends StatelessWidget {
  final String url;
  const RecipeImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            builder: (context, scale, scaledChild) => Transform.scale(
              scale: scale,
              child: Opacity(opacity: scale.clamp(0.0, 1.0).toDouble(), child: scaledChild),
            ),
            child: child,
          );
        }
        return const ShimmerBox();
      },
      errorBuilder: (context, error, stackTrace) => const _ImageFallback(),
    );
  }
}

/// Shown in place of a photo that failed to load — a soft neutral
/// gradient (reads as "no photo" rather than "broken", unlike a flat
/// grey block) behind an icon that fades in on arrival and then
/// breathes gently in place, so a failed load still feels like part of
/// the app's living, animated language rather than a dead end.
class _ImageFallback extends StatefulWidget {
  const _ImageFallback();

  @override
  State<_ImageFallback> createState() => _ImageFallbackState();
}

class _ImageFallbackState extends State<_ImageFallback> with TickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..forward();

  @override
  void dispose() {
    _breathe.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [semantics.shimmerBase, semantics.shimmerHighlight],
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathe, _entrance]),
        builder: (context, child) {
          final double entranceT = _entrance.value.clamp(0.0, 1.0).toDouble();
          final double breatheT = Curves.easeInOut.transform(_breathe.value);
          final double opacity = entranceT * (0.55 + breatheT * 0.35);
          return Opacity(
            opacity: opacity,
            child: Transform.scale(scale: 0.85 + entranceT * 0.15, child: child),
          );
        },
        child: Icon(Icons.cake_outlined, color: semantics.bodyText, size: 32),
      ),
    );
  }
}

