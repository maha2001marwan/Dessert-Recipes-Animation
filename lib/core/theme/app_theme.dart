import 'package:flutter/material.dart';
import 'app_semantic_colors.dart';

/// Builds the app's [ThemeData] for both brightness modes. Widgets should
/// never hard-code colors for text/backgrounds — they pull from
/// `Theme.of(context).colorScheme` and `Theme.of(context).extension<AppSemanticColors>()`.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        semantics: AppSemanticColors.light,
        seed: RecipeColors.orange,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        semantics: AppSemanticColors.dark,
        seed: RecipeColors.orange,
      );

  static ThemeData _build({
    required Brightness brightness,
    required AppSemanticColors semantics,
    required Color seed,
  }) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: semantics.screenBackground,
      splashFactory: InkRipple.splashFactory,
      extensions: [semantics],
    );
  }
}
