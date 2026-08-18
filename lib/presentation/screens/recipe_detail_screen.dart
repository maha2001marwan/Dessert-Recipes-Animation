import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/ingredient_scaling.dart';
import '../../core/utils/responsive.dart';
import '../../data/datasources/hints_local_datasource.dart';
import '../../data/datasources/mock_recipes.dart';
import '../../data/datasources/recently_viewed_local_datasource.dart';
import '../../data/datasources/recipe_progress_local_datasource.dart';
import '../../data/models/localized_text.dart';
import '../../data/models/recipe.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/animated_count_label.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/equipment_chips.dart';
import '../widgets/expandable_tip_card.dart';
import '../widgets/gesture_hint_banner.dart';
import '../widgets/ingredient_tile.dart';
import '../widgets/nutrition_facts.dart';
import '../widgets/related_recipes_carousel.dart';
import '../widgets/servings_stepper.dart';
import '../widgets/step_tile.dart';
import '../widgets/recipe_header_delegate.dart';
import '../widgets/staggered_fade_slide.dart';
import '../widgets/expanding_underline.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final FavoritesController favoritesController;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.favoritesController,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _headerCollapse = ValueNotifier<double>(0);
  // Positive while the user overscrolls past the top of the list (only
  // possible with BouncingScrollPhysics) — feeds the header's elastic
  // pull-to-stretch. Zero the rest of the time.
  final ValueNotifier<double> _headerOverscroll = ValueNotifier<double>(0);
  // 0..1 cooking-mode completion, feeding the header's color-lighten.
  final ValueNotifier<double> _cookingProgress = ValueNotifier<double>(0);
  // Bumped once per freshly-checked step; the header ripples in response.
  final ValueNotifier<int> _rippleSignal = ValueNotifier<int>(0);
  // Bumped once when every step is completed; fires the confetti burst.
  final ValueNotifier<int> _celebrationSignal = ValueNotifier<int>(0);
  // Plays a shake + flash on the ingredients section as a gentle nudge
  // if cooking mode is started with nothing checked off yet.
  final GlobalKey<_ShakeState> _ingredientsShakeKey = GlobalKey<_ShakeState>();

  final Set<int> _checkedIngredients = <int>{};
  final Set<int> _completedSteps = <int>{};
  bool _cookingMode = false;
  int _rating = 0;
  bool _justShared = false;
  late int _servings;
  final RecipeProgressLocalDataSource _progressDataSource = RecipeProgressLocalDataSource();
  final RecentlyViewedLocalDataSource _recentlyViewedDataSource = RecentlyViewedLocalDataSource();
  final HintsLocalDataSource _hintsDataSource = HintsLocalDataSource();
  bool _showDoubleTapHint = false;

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings;
    _restoreProgress();
    _recentlyViewedDataSource.recordView(widget.recipe.id);
    _maybeShowDoubleTapHint();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) _staggerController.forward();
    });
    _scrollController.addListener(_handleScroll);
  }

  Future<void> _maybeShowDoubleTapHint() async {
    final bool seen = await _hintsDataSource.hasSeenDoubleTapHint();
    if (!mounted || seen) return;
    // Let the entrance choreography settle first.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _showDoubleTapHint = true);
  }

  void _dismissDoubleTapHint() {
    if (!_showDoubleTapHint) return;
    setState(() => _showDoubleTapHint = false);
    _hintsDataSource.markDoubleTapHintSeen();
  }

  void _handleScroll() {
    final double offset = _scrollController.offset;
    const double range =
        RecipeHeaderDelegate.maxHeaderExtent - RecipeHeaderDelegate.minHeaderExtent;
    _headerCollapse.value = (offset / range).clamp(0.0, 1.0).toDouble();
    _headerOverscroll.value = offset < 0 ? -offset : 0;
  }

  /// Loads any previously-saved servings scale and completed steps for
  /// this specific recipe. Fully async and fire-once: if nothing was
  /// ever saved (first visit), the defaults set in [initState] stand.
  Future<void> _restoreProgress() async {
    final results = await Future.wait([
      _progressDataSource.loadServings(widget.recipe.id),
      _progressDataSource.loadCompletedSteps(widget.recipe.id),
    ]);
    if (!mounted) return;
    final int? savedServings = results[0] as int?;
    final Set<int> savedSteps = results[1] as Set<int>;
    final int totalSteps = widget.recipe.steps.length;
    // Guard against stale data from a previous build of the app where
    // this recipe might have had a different number of steps.
    final Set<int> validSteps = savedSteps.where((i) => i >= 0 && i < totalSteps).toSet();
    if (savedServings == null && validSteps.isEmpty) return;
    setState(() {
      if (savedServings != null) {
        _servings = savedServings.clamp(ServingsStepper.minServings, ServingsStepper.maxServings).toInt();
      }
      if (validSteps.isNotEmpty) {
        _completedSteps
          ..clear()
          ..addAll(validSteps);
        _cookingProgress.value = totalSteps == 0 ? 0 : _completedSteps.length / totalSteps;
        // Picking up mid-recipe implies cooking mode was already active.
        _cookingMode = true;
      }
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _headerCollapse.dispose();
    _headerOverscroll.dispose();
    _cookingProgress.dispose();
    _rippleSignal.dispose();
    _celebrationSignal.dispose();
    super.dispose();
  }

  void _toggleIngredient(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_checkedIngredients.remove(index)) _checkedIngredients.add(index);
    });
  }

  void _toggleStep(int index) {
    HapticFeedback.selectionClick();
    final int totalSteps = widget.recipe.steps.length;
    final bool wasComplete = totalSteps > 0 && _completedSteps.length == totalSteps;
    setState(() {
      final bool nowChecked = !_completedSteps.remove(index);
      if (nowChecked) {
        _completedSteps.add(index);
        _rippleSignal.value++;
      }
      _cookingProgress.value = totalSteps == 0 ? 0 : _completedSteps.length / totalSteps;
    });
    // Fire-and-forget: the UI already reflects the new state, same
    // pattern as FavoritesController.
    _progressDataSource.saveCompletedSteps(widget.recipe.id, _completedSteps);
    final bool nowComplete = totalSteps > 0 && _completedSteps.length == totalSteps;
    if (nowComplete && !wasComplete) {
      // A little "drumroll" instead of one flat impact — matches the
      // celebratory weight of the confetti it's paired with.
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 110), HapticFeedback.mediumImpact);
      Future.delayed(const Duration(milliseconds: 230), HapticFeedback.heavyImpact);
      _celebrationSignal.value++;
    }
  }

  void _startCooking() {
    HapticFeedback.mediumImpact();
    setState(() => _cookingMode = true);
    if (_checkedIngredients.isEmpty) {
      _ingredientsShakeKey.currentState?.play();
    }
  }

  void _resetCooking() {
    HapticFeedback.lightImpact();
    setState(() {
      _cookingMode = false;
      _completedSteps.clear();
      _cookingProgress.value = 0;
    });
    _progressDataSource.saveCompletedSteps(widget.recipe.id, _completedSteps);
  }

  void _handleShare() {
    HapticFeedback.lightImpact();
    final strings = AppLocalizations.of(context);
    final String languageCode = Localizations.localeOf(context).languageCode;
    Clipboard.setData(ClipboardData(text: _buildShareText(strings, languageCode)));
    setState(() => _justShared = true);
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
      if (mounted) setState(() => _justShared = false);
    });
  }

  /// A plain-text recipe summary, ready to paste into a message or note.
  /// Ingredient amounts reflect whatever servings the person currently
  /// has selected, same as what's on screen.
  String _buildShareText(AppLocalizations strings, String languageCode) {
    final Recipe recipe = widget.recipe;
    final double ratio = _servings / recipe.servings;
    final buffer = StringBuffer()
      ..writeln(recipe.title.resolve(languageCode))
      ..writeln('${recipe.prepMinutes} ${strings.minutes} · $_servings ${strings.servings}')
      ..writeln()
      ..writeln(strings.ingredients);
    for (final ingredient in recipe.ingredients) {
      buffer.writeln('• ${scaleIngredientText(ingredient.text.resolve(languageCode), ratio)}');
    }
    buffer
      ..writeln()
      ..writeln(strings.steps);
    for (int i = 0; i < recipe.steps.length; i++) {
      buffer.writeln('${i + 1}. ${recipe.steps[i].text.resolve(languageCode)}');
    }
    return buffer.toString();
  }

  void _changeServings(int value) {
    HapticFeedback.selectionClick();
    setState(() {
      _servings = value.clamp(ServingsStepper.minServings, ServingsStepper.maxServings).toInt();
    });
    _progressDataSource.saveServings(widget.recipe.id, _servings);
  }

  @override
  Widget build(BuildContext context) {
    final OverlayButtonColors overlayColors =
        OverlayButtonColors.forBackground(widget.recipe.color);
    final double topInset = MediaQuery.of(context).padding.top + 16;
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    final strings = AppLocalizations.of(context);
    final String languageCode = Localizations.localeOf(context).languageCode;
    final int totalSteps = widget.recipe.steps.length;
    final double cookingProgress =
        totalSteps == 0 ? 0 : _completedSteps.length / totalSteps;
    final List<Recipe> related = mockRecipes
        .where((r) => r.category == widget.recipe.category && r.id != widget.recipe.id)
        .take(6)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isLightColor(widget.recipe.color)
          ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: semantics.screenBackground,
        floatingActionButton: _CookingFab(
          cookingMode: _cookingMode,
          accent: widget.recipe.accentColor,
          onStart: _startCooking,
          onReset: _resetCooking,
        ),
        body: Stack(
          children: [
            Responsive.centeredMaxWidth(
              context,
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: RecipeHeaderDelegate(
                      recipe: widget.recipe,
                      overscroll: _headerOverscroll,
                      progress: _cookingProgress,
                      rippleSignal: _rippleSignal,
                      onDoubleTapFavorite: () {
                        if (!widget.favoritesController.isFavorite(widget.recipe.id)) {
                          widget.favoritesController.toggle(widget.recipe.id);
                        }
                        _dismissDoubleTapHint();
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _DetailContent(
                      recipe: widget.recipe,
                      stagger: _staggerController,
                      languageCode: languageCode,
                      checkedIngredients: _checkedIngredients,
                      completedSteps: _completedSteps,
                      cookingMode: _cookingMode,
                      rating: _rating,
                      servings: _servings,
                      relatedRecipes: related,
                      favoritesController: widget.favoritesController,
                      ingredientsShakeKey: _ingredientsShakeKey,
                      onToggleIngredient: _toggleIngredient,
                      onToggleStep: _toggleStep,
                      onRate: (value) => setState(() => _rating = value),
                      onServingsChanged: _changeServings,
                    ),
                  ),
                ],
              ),
            ),

            // Confetti fires once every step is completed in cooking mode.
            Positioned.fill(child: ConfettiOverlay(signal: _celebrationSignal)),

            // Cooking-mode progress bar, pinned just below the sticky title.
            if (_cookingMode)
              Positioned(
                top: topInset + 46,
                left: 24,
                right: 24,
                child: _ProgressBanner(
                  progress: cookingProgress,
                  completed: _completedSteps.length,
                  total: totalSteps,
                  accent: widget.recipe.accentColor,
                ),
              ),

            // One-time "double-tap the photo to favorite" hint — never
            // shown again once dismissed (or once the gesture is
            // actually performed) via [HintsLocalDataSource].
            if (_showDoubleTapHint && !_cookingMode)
              Positioned(
                top: topInset + 44,
                left: 24,
                right: 24,
                child: GestureHintBanner(
                  message: strings.doubleTapHint,
                  icon: Icons.touch_app_rounded,
                  autoDismissAfter: const Duration(seconds: 5),
                  onDismiss: _dismissDoubleTapHint,
                ),
              ),

            Positioned(
              top: topInset,
              left: 64,
              right: 64,
              child: ValueListenableBuilder<double>(
                valueListenable: _headerCollapse,
                builder: (context, t, child) {
                  final double opacity = ((t - 0.7) / 0.3).clamp(0.0, 1.0).toDouble();
                  return IgnorePointer(
                    child: Opacity(
                      opacity: opacity,
                      child: Text(
                        widget.recipe.title.resolve(languageCode),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: semantics.titleText,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            PositionedDirectional(
              top: topInset,
              start: 16,
              child: _BackButton(
                colors: overlayColors,
                onTap: () => Navigator.pop(context),
              ),
            ),

            PositionedDirectional(
              top: topInset,
              end: 16,
              child: Row(
                children: [
                  _ShareButton(colors: overlayColors, justShared: _justShared, onTap: _handleShare),
                  const SizedBox(width: 8),
                  _FavoriteButton(
                    colors: overlayColors,
                    recipeId: widget.recipe.id,
                    controller: widget.favoritesController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a section (here, the ingredients block) with a one-shot shake +
/// color flash, triggered externally via [play] on the [GlobalKey]
/// attached to it — a gentle, non-blocking nudge (cooking mode still
/// starts either way) rather than a hard validation error.
class _Shake extends StatefulWidget {
  final Widget child;
  final Color flashColor;

  const _Shake({required Key key, required this.child, required this.flashColor})
      : super(key: key);

  @override
  State<_Shake> createState() => _ShakeState();
}

class _ShakeState extends State<_Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  void play() => _controller.forward(from: 0);

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
        final double raw = _controller.value;
        final double decay = 1 - raw;
        final double dx = math.sin(raw * math.pi * 6) * decay * 10;
        final double flashOpacity = raw <= 0 || raw >= 1 ? 0.0 : (decay * 0.14);
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: widget.flashColor.withOpacity(flashOpacity),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _CookingFab extends StatelessWidget {
  final bool cookingMode;
  final Color accent;
  final VoidCallback onStart;
  final VoidCallback onReset;

  const _CookingFab({
    required this.cookingMode,
    required this.accent,
    required this.onStart,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: cookingMode
          ? FloatingActionButton.extended(
              key: const ValueKey('reset'),
              onPressed: onReset,
              backgroundColor: Colors.grey.shade700,
              icon: const Icon(Icons.replay_rounded),
              label: Text(strings.resetProgress),
            )
          : FloatingActionButton.extended(
              key: const ValueKey('start'),
              onPressed: onStart,
              backgroundColor: accent,
              icon: const Icon(Icons.restaurant_menu_rounded, color: Colors.white),
              label: Text(strings.startCooking, style: const TextStyle(color: Colors.white)),
            ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;
  final Color accent;

  const _ProgressBanner({
    required this.progress,
    required this.completed,
    required this.total,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$completed/$total ${strings.cookingInProgress}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final OverlayButtonColors colors;
  final VoidCallback onTap;
  const _BackButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: strings.back,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(shape: BoxShape.circle, color: colors.badge),
          child: Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back, color: colors.icon, size: 20),
        ),
      ),
    );
  }
}

/// The share button. On tap, the share icon "launches" — flying up and
/// to the reading-end side while shrinking and fading — right before
/// swapping to the checkmark, instead of the icon just flatly swapping
/// in place.
class _ShareButton extends StatefulWidget {
  final OverlayButtonColors colors;
  final bool justShared;
  final VoidCallback onTap;

  const _ShareButton({required this.colors, required this.justShared, required this.onTap});

  @override
  State<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<_ShareButton> with SingleTickerProviderStateMixin {
  late final AnimationController _flight = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void dispose() {
    _flight.dispose();
    super.dispose();
  }

  void _handleTap() {
    _flight.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final double flightDirection = isRtl ? -1 : 1;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: strings.share,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(shape: BoxShape.circle, color: widget.colors.badge),
          child: ClipOval(
            child: AnimatedBuilder(
              animation: _flight,
              builder: (context, child) {
                final double raw = _flight.value;
                final bool flying = raw > 0.0 && raw < 1.0;
                final double t = Curves.easeIn.transform(raw);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (flying)
                      Opacity(
                        opacity: (1 - t).clamp(0.0, 1.0).toDouble(),
                        child: Transform.translate(
                          offset: Offset(t * 16 * flightDirection, -t * 16),
                          child: Transform.scale(
                            scale: 1 - t * 0.5,
                            child: Icon(Icons.ios_share_rounded, color: widget.colors.icon, size: 19),
                          ),
                        ),
                      ),
                    if (!flying)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: widget.justShared
                            ? const Icon(
                                Icons.check_rounded,
                                key: ValueKey(true),
                                color: Colors.greenAccent,
                                size: 19,
                              )
                            : Icon(
                                Icons.ios_share_rounded,
                                key: const ValueKey(false),
                                color: widget.colors.icon,
                                size: 19,
                              ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The favorite (heart) button. On top of the existing bounce, toggling
/// *on* now also bursts a small ring of tiny hearts outward once — a
/// deliberately understated version of the classic "like button" pop,
/// self-contained (no new package) via a handful of positioned icons
/// animated by one [AnimationController].
class _FavoriteButton extends StatefulWidget {
  final OverlayButtonColors colors;
  final String recipeId;
  final FavoritesController controller;

  const _FavoriteButton({
    required this.colors,
    required this.recipeId,
    required this.controller,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );
  late bool _wasFavorite = widget.controller.isFavorite(widget.recipeId);

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  void _syncBurst() {
    final bool isFavorite = widget.controller.isFavorite(widget.recipeId);
    if (isFavorite && !_wasFavorite) {
      _burst.forward(from: 0);
    }
    _wasFavorite = isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        _syncBurst();
        final bool isFavorite = widget.controller.isFavorite(widget.recipeId);
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.controller.toggle(widget.recipeId);
          },
          behavior: HitTestBehavior.opaque,
          child: Tooltip(
            message: isFavorite ? strings.unfavoriteTooltip : strings.favoriteTooltip,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: widget.colors.badge),
                    child: AnimatedScale(
                      scale: isFavorite ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.elasticOut,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : widget.colors.icon,
                        size: 20,
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _burst,
                      builder: (context, __) {
                        final double raw = _burst.value;
                        if (raw <= 0.0 || raw >= 1.0) return const SizedBox.shrink();
                        final double t = Curves.easeOut.transform(raw);
                        final double dist = t * 24;
                        final double opacity = (1 - t).clamp(0.0, 1.0).toDouble();
                        return Stack(
                          alignment: Alignment.center,
                          children: List.generate(6, (i) {
                            final double angle = (i / 6) * 2 * math.pi;
                            return Transform.translate(
                              offset: Offset(math.cos(angle) * dist, math.sin(angle) * dist),
                              child: Opacity(
                                opacity: opacity,
                                child: Icon(Icons.favorite, size: 10, color: Colors.redAccent.withOpacity(0.9)),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PrepBadges extends StatelessWidget {
  final Recipe recipe;
  const _PrepBadges({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    return Row(
      children: [
        _Badge(
          icon: Icons.schedule_rounded,
          label: '${recipe.prepMinutes} ${strings.minutes}',
          color: semantics.bodyText,
        ),
        const SizedBox(width: 16),
        _Badge(
          icon: Icons.people_alt_rounded,
          label: '${recipe.servings} ${strings.servings}',
          color: semantics.bodyText,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRate;
  final Color accent;

  const _StarRating({required this.rating, required this.onRate, required this.accent});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      label: strings.rateRecipe,
      value: '$rating/5',
      child: Row(
        children: List.generate(5, (index) {
          final int starValue = index + 1;
          final bool filled = starValue <= rating;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onRate(starValue);
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: filled ? 1.15 : 1.0),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: filled ? Colors.amber : accent.withOpacity(0.4),
                  size: 26,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// The scrollable text content below the header. Every section reveals
/// itself with [StaggeredFadeSlide] (or, for the sections with their own
/// internal per-item stagger — nutrition rings, equipment chips, related
/// recipes — a [CurvedAnimation] slice of the same timeline) across
/// staggered slices of the same 0..1 [stagger] timeline, so the whole
/// entrance reads as one connected choreography rather than separate,
/// disjointed animations.
class _DetailContent extends StatelessWidget {
  final Recipe recipe;
  final Animation<double> stagger;
  final String languageCode;
  final Set<int> checkedIngredients;
  final Set<int> completedSteps;
  final bool cookingMode;
  final int rating;
  final int servings;
  final List<Recipe> relatedRecipes;
  final FavoritesController favoritesController;
  final GlobalKey<_ShakeState> ingredientsShakeKey;
  final ValueChanged<int> onToggleIngredient;
  final ValueChanged<int> onToggleStep;
  final ValueChanged<int> onRate;
  final ValueChanged<int> onServingsChanged;

  const _DetailContent({
    required this.recipe,
    required this.stagger,
    required this.languageCode,
    required this.checkedIngredients,
    required this.completedSteps,
    required this.cookingMode,
    required this.rating,
    required this.servings,
    required this.relatedRecipes,
    required this.favoritesController,
    required this.ingredientsShakeKey,
    required this.onToggleIngredient,
    required this.onToggleStep,
    required this.onRate,
    required this.onServingsChanged,
  });

  Animation<double> _slice(double start, double end) {
    return CurvedAnimation(
      parent: stagger,
      curve: Interval(
        start.clamp(0.0, 1.0).toDouble(),
        end.clamp(0.0, 1.0).toDouble(),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  /// The first step (in order) not yet in [completed] — "where you are"
  /// in cooking mode. Returns -1 if every step is done (nothing pulses).
  static int _firstIncompleteIndex(int total, Set<int> completed) {
    for (int i = 0; i < total; i++) {
      if (!completed.contains(i)) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantics = Theme.of(context).extension<AppSemanticColors>()!;
    final Color accent = recipe.accentColor;
    final ingredients = recipe.ingredients;
    final steps = recipe.steps;
    final double ratio = servings / recipe.servings;

    const double titleStart = 0.00, titleEnd = 0.22;
    const double badgesStart = 0.02, badgesEnd = 0.24;
    const double descStart = 0.05, descEnd = 0.28;
    const double ratingStart = 0.08, ratingEnd = 0.30;
    const double nutritionStart = 0.10, nutritionEnd = 0.40;
    const double equipmentStart = 0.14, equipmentEnd = 0.42;
    const double tipStart = 0.18, tipEnd = 0.44;
    const double ingHeaderStart = 0.22, ingHeaderEnd = 0.48;
    const double ingredientsBaseStart = 0.30;
    const double ingredientStep = 0.03;
    const double stepsHeaderStart = 0.62, stepsHeaderEnd = 0.84;
    const double stepsBaseStart = 0.66;
    const double stepStep = 0.035;
    const double relatedStart = 0.82, relatedEnd = 1.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaggeredFadeSlide(
            controller: stagger,
            start: titleStart,
            end: titleEnd,
            child: Text(
              recipe.title.resolve(languageCode),
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: semantics.titleText),
            ),
          ),
          const SizedBox(height: 10),
          StaggeredFadeSlide(
            controller: stagger,
            start: badgesStart,
            end: badgesEnd,
            child: _PrepBadges(recipe: recipe),
          ),
          const SizedBox(height: 14),
          StaggeredFadeSlide(
            controller: stagger,
            start: descStart,
            end: descEnd,
            child: Text(
              recipe.fullDescription.resolve(languageCode),
              style: TextStyle(fontSize: 15, height: 1.45, color: semantics.bodyText),
            ),
          ),
          const SizedBox(height: 16),
          StaggeredFadeSlide(
            controller: stagger,
            start: ratingStart,
            end: ratingEnd,
            child: _StarRating(rating: rating, onRate: onRate, accent: accent),
          ),
          const SizedBox(height: 22),

          // --- Nutrition facts ------------------------------------
          Text(
            strings.nutritionPerServing,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: semantics.sectionHeader,
            ),
          ),
          const SizedBox(height: 14),
          NutritionFacts(
            nutrition: recipe.nutritionEstimate,
            accent: accent,
            reveal: _slice(nutritionStart, nutritionEnd),
          ),
          const SizedBox(height: 24),

          // --- Equipment needed ------------------------------------
          Text(
            strings.equipmentNeeded,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: semantics.sectionHeader,
            ),
          ),
          const SizedBox(height: 12),
          EquipmentChips(
            tools: recipe.suggestedEquipment,
            accent: accent,
            reveal: _slice(equipmentStart, equipmentEnd),
          ),
          const SizedBox(height: 22),

          // --- Chef's tip -------------------------------------------
          StaggeredFadeSlide(
            controller: stagger,
            start: tipStart,
            end: tipEnd,
            child: ExpandableTipCard(
              tip: recipe.chefTip,
              languageCode: languageCode,
              accent: accent,
            ),
          ),
          const SizedBox(height: 22),

          _Shake(
            key: ingredientsShakeKey,
            flashColor: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StaggeredFadeSlide(
                  controller: stagger,
                  start: ingHeaderStart,
                  end: ingHeaderEnd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.ingredients,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color: semantics.sectionHeader,
                                  ),
                                ),
                                ExpandingUnderline(
                                  controller: stagger,
                                  start: ingHeaderStart,
                                  end: ingHeaderEnd + 0.1,
                                  color: accent,
                                ),
                              ],
                            ),
                          ),
                          AnimatedCountLabel(
                            count: ingredients.length - checkedIngredients.length,
                            color: accent,
                            labelBuilder: (n) => n == 0
                                ? strings.allIngredientsReady
                                : '$n ${strings.ingredientsLeft}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ServingsStepper(
                        servings: servings,
                        baseServings: recipe.servings,
                        accent: accent,
                        onChanged: onServingsChanged,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                for (int i = 0; i < ingredients.length; i++)
                  StaggeredFadeSlide(
                    controller: stagger,
                    start: (ingredientsBaseStart + i * ingredientStep).clamp(0.0, 0.9).toDouble(),
                    end: (ingredientsBaseStart + i * ingredientStep + 0.35).clamp(0.0, 1.0).toDouble(),
                    child: IngredientTile(
                      ingredient: Ingredient(
                        LocalizedText(
                          en: scaleIngredientText(ingredients[i].text.en, ratio),
                          ar: scaleIngredientText(ingredients[i].text.ar, ratio),
                        ),
                      ),
                      accentColor: accent,
                      languageCode: languageCode,
                      checked: checkedIngredients.contains(i),
                      onToggle: () => onToggleIngredient(i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          StaggeredFadeSlide(
            controller: stagger,
            start: stepsHeaderStart,
            end: stepsHeaderEnd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.steps,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: semantics.sectionHeader,
                  ),
                ),
                ExpandingUnderline(
                  controller: stagger,
                  start: stepsHeaderStart,
                  end: (stepsHeaderEnd + 0.1).clamp(0.0, 1.0).toDouble(),
                  color: accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (int i = 0; i < steps.length; i++)
            StaggeredFadeSlide(
              controller: stagger,
              start: (stepsBaseStart + i * stepStep).clamp(0.0, 0.9).toDouble(),
              end: (stepsBaseStart + i * stepStep + 0.35).clamp(0.0, 1.0).toDouble(),
              child: StepTile(
                step: steps[i],
                accentColor: accent,
                languageCode: languageCode,
                completed: completedSteps.contains(i),
                interactive: cookingMode,
                isLast: i == steps.length - 1,
                isCurrent: cookingMode && i == _firstIncompleteIndex(steps.length, completedSteps),
                onToggle: () => onToggleStep(i),
              ),
            ),

          if (relatedRecipes.isNotEmpty) ...[
            const SizedBox(height: 30),
            RelatedRecipesCarousel(
              recipes: relatedRecipes,
              languageCode: languageCode,
              reveal: _slice(relatedStart, relatedEnd),
              favoritesController: favoritesController,
            ),
          ],
        ],
      ),
    );
  }
}
