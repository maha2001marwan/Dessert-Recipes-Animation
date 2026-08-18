import 'package:shared_preferences/shared_preferences.dart';

/// Tracks small one-time UI states that should only ever happen once
/// per install — specifically, whether the person has already been
/// shown the long-press (list) and double-tap (detail header) gesture
/// hints. Once shown, gone for good; no snooze/remind-later logic,
/// since re-nagging about a gesture someone has already discovered (or
/// dismissed on purpose) is worse than just not mentioning it again.
class HintsLocalDataSource {
  static const String _longPressHintKey = 'seen_long_press_hint';
  static const String _doubleTapHintKey = 'seen_double_tap_hint';

  Future<bool> hasSeenLongPressHint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_longPressHintKey) ?? false;
  }

  Future<void> markLongPressHintSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_longPressHintKey, true);
  }

  Future<bool> hasSeenDoubleTapHint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_doubleTapHintKey) ?? false;
  }

  Future<void> markDoubleTapHintSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_doubleTapHintKey, true);
  }
}
