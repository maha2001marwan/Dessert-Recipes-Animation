import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'presentation/controllers/favorites_controller.dart';
import 'presentation/screens/recipe_list_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/widgets/locale_fade_transition.dart';
import 'presentation/widgets/theme_reveal_layer.dart';

class DessertRecipesApp extends StatefulWidget {
  const DessertRecipesApp({super.key});

  @override
  State<DessertRecipesApp> createState() => _DessertRecipesAppState();
}

class _DessertRecipesAppState extends State<DessertRecipesApp> {
  final ThemeController _themeController = ThemeController();
  final LocaleController _localeController = LocaleController();
  final FavoritesController _favoritesController = FavoritesController();

  @override
  void initState() {
    super.initState();
    _favoritesController.load();
  }

  @override
  void dispose() {
    _themeController.dispose();
    _localeController.dispose();
    _favoritesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_themeController, _localeController]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Dessert Recipes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeController.mode,
          locale: _localeController.value,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Clamp accessibility text scaling so a very large system font
          // setting can't break the fixed-size layout pieces (badges,
          // ingredient rows, circular buttons) — while still letting
          // people bump text up or down within a safe, readable range.
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final double clamped = mediaQuery.textScaler.scale(1.0).clamp(0.85, 1.25).toDouble();
            return ThemeRevealLayer(
              controller: _themeController,
              child: MediaQuery(
                data: mediaQuery.copyWith(textScaler: TextScaler.linear(clamped)),
                child: LocaleFadeTransition(
                  controller: _localeController,
                  child: child!,
                ),
              ),
            );
          },
          home: SplashScreen(
            next: RecipeListScreen(
              themeController: _themeController,
              localeController: _localeController,
              favoritesController: _favoritesController,
            ),
          ),
        );
      },
    );
  }
}
