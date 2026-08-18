import 'package:shared_preferences/shared_preferences.dart';

/// Persists the ids of recently-opened recipes, most-recent-first,
/// capped at [maxEntries] — backs the "Recently viewed" row on the
/// list screen.
class RecentlyViewedLocalDataSource {
  static const String _key = 'recently_viewed_recipe_ids';
  static const int maxEntries = 8;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  Future<void> recordView(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_key) ?? [];
    current.remove(recipeId); // de-dupe, then re-insert at the front
    current.insert(0, recipeId);
    final List<String> trimmed = current.take(maxEntries).toList();
    await prefs.setStringList(_key, trimmed);
  }
}
