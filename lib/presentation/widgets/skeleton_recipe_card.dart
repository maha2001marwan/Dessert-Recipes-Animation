import 'package:flutter/material.dart';
import 'recipe_card.dart';
import 'shimmer_box.dart';

/// A shimmer placeholder shaped exactly like [RecipeCard], shown for a
/// brief moment while the (mock) recipe feed "loads" — so the list
/// doesn't just pop into existence.
class SkeletonRecipeCard extends StatelessWidget {
  const SkeletonRecipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RecipeCard.bottomSpacing),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RecipeCard.cardRadius),
        child: const SizedBox(
          height: RecipeCard.cardHeight,
          child: ShimmerBox(),
        ),
      ),
    );
  }
}
