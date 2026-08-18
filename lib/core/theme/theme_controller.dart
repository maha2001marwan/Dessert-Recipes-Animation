import 'package:flutter/material.dart';

/// A minimal, dependency-free controller for the app's [ThemeMode], plus
/// the bits [ThemeRevealLayer] needs to animate a circular reveal
/// centered on wherever the toggle button was tapped.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  /// Global position the reveal circle should expand from.
  Offset? revealOrigin;

  /// The background color being covered (the *old* theme's), painted by
  /// the reveal overlay while the circular hole grows to expose the
  /// already-switched new theme underneath.
  Color? revealFromColor;

  /// Bumped on every toggle so [ThemeRevealLayer] can detect "a new
  /// reveal should play" even if somehow toggled twice in a row.
  int revealTick = 0;

  void toggle({required Offset origin, required Color fromColor}) {
    revealOrigin = origin;
    revealFromColor = fromColor;
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    revealTick++;
    notifyListeners();
  }
}
