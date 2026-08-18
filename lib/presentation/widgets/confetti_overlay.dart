import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A short burst of small colored shapes, fired once when [signal]
/// changes — used to celebrate finishing every step in cooking mode.
///
/// Self-contained (no external confetti package): a fixed set of
/// particles, each with its own angle, speed, rotation and color,
/// animated by one [AnimationController] with simple gravity added to
/// their vertical fall. Renders nothing (an empty [SizedBox], no
/// [CustomPaint] in the tree at all) whenever it isn't actively
/// playing, so it costs nothing outside the ~1.4s celebration.
class ConfettiOverlay extends StatefulWidget {
  final ValueListenable<int> signal;

  const ConfettiOverlay({super.key, required this.signal});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;
  final _ParticleShape shape;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
    required this.shape,
  });
}

enum _ParticleShape { circle, square, triangle }

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  List<_Particle> _particles = const [];

  static const List<Color> _palette = [
    Color(0xFFE7684C),
    Color(0xFFE0A93E),
    Color(0xFF4C9F70),
    Color(0xFF4C82E0),
    Color(0xFFD65CA8),
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    widget.signal.addListener(_trigger);
  }

  void _trigger() {
    final math.Random random = math.Random();
    _particles = List.generate(28, (i) {
      final double baseAngle = -math.pi / 2;
      final double spread = (random.nextDouble() - 0.5) * math.pi * 1.15;
      return _Particle(
        angle: baseAngle + spread,
        speed: 90 + random.nextDouble() * 130,
        size: 5 + random.nextDouble() * 5,
        spin: (random.nextDouble() - 0.5) * 10,
        color: _palette[random.nextInt(_palette.length)],
        shape: _ParticleShape.values[random.nextInt(_ParticleShape.values.length)],
      );
    });
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
          if (_controller.value <= 0.0 || _controller.value >= 1.0 || _particles.isEmpty) {
            return const SizedBox.shrink();
          }
          return RepaintBoundary(
            child: CustomPaint(
              painter: _ConfettiPainter(particles: _particles, t: _controller.value),
              size: Size.infinite,
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  _ConfettiPainter({required this.particles, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset origin = Offset(size.width / 2, size.height * 0.32);
    final double fade = t > 0.7 ? (1 - (t - 0.7) / 0.3).clamp(0.0, 1.0).toDouble() : 1.0;

    for (final particle in particles) {
      final double dist = particle.speed * t;
      final double gravity = 260 * t * t;
      final double dx = math.cos(particle.angle) * dist;
      final double dy = math.sin(particle.angle) * dist + gravity;
      final Offset pos = origin + Offset(dx, dy);
      final double rotation = particle.spin * t * math.pi;

      final Paint paint = Paint()..color = particle.color.withOpacity(fade);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rotation);
      switch (particle.shape) {
        case _ParticleShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case _ParticleShape.square:
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size),
            paint,
          );
          break;
        case _ParticleShape.triangle:
          final Path path = Path()
            ..moveTo(0, -particle.size / 2)
            ..lineTo(particle.size / 2, particle.size / 2)
            ..lineTo(-particle.size / 2, particle.size / 2)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
