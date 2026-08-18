import 'package:shared_preferences/shared_preferences.dart';

/// Persists favorited recipe ids to disk so they survive app restarts.
/// A thin wrapper around [SharedPreferences] — kept in the data layer so
/// the presentation layer never talks to a storage API directly.
class FavoritesLocalDataSource {
  static const String _key = 'favorite_recipe_ids';

  Future<Set<String>> loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? <String>{};
  }

  Future<void> saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }
}
