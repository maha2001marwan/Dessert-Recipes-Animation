import 'package:flutter/material.dart';

/// Design tokens that aren't already covered by [ColorScheme] — the
/// specific greys/text colors this UI needs — expressed as a proper
/// [ThemeExtension] so every widget reads colors from `Theme.of(context)`
/// instead of hard-coded constants. This is what makes dark mode "just
/// work" instead of requiring `if (isDark)` checks scattered everywhere.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color screenBackground;
  final Color plainCardSurface;
  final Color titleText;
  final Color bodyText;
  final Color ingredientText;
  final Color stepText;
  final Color sectionHeader;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppSemanticColors({
    required this.screenBackground,
    required this.plainCardSurface,
    required this.titleText,
    required this.bodyText,
    required this.ingredientText,
    required this.stepText,
    required this.sectionHeader,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static const AppSemanticColors light = AppSemanticColors(
    screenBackground: Color(0xFFFFFFFF),
    plainCardSurface: Color(0xFFFFFFFF),
    titleText: Color(0xFF26262B),
    bodyText: Color(0xFF6B6B72),
    ingredientText: Color(0xFF33333A),
    stepText: Color(0xFF44444C),
    sectionHeader: Color(0xFF2C2C33),
    shimmerBase: Color(0xFFE3E3E3),
    shimmerHighlight: Color(0xFFF6F6F6),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    screenBackground: Color(0xFF15151A),
    plainCardSurface: Color(0xFF222228),
    titleText: Color(0xFFF3F3F5),
    bodyText: Color(0xFFB2B2BA),
    ingredientText: Color(0xFFE4E4E8),
    stepText: Color(0xFFCACAD2),
    sectionHeader: Color(0xFFF0F0F3),
    shimmerBase: Color(0xFF2A2A32),
    shimmerHighlight: Color(0xFF38383F),
  );

  @override
  AppSemanticColors copyWith({
    Color? screenBackground,
    Color? plainCardSurface,
    Color? titleText,
    Color? bodyText,
    Color? ingredientText,
    Color? stepText,
    Color? sectionHeader,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppSemanticColors(
      screenBackground: screenBackground ?? this.screenBackground,
      plainCardSurface: plainCardSurface ?? this.plainCardSurface,
      titleText: titleText ?? this.titleText,
      bodyText: bodyText ?? this.bodyText,
      ingredientText: ingredientText ?? this.ingredientText,
      stepText: stepText ?? this.stepText,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      screenBackground: Color.lerp(screenBackground, other.screenBackground, t)!,
      plainCardSurface: Color.lerp(plainCardSurface, other.plainCardSurface, t)!,
      titleText: Color.lerp(titleText, other.titleText, t)!,
      bodyText: Color.lerp(bodyText, other.bodyText, t)!,
      ingredientText: Color.lerp(ingredientText, other.ingredientText, t)!,
      stepText: Color.lerp(stepText, other.stepText, t)!,
      sectionHeader: Color.lerp(sectionHeader, other.sectionHeader, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

/// The fixed, vivid recipe accent palette. These intentionally do NOT
/// change between light/dark — a card's brand color should stay
/// recognizable in both themes; only the neutrals around it adapt.
class RecipeColors {
  RecipeColors._();

  static const Color red = Color(0xFFC1393E);
  static const Color orange = Color(0xFFC9480C);
  static const Color yellow = Color(0xFFE8C24C);
  static const Color teal = Color(0xFF7FA9B4);
  static const Color pink = Color(0xFFF1A7B4);
}
