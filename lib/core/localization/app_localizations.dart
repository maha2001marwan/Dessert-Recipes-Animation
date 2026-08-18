import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../data/models/recipe.dart' show KitchenTool;

/// Hand-written localization for the app's own UI chrome (recipe *content*
/// is localized separately via [LocalizedText] in the data layer, since
/// that's data, not UI strings). No code generation involved — just a
/// small map — so the project builds with a plain `flutter run`.
class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'appTitle': 'Dessert Recipes',
      'ingredients': 'INGREDIENTS',
      'steps': 'STEPS',
      'darkMode': 'Switch to dark mode',
      'lightMode': 'Switch to light mode',
      'language': 'العربية',
      'favorite': 'Save to favorites',
      'unfavorite': 'Remove from favorites',
      'back': 'Back',
      'share': 'Share recipe',
      'minutes': 'min',
      'servings': 'servings',
      'startCooking': 'Start Cooking',
      'cookingInProgress': 'steps done',
      'resetProgress': 'Reset',
      'categoryAll': 'All',
      'categoryCake': 'Cakes',
      'categoryPie': 'Pies',
      'categoryCold': 'Cold desserts',
      'pullToRefresh': 'Pull to refresh',
      'rateRecipe': 'Rate this recipe',
      'nutritionPerServing': 'Nutrition per serving',
      'calories': 'Calories',
      'protein': 'Protein',
      'carbs': 'Carbs',
      'fat': 'Fat',
      'equipmentNeeded': 'Equipment needed',
      'chefTip': "Chef's tip",
      'relatedRecipes': 'You might also like',
      'adjustServings': 'Adjust servings',
      'toolOven': 'Oven',
      'toolMixer': 'Hand / stand mixer',
      'toolWhisk': 'Whisk',
      'toolRollingPin': 'Rolling pin',
      'toolFridge': 'Fridge',
      'toolBowl': 'Mixing bowl',
      'toolBakingPan': 'Baking pan',
      'toolBlender': 'Blender',
      'allIngredientsReady': 'All set!',
      'ingredientsLeft': 'left',
      'shoppingList': 'Shopping List',
      'shoppingListEmptyTitle': 'Nothing to shop for yet',
      'shoppingListEmptyBody':
          'Favorite a few recipes and their ingredients will collect here automatically.',
      'items': 'items',
      'recipesWord': 'recipes',
      'favorites': 'Favorites',
      'favoritesEmptyTitle': 'No favorites yet',
      'favoritesEmptyBody': 'Tap the heart on any recipe to save it here for later.',
      'browseRecipes': 'Browse recipes',
      'removedFromFavorites': 'Removed from favorites',
      'undo': 'Undo',
      'searchHint': 'Search recipes or ingredients',
      'copiedToClipboard': 'Copied to clipboard',
      'copyList': 'Copy list',
      'longPressHint': 'Tip: long-press any card to quick-favorite it.',
      'doubleTapHint': 'Double-tap the photo to favorite this recipe',
      'recentlyViewed': 'Recently viewed',
    },
    'ar': {
      'appTitle': 'وصفات الحلويات',
      'ingredients': 'المكوّنات',
      'steps': 'خطوات التحضير',
      'darkMode': 'التبديل إلى الوضع الداكن',
      'lightMode': 'التبديل إلى الوضع الفاتح',
      'language': 'English',
      'favorite': 'إضافة للمفضلة',
      'unfavorite': 'إزالة من المفضلة',
      'back': 'رجوع',
      'share': 'مشاركة الوصفة',
      'minutes': 'دقيقة',
      'servings': 'أشخاص',
      'startCooking': 'ابدأ الطبخ',
      'cookingInProgress': 'خطوات مكتملة',
      'resetProgress': 'إعادة تعيين',
      'categoryAll': 'الكل',
      'categoryCake': 'كيك',
      'categoryPie': 'فطائر',
      'categoryCold': 'حلويات باردة',
      'pullToRefresh': 'اسحب للتحديث',
      'rateRecipe': 'قيّم هذه الوصفة',
      'nutritionPerServing': 'القيمة الغذائية لكل حصة',
      'calories': 'سعرات',
      'protein': 'بروتين',
      'carbs': 'كربوهيدرات',
      'fat': 'دهون',
      'equipmentNeeded': 'الأدوات اللازمة',
      'chefTip': 'نصيحة الشيف',
      'relatedRecipes': 'قد يعجبك أيضاً',
      'adjustServings': 'عدّلي عدد الحصص',
      'toolOven': 'فرن',
      'toolMixer': 'خفّاقة كهربائية',
      'toolWhisk': 'مضرب يدوي',
      'toolRollingPin': 'شوبك',
      'toolFridge': 'ثلاجة',
      'toolBowl': 'وعاء خلط',
      'toolBakingPan': 'صينية فرن',
      'toolBlender': 'خلاط',
      'allIngredientsReady': 'كل شي جاهز!',
      'ingredientsLeft': 'متبقّي',
      'shoppingList': 'قائمة التسوق',
      'shoppingListEmptyTitle': 'ما في شي للتسوق لسا',
      'shoppingListEmptyBody': 'أضيفي بعض الوصفات للمفضلة وبتتجمع مكوّناتها هون تلقائياً.',
      'items': 'عنصر',
      'recipesWord': 'وصفات',
      'favorites': 'المفضلة',
      'favoritesEmptyTitle': 'لا يوجد مفضلة بعد',
      'favoritesEmptyBody': 'اضغطي على القلب بأي وصفة عشان تحفظيها هون.',
      'browseRecipes': 'تصفّحي الوصفات',
      'removedFromFavorites': 'اتشالت من المفضلة',
      'undo': 'تراجعي',
      'searchHint': 'دوّري بعنوان الوصفة أو المكوّنات',
      'copiedToClipboard': 'انسخت للحافظة',
      'copyList': 'انسخي القائمة',
      'longPressHint': 'نصيحة: اضغطي ضغط مطوّل على أي كرت عشان تضيفيه للمفضلة بسرعة.',
      'doubleTapHint': 'اضغطي مرتين على الصورة عشان تضيفي الوصفة للمفضلة',
      'recentlyViewed': 'شفتيه مؤخراً',
    },
  };

  String _t(String key) => _strings[locale.languageCode]?[key] ?? _strings['en']![key]!;

  String get appTitle => _t('appTitle');
  String get ingredients => _t('ingredients');
  String get steps => _t('steps');
  String get darkModeTooltip => _t('darkMode');
  String get lightModeTooltip => _t('lightMode');
  String get languageToggleLabel => _t('language');
  String get favoriteTooltip => _t('favorite');
  String get unfavoriteTooltip => _t('unfavorite');
  String get back => _t('back');
  String get share => _t('share');
  String get minutes => _t('minutes');
  String get servings => _t('servings');
  String get startCooking => _t('startCooking');
  String get cookingInProgress => _t('cookingInProgress');
  String get resetProgress => _t('resetProgress');
  String get categoryAll => _t('categoryAll');
  String get categoryCake => _t('categoryCake');
  String get categoryPie => _t('categoryPie');
  String get categoryCold => _t('categoryCold');
  String get pullToRefresh => _t('pullToRefresh');
  String get rateRecipe => _t('rateRecipe');
  String get nutritionPerServing => _t('nutritionPerServing');
  String get calories => _t('calories');
  String get protein => _t('protein');
  String get carbs => _t('carbs');
  String get fat => _t('fat');
  String get equipmentNeeded => _t('equipmentNeeded');
  String get chefTip => _t('chefTip');
  String get relatedRecipes => _t('relatedRecipes');
  String get adjustServings => _t('adjustServings');
  String get allIngredientsReady => _t('allIngredientsReady');
  String get ingredientsLeft => _t('ingredientsLeft');
  String get shoppingList => _t('shoppingList');
  String get shoppingListEmptyTitle => _t('shoppingListEmptyTitle');
  String get shoppingListEmptyBody => _t('shoppingListEmptyBody');
  String get favorites => _t('favorites');
  String get favoritesEmptyTitle => _t('favoritesEmptyTitle');
  String get favoritesEmptyBody => _t('favoritesEmptyBody');
  String get browseRecipes => _t('browseRecipes');
  String get removedFromFavorites => _t('removedFromFavorites');
  String get undo => _t('undo');
  String get searchHint => _t('searchHint');
  String get copiedToClipboard => _t('copiedToClipboard');
  String get copyList => _t('copyList');
  String get longPressHint => _t('longPressHint');
  String get doubleTapHint => _t('doubleTapHint');
  String get recentlyViewed => _t('recentlyViewed');

  String noSearchResults(String query) {
    final bool isArabic = locale.languageCode == 'ar';
    return isArabic ? 'ما في نتائج لـ"$query"' : 'No results for "$query"';
  }

  String shoppingListSummary(int items, int recipes) {
    return '$items ${_t('items')} · $recipes ${_t('recipesWord')}';
  }

  String toolLabel(KitchenTool tool) {
    return switch (tool) {
      KitchenTool.oven => _t('toolOven'),
      KitchenTool.mixer => _t('toolMixer'),
      KitchenTool.whisk => _t('toolWhisk'),
      KitchenTool.rollingPin => _t('toolRollingPin'),
      KitchenTool.fridge => _t('toolFridge'),
      KitchenTool.bowl => _t('toolBowl'),
      KitchenTool.bakingPan => _t('toolBakingPan'),
      KitchenTool.blender => _t('toolBlender'),
    };
  }

  IconData toolIcon(KitchenTool tool) {
    return switch (tool) {
      KitchenTool.oven => Icons.microwave_rounded,
      KitchenTool.mixer => Icons.blender_rounded,
      KitchenTool.whisk => Icons.whatshot_rounded,
      KitchenTool.rollingPin => Icons.horizontal_rule_rounded,
      KitchenTool.fridge => Icons.kitchen_rounded,
      KitchenTool.bowl => Icons.ramen_dining_rounded,
      KitchenTool.bakingPan => Icons.square_rounded,
      KitchenTool.blender => Icons.blender_outlined,
    };
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
