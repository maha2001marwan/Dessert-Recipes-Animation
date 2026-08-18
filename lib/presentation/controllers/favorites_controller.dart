import 'package:flutter/foundation.dart';
import '../../data/datasources/favorites_local_datasource.dart';

/// Holds the current set of favorited recipe ids in memory, backed by
/// [FavoritesLocalDataSource] for persistence. Loads once at startup;
/// every toggle updates the in-memory set immediately (so the UI never
/// waits on disk I/O) and writes through in the background.
class FavoritesController extends ChangeNotifier {
  final FavoritesLocalDataSource _dataSource;
  Set<String> _favoriteIds = <String>{};
  bool _loaded = false;

  FavoritesController({FavoritesLocalDataSource? dataSource})
      : _dataSource = dataSource ?? FavoritesLocalDataSource();

  bool get isLoaded => _loaded;

  /// The current set of favorited recipe ids (read-only view) — used by
  /// screens that need to list favorites (Favorites screen, shopping
  /// list) rather than just check one id at a time.
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  Future<void> load() async {
    _favoriteIds = await _dataSource.loadFavoriteIds();
    _loaded = true;
    notifyListeners();
  }

  bool isFavorite(String recipeId) => _favoriteIds.contains(recipeId);

  void toggle(String recipeId) {
    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds = {..._favoriteIds}..remove(recipeId);
    } else {
      _favoriteIds = {..._favoriteIds, recipeId};
    }
    notifyListeners();
    // Fire-and-forget: the UI already reflects the new state.
    _dataSource.saveFavoriteIds(_favoriteIds);
  }
}
