import 'package:flutter/material.dart';
import 'localized_text.dart';

class Ingredient {
  final LocalizedText text;
  const Ingredient(this.text);
}

class RecipeStep {
  final int number;
  final LocalizedText text;
  const RecipeStep(this.number, this.text);
}

/// Broad categories used for the filter chips on the list screen.
enum RecipeCategory { cake, pie, cold }

class Recipe {
  final String id;
  final LocalizedText title;
  final LocalizedText shortDescription;
  final LocalizedText fullDescription;
  final String imageUrl;

  /// Brand accent color — fixed regardless of light/dark theme.
  final Color color;

  /// Whether the list card should render with a colored background.
  /// Some cards in the reference design are intentionally plain.
  final bool hasCardColor;

  final RecipeCategory category;
  final int prepMinutes;
  final int servings;

  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;

  const Recipe({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.imageUrl,
    required this.color,
    required this.hasCardColor,
    required this.category,
    required this.prepMinutes,
    required this.servings,
    required this.ingredients,
    required this.steps,
  });

  Color get accentColor => color;
}

/// Per-serving nutrition figures shown on the detail screen.
///
/// This is a **mock/demo app with no real nutrition database** behind
/// it — rather than hand-guess 11 sets of numbers (which would look
/// authoritative but wouldn't actually be reliable either), these are
/// derived deterministically from the recipe's category, so the same
/// recipe always shows the same figures, they land in a believable
/// range for that kind of dessert, and no per-recipe data entry was
/// needed. Swap [Recipe.nutritionEstimate] for a real lookup if this
/// ever talks to an actual nutrition API.
class NutritionEstimate {
  final int caloriesPerServing;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  const NutritionEstimate({
    required this.caloriesPerServing,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });
}

/// Kitchen tools suggested for a recipe, shown as small chips. Mapped
/// from [RecipeCategory] rather than stored per-recipe, for the same
/// reason as [NutritionEstimate].
enum KitchenTool { oven, mixer, whisk, rollingPin, fridge, bowl, bakingPan, blender }

extension RecipeExtras on Recipe {
  NutritionEstimate get nutritionEstimate {
    final int seed = id.hashCode.abs();
    final int base = switch (category) {
      RecipeCategory.cake => 320,
      RecipeCategory.pie => 280,
      RecipeCategory.cold => 190,
    };
    final int calories = base + (seed % 140);
    final int protein = 3 + (seed % 6);
    final int fat = 8 + (seed % 12);
    final int carbsFromRemainder = ((calories - protein * 4 - fat * 9) / 4).round();
    final int carbs = carbsFromRemainder.clamp(10, 80).toInt();
    return NutritionEstimate(
      caloriesPerServing: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
    );
  }

  List<KitchenTool> get suggestedEquipment {
    return switch (category) {
      RecipeCategory.cake => const [
          KitchenTool.oven,
          KitchenTool.mixer,
          KitchenTool.bakingPan,
          KitchenTool.bowl,
        ],
      RecipeCategory.pie => const [
          KitchenTool.oven,
          KitchenTool.rollingPin,
          KitchenTool.bakingPan,
          KitchenTool.bowl,
        ],
      RecipeCategory.cold => const [
          KitchenTool.fridge,
          KitchenTool.whisk,
          KitchenTool.bowl,
          KitchenTool.blender,
        ],
    };
  }

  /// A short, category-based tip — not authored per-recipe (see
  /// [NutritionEstimate] for why), but picked from a small pool using
  /// the recipe id so the same recipe always shows the same tip.
  LocalizedText get chefTip {
    const pool = [
      LocalizedText(
        en: 'Bring cold ingredients like eggs and butter to room temperature first — they combine far more evenly.',
        ar: 'أخرجي المكوّنات الباردة كالبيض والزبدة من الثلاجة قبل البدء بوقت كافٍ — تمتزج بشكل أفضل بكثير في درجة حرارة الغرفة.',
      ),
      LocalizedText(
        en: 'Measure by weight rather than volume whenever you can — a kitchen scale removes almost all the guesswork.',
        ar: 'زني المكوّنات بالوزن بدل الكوب كلما أمكن — الميزان المطبخي يزيل معظم هامش الخطأ.',
      ),
      LocalizedText(
        en: "Don't skip resting/chilling times — they're doing real work (relaxing gluten, firming fat) even though nothing looks like it's happening.",
        ar: 'لا تتجاوزي أوقات الراحة أو التبريد — فهي تقوم بعمل حقيقي (إرخاء الغلوتين، تماسك الدهن) حتى لو بدا أنه لا شيء يحدث.',
      ),
      LocalizedText(
        en: 'Taste as you go and adjust sweetness at the end — fruit ripeness and chocolate brands vary more than recipes admit.',
        ar: 'تذوّقي أثناء التحضير وعدّلي درجة الحلاوة في النهاية — نضج الفاكهة ونوع الشوكولاتة يختلفان أكثر مما تعترف به الوصفات عادة.',
      ),
      LocalizedText(
        en: 'Prep everything before you start (mise en place) — desserts move fast once heat or whipping is involved.',
        ar: 'جهّزي كل المكوّنات قبل البدء — الحلويات تتحرك بسرعة بمجرد أن تدخل الحرارة أو الخفق في المعادلة.',
      ),
    ];
    return pool[id.hashCode.abs() % pool.length];
  }
}
