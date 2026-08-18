import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/responsive.dart';
import '../../data/datasources/hints_local_datasource.dart';
import '../../data/datasources/mock_recipes.dart';
import '../../data/datasources/recently_viewed_local_datasource.dart';
import '../../data/models/recipe.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/gesture_hint_banner.dart';
import '../widgets/recipe_card.dart';
import '../widgets/related_recipes_carousel.dart';
import '../widgets/skeleton_recipe_card.dart';
import 'favorites_screen.dart';
import 'recipe_detail_screen.dart';
import 'shopping_list_screen.dart';

const double _kRefreshThreshold = 70;

class RecipeListScreen extends StatefulWidget {
  final ThemeController themeController;
  final LocaleController localeController;
  final FavoritesController favoritesController;

  const RecipeListScreen({
    super.key,
    required this.themeController,
    required this.localeController,
    required this.favoritesController,
  });

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _plateRotation = ValueNotifier<double>(0);
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);
  // Drives the "unfold from the top" entrance (section 1.4 of the
  // reference video analysis) vs the plain "fade + slide up" entrance
  // (section 1.3) — read once by each RecipeCard the moment it's built.
  final ValueNotifier<bool> _isScrollingUp = ValueNotifier<bool>(false);
  double _lastOffset = 0;
  // Custom pull-to-refresh (replaces the default Material spinner): pull
  // distance past the top, in pixels, and whether this gesture has
  // already fired a refresh (so a single long pull can't trigger twice).
  final ValueNotifier<double> _pullDistance = ValueNotifier<double>(0);
  bool _refreshArmed = false;

  bool _loading = true;
  CategoryFilter _filter; // null means "All" — see CategoryFilter typedef
  int _filterDirection = 1; // drives which way the list slides on change
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final RecentlyViewedLocalDataSource _recentlyViewedDataSource = RecentlyViewedLocalDataSource();
  List<Recipe> _recentlyViewed = [];

  final HintsLocalDataSource _hintsDataSource = HintsLocalDataSource();
  bool _showLongPressHint = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _loading = false);
    });
    _loadRecentlyViewed();
    _maybeShowLongPressHint();
  }

  Future<void> _loadRecentlyViewed() async {
    final List<String> ids = await _recentlyViewedDataSource.load();
    if (!mounted || ids.isEmpty) return;
    // Preserve the saved most-recent-first order (a plain `where` on
    // mockRecipes would silently fall back to the mock list's own
    // order instead).
    final Map<String, Recipe> byId = {for (final r in mockRecipes) r.id: r};
    final List<Recipe> resolved = ids.map((id) => byId[id]).whereType<Recipe>().toList();
    setState(() => _recentlyViewed = resolved);
  }

  Future<void> _maybeShowLongPressHint() async {
    final bool seen = await _hintsDataSource.hasSeenLongPressHint();
    if (!mounted || seen) return;
    // A small delay so it doesn't compete with the initial skeleton/list
    // entrance for attention.
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _showLongPressHint = true);
  }

  void _dismissLongPressHint() {
    setState(() => _showLongPressHint = false);
    _hintsDataSource.markLongPressHintSeen();
  }

  void _handleScroll() {
    final double offset = _scrollController.offset;
    final double delta = offset - _lastOffset;
    // Ignore tiny jitters (e.g. overscroll bounce) so direction only
    // flips on an actual, deliberate scroll gesture.
    if (delta.abs() > 0.6) {
      final bool scrollingUp = delta < 0;
      if (_isScrollingUp.value != scrollingUp) _isScrollingUp.value = scrollingUp;
      _lastOffset = offset;
    }
    _scrollOffset.value = offset;
    _plateRotation.value = offset / 180;
  }

  Future<void> _handleRefresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _loading = false);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final double pixels = notification.metrics.pixels;
    final double pull = pixels < 0 ? -pixels : 0;
    _pullDistance.value = pull;

    if (notification is ScrollEndNotification) {
      if (pull > _kRefreshThreshold && !_refreshArmed && !_loading) {
        _refreshArmed = true;
        _handleRefresh().whenComplete(() => _refreshArmed = false);
      }
      _pullDistance.value = 0;
    }
    return false;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _plateRotation.dispose();
    _scrollOffset.dispose();
    _isScrollingUp.dispose();
    _pullDistance.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> get _filteredRecipes {
    Iterable<Recipe> pool = mockRecipes;
    if (_filter != null) {
      pool = pool.where((r) => r.category == _filter);
    }
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      pool = pool.where((r) => _matchesQuery(r, query));
    }
    return pool.toList();
  }

  /// Stable left-to-right order of the filter chips ("All" first),
  /// independent of the enum's own declaration order — used only to
  /// decide which direction the list should slide when the filter
  /// changes.
  static int _filterIndex(CategoryFilter filter) {
    if (filter == null) return 0;
    return switch (filter) {
      RecipeCategory.cake => 1,
      RecipeCategory.pie => 2,
      RecipeCategory.cold => 3,
    };
  }

  void _changeFilter(CategoryFilter value) {
    final int oldIndex = _filterIndex(_filter);
    final int newIndex = _filterIndex(value);
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _scrollController = ScrollController()..addListener(_handleScroll);
    setState(() {
      _filterDirection = newIndex >= oldIndex ? 1 : -1;
      _filter = value;
    });
  }

  /// Matches against title, short description, and every ingredient —
  /// in *both* languages regardless of which one is currently active,
  /// so switching languages never makes an in-progress search feel like
  /// it broke.
  bool _matchesQuery(Recipe recipe, String query) {
    bool hits(String text) => text.toLowerCase().contains(query);
    if (hits(recipe.title.en) || hits(recipe.title.ar)) return true;
    if (hits(recipe.shortDescription.en) || hits(recipe.shortDescription.ar)) return true;
    for (final ingredient in recipe.ingredients) {
      if (hits(ingredient.text.en) || hits(ingredient.text.ar)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String languageCode = Localizations.localeOf(context).languageCode;
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    final Color accent = Theme.of(context).colorScheme.primary;

    final Animation<double> secondaryRaw =
        ModalRoute.of(context)?.secondaryAnimation ?? const AlwaysStoppedAnimation<double>(0);
    final CurvedAnimation secondary = CurvedAnimation(
      parent: secondaryRaw,
      curve: Curves.easeOutCubic,
    );

    final List<Recipe> recipes = _filteredRecipes;
    final bool noResults = !_loading && recipes.isEmpty;

    final Widget listOrSkeleton = _loading
        ? ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: 5,
            itemBuilder: (context, index) => const SkeletonRecipeCard(),
          )
        : noResults
            ? _NoSearchResults(query: _searchQuery)
            : Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: ListView.builder(
                  key: const PageStorageKey('recipe-list'),
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return RecipeCard(
                      key: ValueKey(recipe.id),
                      recipe: recipe,
                      index: index,
                      languageCode: languageCode,
                      plateRotation: _plateRotation,
                      scrollOffset: _scrollOffset,
                      isScrollingUp: _isScrollingUp,
                      favoritesController: widget.favoritesController,
                      onTap: () => _openDetail(context, recipe),
                    );
                  },
                ),
              ),
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                child: _PullToRefreshSpinner(
                  pullDistance: _pullDistance,
                  refreshing: _loading,
                  accent: accent,
                ),
              ),
            ],
          );

    final Widget listContent = SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Row(
              children: [
                _LanguageToggleButton(controller: widget.localeController),
                Expanded(
                  child: Text(
                    strings.appTitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: semantics.titleText,
                    ),
                  ),
                ),
                _ThemeToggleButton(controller: widget.themeController),
                _FavoritesNavButton(
                  favoritesController: widget.favoritesController,
                ),
                _ShoppingListNavButton(
                  favoritesController: widget.favoritesController,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (_showLongPressHint)
            GestureHintBanner(
              message: strings.longPressHint,
              icon: Icons.favorite_border_rounded,
              autoDismissAfter: const Duration(seconds: 6),
              onDismiss: _dismissLongPressHint,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SearchField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 8),
          _AmbientMoodGlow(scrollOffset: _scrollOffset, recipes: recipes, fallback: accent),
          CategoryFilterBar(
            selected: _filter,
            accent: accent,
            onChanged: _changeFilter,
          ),
          if (!_loading && _filter == null && _searchQuery.isEmpty && _recentlyViewed.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: RelatedRecipesCarousel(
                recipes: _recentlyViewed,
                languageCode: languageCode,
                reveal: kAlwaysCompleteAnimation,
                favoritesController: widget.favoritesController,
                title: strings.recentlyViewed,
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: Responsive.centeredMaxWidth(
              context,
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final Offset begin = Offset(_filterDirection * 0.10, 0);
                  return SlideTransition(
                    position: Tween<Offset>(begin: begin, end: Offset.zero).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: KeyedSubtree(key: ValueKey(_filter), child: listOrSkeleton),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: semantics.screenBackground,
      body: AnimatedBuilder(
        animation: secondary,
        child: listContent,
        builder: (context, child) {
          final double t = secondary.value;
          final double sigma = t * 6;
          final double scale = 1 - t * 0.04;
          return Transform.scale(
            scale: scale,
            child: sigma > 0
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                    child: child,
                  )
                : child,
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, Recipe recipe) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 340),
        pageBuilder: (context, animation, secondaryAnimation) => RecipeDetailScreen(
          recipe: recipe,
          favoritesController: widget.favoritesController,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    ).then((_) {
      // The recipe just opened (or one favorited/unfavorited from
      // "related"/"favorites" while inside it) may have changed what
      // "recently viewed" should show — refresh once control returns.
      if (mounted) _loadRecentlyViewed();
    });
  }
}

/// Replaces the default Material [RefreshIndicator] spinner: a small
/// dessert-plate icon that rotates in proportion to how far the list has
/// been pulled down, fading in as it approaches the trigger threshold,
/// then switching to a smooth continuous spin for the duration of the
/// actual refresh.
class _PullToRefreshSpinner extends StatefulWidget {
  final ValueListenable<double> pullDistance;
  final bool refreshing;
  final Color accent;

  const _PullToRefreshSpinner({
    required this.pullDistance,
    required this.refreshing,
    required this.accent,
  });

  @override
  State<_PullToRefreshSpinner> createState() => _PullToRefreshSpinnerState();
}

class _PullToRefreshSpinnerState extends State<_PullToRefreshSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(covariant _PullToRefreshSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshing && !oldWidget.refreshing) {
      _spin.repeat();
    } else if (!widget.refreshing && oldWidget.refreshing) {
      _spin.stop();
      _spin.value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      label: widget.refreshing ? null : strings.pullToRefresh,
      liveRegion: widget.refreshing,
      value: widget.refreshing ? strings.pullToRefresh : null,
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([widget.pullDistance, _spin]),
            builder: (context, child) {
              final double pull = widget.pullDistance.value;
              final double pullT = (pull / _kRefreshThreshold).clamp(0.0, 1.0).toDouble();
              final bool visible = widget.refreshing || pull > 4;
              if (!visible) return const SizedBox.shrink();

              final double angle =
                  widget.refreshing ? _spin.value * 2 * math.pi : pullT * 2 * math.pi;

              return Opacity(
                opacity: widget.refreshing ? 1.0 : pullT,
                child: RepaintBoundary(
                  child: Transform.scale(
                    scale: 0.7 + 0.3 * (widget.refreshing ? 1.0 : pullT),
                    child: Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accent.withOpacity(0.12),
                          border: Border.all(color: widget.accent.withOpacity(0.4), width: 1.4),
                        ),
                        child: Icon(Icons.bakery_dining_rounded, size: 17, color: widget.accent),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  final ThemeController controller;
  const _ThemeToggleButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final bool isDark = controller.isDark;
        return IconButton(
          tooltip: isDark ? strings.lightModeTooltip : strings.darkModeTooltip,
          onPressed: () {
            final Color from = Theme.of(context).scaffoldBackgroundColor;
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset origin = box.localToGlobal(box.size.center(Offset.zero));
            controller.toggle(origin: origin, fromColor: from);
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              key: ValueKey(isDark),
              color: semantics.titleText,
            ),
          ),
        );
      },
    );
  }
}

/// Opens [FavoritesScreen], with a small badge that pops in (scale +
/// fade) whenever there's at least one favorite, and animates its count
/// with the same slide-crossfade digit used elsewhere in the app.
class _FavoritesNavButton extends StatelessWidget {
  final FavoritesController favoritesController;
  const _FavoritesNavButton({required this.favoritesController});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return AnimatedBuilder(
      animation: favoritesController,
      builder: (context, _) {
        final int count = favoritesController.favoriteIds.length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: strings.favorites,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(favoritesController: favoritesController),
                ),
              ),
              icon: Icon(Icons.favorite_rounded, color: semantics.titleText),
            ),
            if (count > 0)
              PositionedDirectional(
                top: 4,
                end: 4,
                child: IgnorePointer(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    builder: (context, t, child) => Transform.scale(scale: t, child: child),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 16),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Opens [ShoppingListScreen].
class _ShoppingListNavButton extends StatelessWidget {
  final FavoritesController favoritesController;
  const _ShoppingListNavButton({required this.favoritesController});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return IconButton(
      tooltip: strings.shoppingList,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShoppingListScreen(favoritesController: favoritesController),
        ),
      ),
      icon: Icon(Icons.shopping_basket_rounded, color: semantics.titleText),
    );
  }
}

/// A compact, always-visible search field. Typing filters the list
/// live against recipe titles, descriptions, and ingredients (in both
/// languages at once — see [_RecipeListScreenState._matchesQuery]). The
/// clear button pops in only once there's something to clear.
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: semantics.plainCardSurface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, size: 19, color: semantics.bodyText),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(fontSize: 14, color: semantics.titleText),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: strings.searchHint,
                hintStyle: TextStyle(fontSize: 14, color: semantics.bodyText.withOpacity(0.7)),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final bool hasText = controller.text.isNotEmpty;
              return AnimatedScale(
                scale: hasText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  onPressed: hasText
                      ? () {
                          controller.clear();
                          onChanged('');
                        }
                      : null,
                  icon: Icon(Icons.close_rounded, color: semantics.bodyText),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

/// Shown instead of the list when a search query matches nothing —
/// echoes the query back so it's clear *what* didn't match, with a
/// gently bobbing icon consistent with the other empty states in this
/// app (Favorites, Shopping List).
class _NoSearchResults extends StatelessWidget {
  final String query;
  const _NoSearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutBack,
              builder: (context, t, child) => Transform.scale(scale: t, child: child),
              child: Icon(Icons.search_off_rounded, size: 48, color: semantics.bodyText.withOpacity(0.35)),
            ),
            const SizedBox(height: 14),
            Text(
              strings.noSearchResults(query),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: semantics.bodyText),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientMoodGlow extends StatelessWidget {
  final ValueListenable<double> scrollOffset;
  final List<Recipe> recipes;
  final Color fallback;

  const _AmbientMoodGlow({
    required this.scrollOffset,
    required this.recipes,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: scrollOffset,
      builder: (context, offset, child) {
        Color target = fallback;
        if (recipes.isNotEmpty) {
          final int index =
              (offset / RecipeCard.itemExtent).round().clamp(0, recipes.length - 1).toInt();
          final Recipe nearest = recipes[index];
          if (nearest.hasCardColor) target = nearest.color;
        }
        // No `begin` on purpose: TweenAnimationBuilder animates from
        // whatever it last painted toward the new `end` automatically,
        // so the ambient tint always eases smoothly toward whichever
        // card is nearest the top, however fast the list is scrolling.
        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: target),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, color, _) {
            final Color glow = color ?? fallback;
            // Dark backgrounds swallow low-opacity tints almost
            // entirely — the same 0.14 that reads as a soft accent on a
            // light screen is nearly invisible on a dark one, so this
            // brightens the glow (and evens out its own saturation a
            // touch) specifically for dark mode instead of using one
            // flat opacity everywhere.
            final bool isDark = Theme.of(context).brightness == Brightness.dark;
            final double topOpacity = isDark ? 0.28 : 0.14;
            return IgnorePointer(
              child: Container(
                height: 70,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [glow.withOpacity(topOpacity), glow.withOpacity(0.0)],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LanguageToggleButton extends StatelessWidget {
  final LocaleController controller;
  const _LanguageToggleButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return ValueListenableBuilder<Locale>(
      valueListenable: controller,
      builder: (context, locale, _) {
        final strings = AppLocalizations(locale);
        return TextButton(
          onPressed: controller.toggle,
          child: Text(
            strings.languageToggleLabel,
            style: TextStyle(fontWeight: FontWeight.w600, color: semantics.titleText),
          ),
        );
      },
    );
  }
}
