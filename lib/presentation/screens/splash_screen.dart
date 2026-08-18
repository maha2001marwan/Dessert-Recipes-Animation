import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_semantic_colors.dart';

/// A brief branded splash shown once at cold start, before the recipe
/// list (which itself still shows its own ~650ms skeleton loading state
/// once reached — this is purely the very first frame the app shows,
/// before that).
///
/// The icon pops in with a single overshoot-and-settle, holds briefly,
/// then the whole screen fades into [next] — no looping animation,
/// since the splash is only ever on screen for about a second.
class SplashScreen extends StatefulWidget {
  final Widget next;
  const SplashScreen({super.key, required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1050), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (context, animation, secondaryAnimation) => widget.next,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantics.screenBackground,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double raw = _controller.value.clamp(0.0, 1.0).toDouble();
            final double t = Curves.easeOutBack.transform(raw);
            return Opacity(
              opacity: raw,
              child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RecipeColors.orange.withOpacity(0.14),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.cake_rounded, size: 44, color: RecipeColors.orange),
              ),
              const SizedBox(height: 18),
              Text(
                strings.appTitle,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: semantics.titleText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
