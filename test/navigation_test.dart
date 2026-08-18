import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dessert_recipes/app.dart';
import 'package:dessert_recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:dessert_recipes/presentation/widgets/recipe_card.dart';

void main() {
  testWidgets('tapping a recipe card opens the detail screen without errors',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const DessertRecipesApp());

    // Let the fake loading skeleton finish (650ms timer) and the cards
    // reveal themselves.
    for (int i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(tester.takeException(), isNull,
        reason: 'no exception after the list settles');

    expect(find.byType(RecipeCard), findsWidgets,
        reason: 'recipe cards should be on screen');

    await tester.tap(find.byType(RecipeCard).first, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 500));

    final Object? navException = tester.takeException();
    expect(navException, isNull,
        reason: 'no exception right after tapping a dish');

    // Push transition duration is 420ms; step through the rest of it.
    await tester.pump(const Duration(milliseconds: 500));

    final Object? lateException = tester.takeException();
    expect(lateException, isNull,
        reason: 'no exception while the detail screen animates in');

    expect(find.byType(RecipeDetailScreen), findsOneWidget,
        reason: 'detail screen should be on top');
  });
}
