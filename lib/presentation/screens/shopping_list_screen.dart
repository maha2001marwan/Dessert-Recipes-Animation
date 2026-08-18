import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../data/datasources/mock_recipes.dart';
import '../../data/models/recipe.dart';
import '../controllers/favorites_controller.dart';

/// A shopping list built from every favorited recipe's ingredients,
/// grouped by recipe. Checking an item off doesn't just cross it out —
/// it animates out of its spot and re-inserts itself at the bottom of
/// its group (built on Flutter's own [AnimatedList], no package), so
/// the list keeps sorting itself into "still need this" / "got it" as
/// you shop, the way crossing things off a paper list naturally works.
///
/// Deliberately *not* wired to the checkboxes on each recipe's own
/// detail screen — those live in that screen's local, per-visit state
/// and aren't persisted anywhere, so there's nothing durable to read
/// here. This screen keeps its own independent checklist instead.
class ShoppingListScreen extends StatefulWidget {
  final FavoritesController favoritesController;

  const ShoppingListScreen({super.key, required this.favoritesController});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  bool _justCopied = false;

  @override
  void initState() {
    super.initState();
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _copyList(
    BuildContext context,
    List<Recipe> favorites,
    String languageCode,
    AppLocalizations strings,
  ) {
    final buffer = StringBuffer()..writeln(strings.shoppingList);
    for (final recipe in favorites) {
      buffer
        ..writeln()
        ..writeln('${recipe.title.resolve(languageCode)}:');
      for (final ingredient in recipe.ingredients) {
        buffer.writeln('• ${ingredient.text.resolve(languageCode)}');
      }
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    HapticFeedback.lightImpact();
    setState(() => _justCopied = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(strings.copiedToClipboard),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    final String languageCode = Localizations.localeOf(context).languageCode;

    final List<Recipe> favorites = mockRecipes
        .where((r) => widget.favoritesController.favoriteIds.contains(r.id))
        .toList();
    final int totalItems = favorites.fold(0, (sum, r) => sum + r.ingredients.length);

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.shoppingList,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: semantics.titleText,
                          ),
                        ),
                        if (favorites.isNotEmpty)
                          Text(
                            strings.shoppingListSummary(totalItems, favorites.length),
                            style: TextStyle(fontSize: 12.5, color: semantics.bodyText),
                          ),
                      ],
                    ),
                  ),
                  if (favorites.isNotEmpty)
                    IconButton(
                      tooltip: strings.copyList,
                      onPressed: () => _copyList(context, favorites, languageCode, strings),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: _justCopied
                            ? const Icon(
                                Icons.check_rounded,
                                key: ValueKey(true),
                                color: Colors.greenAccent,
                                size: 20,
                              )
                            : Icon(
                                Icons.copy_all_rounded,
                                key: const ValueKey(false),
                                size: 20,
                                color: semantics.bodyText,
                              ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? _EmptyShoppingList(entrance: _entrance)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final Recipe recipe = favorites[index];
                        final CurvedAnimation curved = CurvedAnimation(
                          parent: _entrance,
                          curve: Interval(
                            (index * 0.08).clamp(0.0, 0.6).toDouble(),
                            (index * 0.08 + 0.5).clamp(0.0, 1.0).toDouble(),
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
                                offset: Offset(0, (1 - t) * 18),
                                child: child,
                              ),
                            );
                          },
                          child: _RecipeGroup(recipe: recipe, languageCode: languageCode),
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

class _EmptyShoppingList extends StatelessWidget {
  final Animation<double> entrance;
  const _EmptyShoppingList({required this.entrance});

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
              _BobbingIcon(icon: Icons.shopping_basket_rounded, color: semantics.bodyText),
              const SizedBox(height: 18),
              Text(
                strings.shoppingListEmptyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: semantics.titleText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.shoppingListEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, height: 1.5, color: semantics.bodyText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A slow, continuous up/down bob — used by empty states across this
/// app instead of a static icon, so "nothing here yet" still feels
/// alive rather than dead.
class _BobbingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _BobbingIcon({required this.icon, required this.color});

  @override
  State<_BobbingIcon> createState() => _BobbingIconState();
}

class _BobbingIconState extends State<_BobbingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
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
        return Transform.translate(offset: Offset(0, (t - 0.5) * 10), child: child);
      },
      child: Icon(widget.icon, size: 56, color: widget.color.withOpacity(0.35)),
    );
  }
}

class _RecipeGroup extends StatefulWidget {
  final Recipe recipe;
  final String languageCode;
  const _RecipeGroup({required this.recipe, required this.languageCode});

  @override
  State<_RecipeGroup> createState() => _RecipeGroupState();
}

class _ShoppingEntry {
  final String text;
  bool checked;
  _ShoppingEntry({required this.text, this.checked = false});
}

class _RecipeGroupState extends State<_RecipeGroup> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<_ShoppingEntry> _entries;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _entries = widget.recipe.ingredients
        .map((i) => _ShoppingEntry(text: i.text.resolve(widget.languageCode)))
        .toList();
  }

  void _toggle(_ShoppingEntry entry) {
    final int index = _entries.indexOf(entry);
    if (index == -1) return;
    HapticFeedback.selectionClick();

    entry.checked = !entry.checked;
    final _ShoppingEntry removed = _entries.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildTile(removed, animation),
      duration: const Duration(milliseconds: 260),
    );

    final int insertIndex = removed.checked
        ? _entries.length
        : () {
            final int firstChecked = _entries.indexWhere((e) => e.checked);
            return firstChecked == -1 ? _entries.length : firstChecked;
          }();
    _entries.insert(insertIndex, removed);
    _listKey.currentState?.insertItem(insertIndex, duration: const Duration(milliseconds: 320));
  }

  Widget _buildTile(_ShoppingEntry entry, Animation<double> animation) {
    final CurvedAnimation curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return SizeTransition(
      sizeFactor: curved,
      child: FadeTransition(
        opacity: curved,
        child: _ShoppingTile(
          text: entry.text,
          checked: entry.checked,
          accent: widget.recipe.accentColor,
          onToggle: () => _toggle(entry),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    final int remaining = _entries.where((e) => !e.checked).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: semantics.plainCardSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: widget.recipe.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.recipe.title.resolve(widget.languageCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: semantics.titleText,
                      ),
                    ),
                  ),
                  Text(
                    '$remaining/${_entries.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.recipe.accentColor,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(Icons.expand_more_rounded, color: semantics.bodyText, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                    child: AnimatedList(
                      key: _listKey,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      initialItemCount: _entries.length,
                      itemBuilder: (context, index, animation) =>
                          _buildTile(_entries[index], animation),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ShoppingTile extends StatelessWidget {
  final String text;
  final bool checked;
  final Color accent;
  final VoidCallback onToggle;

  const _ShoppingTile({
    required this.text,
    required this.checked,
    required this.accent,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? accent : Colors.transparent,
                border: Border.all(color: accent, width: 2),
              ),
              child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 14,
                  color: checked ? semantics.bodyText.withOpacity(0.55) : semantics.ingredientText,
                  decoration: checked ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: semantics.bodyText,
                ),
                child: Text(text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
