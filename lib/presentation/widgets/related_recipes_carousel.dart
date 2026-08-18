import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../data/models/recipe.dart';
import '../controllers/favorites_controller.dart';
import '../screens/recipe_detail_screen.dart';
import 'flip_page_route.dart';

/// A horizontal row of small recipe cards — used for both "You might
/// also like" at the bottom of the detail screen (recipes from the same
/// category) and "Recently viewed" on the list screen (via [title]
/// override). Cards cascade in with a short staggered fade+slide the
/// first time the section is revealed, and each pushes a fresh detail
/// screen (its own independent Hero flight) on tap.
class RelatedRecipesCarousel extends StatelessWidget {
  final List<Recipe> recipes;
  final String languageCode;
  final Animation<double> reveal;
  final FavoritesController favoritesController;
  final String? title;

  const RelatedRecipesCarousel({
    super.key,
    required this.recipes,
    required this.languageCode,
    required this.reveal,
    required this.favoritesController,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) return const SizedBox.shrink();
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? strings.relatedRecipes,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: semantics.sectionHeader),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final CurvedAnimation curved = CurvedAnimation(
                parent: reveal,
                curve: Interval(
                  (index * 0.1).clamp(0.0, 0.7).toDouble(),
                  (index * 0.1 + 0.4).clamp(0.0, 1.0).toDouble(),
                  curve: Curves.easeOutCubic,
                ),
              );
              return AnimatedBuilder(
                animation: curved,
                builder: (context, child) {
                  final double t = curved.value.clamp(0.0, 1.0).toDouble();
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(offset: Offset((1 - t) * 24, 0), child: child),
                  );
                },
                child: _RelatedCard(
                  recipe: recipe,
                  languageCode: languageCode,
                  favoritesController: favoritesController,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RelatedCard extends StatefulWidget {
  final Recipe recipe;
  final String languageCode;
  final FavoritesController favoritesController;

  const _RelatedCard({
    required this.recipe,
    required this.languageCode,
    required this.favoritesController,
  });

  @override
  State<_RelatedCard> createState() => _RelatedCardState();
}

class _RelatedCardState extends State<_RelatedCard> {
  bool _pressed = false;

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

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () => _open(context),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: semantics.plainCardSurface,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.4,
                child: Container(
                  color: widget.recipe.color,
                  child: Image.network(widget.recipe.imageUrl, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.title.resolve(widget.languageCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: semantics.titleText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 12, color: semantics.bodyText),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.recipe.prepMinutes} ${strings.minutes}',
                          style: TextStyle(fontSize: 11, color: semantics.bodyText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
