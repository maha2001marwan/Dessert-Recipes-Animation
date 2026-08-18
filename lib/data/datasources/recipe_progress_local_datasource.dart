import 'package:shared_preferences/shared_preferences.dart';

/// Persists a little bit of per-recipe cooking state — the servings
/// scale and which steps are checked off — so leaving the detail screen
/// (or closing the app entirely) and coming back doesn't reset progress
/// back to zero. Mirrors [FavoritesLocalDataSource]'s shape: a thin,
/// dedicated wrapper around [SharedPreferences] kept in the data layer.
class RecipeProgressLocalDataSource {
  static String _servingsKey(String recipeId) => 'servings_$recipeId';
  static String _completedStepsKey(String recipeId) => 'completed_steps_$recipeId';

  Future<int?> loadServings(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final int? value = prefs.getInt(_servingsKey(recipeId));
    return value;
  }

  Future<void> saveServings(String recipeId, int servings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_servingsKey(recipeId), servings);
  }

  Future<Set<int>> loadCompletedSteps(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList(_completedStepsKey(recipeId));
    if (stored == null) return <int>{};
    return stored.map(int.parse).toSet();
  }

  Future<void> saveCompletedSteps(String recipeId, Set<int> steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _completedStepsKey(recipeId),
      steps.map((i) => i.toString()).toList(),
    );
  }
}
