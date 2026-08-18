import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../data/datasources/mock_recipes.dart';
import '../../data/models/recipe.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/flip_page_route.dart';
import '../widgets/floating_plate.dart';
import 'recipe_detail_screen.dart';

/// Every recipe the person has favorited, as a scrollable list of full
/// cards. Un-favoriting one shrinks it out of the list in place —
/// [AnimatedSize] + fade, driven by a short local animation before the
/// actual [FavoritesController.toggle] call — rather than the row just
/// vanishing the instant the heart is tapped.
class FavoritesScreen extends StatefulWidget {
  final FavoritesController favoritesController;

  const FavoritesScreen({super.key, required this.favoritesController});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    widget.favoritesController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.favoritesController.removeListener(_rebuild);
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    final String languageCode = Localizations.localeOf(context).languageCode;

    final List<Recipe> favorites =
        mockRecipes.where((r) => widget.favoritesController.favoriteIds.contains(r.id)).toList();

    return Scaffold(
      backgroundColor: semantics.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_forward
                          : Icons.arrow_back,
                      color: semantics.titleText,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      strings.favorites,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: semantics.titleText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? _EmptyFavorites(entrance: _entrance)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final Recipe recipe = favorites[index];
                        final CurvedAnimation curved = CurvedAnimation(
                          parent: _entrance,
                          curve: Interval(
                            (index * 0.09).clamp(0.0, 0.6).toDouble(),
                            (index * 0.09 + 0.5).clamp(0.0, 1.0).toDouble(),
                            curve: Curves.easeOutCubic,
                          ),
                        );
                        return AnimatedBuilder(
                          animation: curved,
                          builder: (context, child) {
                            final double t = curved.value.clamp(0.0, 1.0).toDouble();
                            return Opacity(
                              opacity: t,
                              child: Transform.translate(
                                offset: Offset(0, (1 - t) * 20),
                                child: child,
                              ),
                            );
                          },
                          child: _FavoriteCard(
                            key: ValueKey(recipe.id),
                            recipe: recipe,
                            languageCode: languageCode,
                            favoritesController: widget.favoritesController,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  final Animation<double> entrance;
  const _EmptyFavorites({required this.entrance});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return Center(
      child: AnimatedBuilder(
        animation: entrance,
        builder: (context, child) {
          final double t = entrance.value.clamp(0.0, 1.0).toDouble();
          return Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingHeart(color: semantics.bodyText),
              const SizedBox(height: 18),
              Text(
                strings.favoritesEmptyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: semantics.titleText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.favoritesEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, height: 1.5, color: semantics.bodyText),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(strings.browseRecipes),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A heart that softly pulses (scale breathing) — used only in the empty
/// state, a gentle invitation rather than the sharp "just favorited"
/// pop used elsewhere.
class _PulsingHeart extends StatefulWidget {
  final Color color;
  const _PulsingHeart({required this.color});

  @override
  State<_PulsingHeart> createState() => _PulsingHeartState();
}

class _PulsingHeartState extends State<_PulsingHeart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = Curves.easeInOut.transform(_controller.value);
        return Transform.scale(scale: 1 + t * 0.12, child: child);
      },
      child: Icon(Icons.favorite_rounded, size: 56, color: widget.color.withOpacity(0.3)),
    );
  }
}

class _FavoriteCard extends StatefulWidget {
  final Recipe recipe;
  final String languageCode;
  final FavoritesController favoritesController;

  const _FavoriteCard({
    super.key,
    required this.recipe,
    required this.languageCode,
    required this.favoritesController,
  });

  @override
  State<_FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<_FavoriteCard> with SingleTickerProviderStateMixin {
  late final AnimationController _removing = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  bool _pressed = false;

  @override
  void dispose() {
    _removing.dispose();
    super.dispose();
  }

  void _unfavorite() {
    HapticFeedback.lightImpact();
    final strings = AppLocalizations.of(context);
    final String recipeId = widget.recipe.id;
    _removing.forward().whenComplete(() {
      widget.favoritesController.toggle(recipeId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(strings.removedFromFavorites),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: strings.undo,
              onPressed: () {
                // Re-favoriting brings the card back with its own fresh
                // entrance animation (handled by the parent list), not
                // a reverse of this card's own removal animation, since
                // this element may already be gone from the tree by the
                // time "Undo" is tapped.
                widget.favoritesController.toggle(recipeId);
              },
            ),
          ),
        );
    });
  }

  void _open(BuildContext context) {
    Navigator.push(
      context,
      flipPageRoute(
        builder: (context) => RecipeDetailScreen(
          recipe: widget.recipe,
          favoritesController: widget.favoritesController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;

    return AnimatedBuilder(
      animation: _removing,
      builder: (context, child) {
        final double t = _removing.value;
        return SizeTransition(
          sizeFactor: ReverseAnimation(_removing),
          axisAlignment: -1,
          child: Opacity(opacity: 1 - t, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: () => _open(context),
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              decoration: BoxDecoration(
                color: widget.recipe.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipe.title.resolve(widget.languageCode),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 13, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.recipe.prepMinutes} ${strings.minutes}',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FloatingImagePlate(
                    imageUrl: widget.recipe.imageUrl,
                    size: 64,
                    phase: widget.recipe.id.hashCode,
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _unfavorite,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.16),
                      ),
                      child: const Icon(Icons.favorite_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
