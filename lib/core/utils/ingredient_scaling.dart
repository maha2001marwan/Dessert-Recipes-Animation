/// Scales the first number found in an ingredient string by [ratio] and
/// re-renders it in place — e.g. `"2 cups flour"` at ratio 1.5 becomes
/// `"3 cups flour"`, and `"1.5 tsp vanilla"` at ratio 2 becomes `"3 tsp
/// vanilla"`.
///
/// Deliberately simple: it only touches the *first* number in the
/// string (ingredient text here is always "amount, then name", never
/// two numbers), rounds to at most one decimal place, and drops a
/// trailing ".0" so whole numbers stay clean. If no number is found
/// (e.g. "a pinch of salt"), the text is returned unchanged — scaling a
/// pinch doesn't mean anything anyway.
String scaleIngredientText(String text, double ratio) {
  if ((ratio - 1.0).abs() < 0.001) return text;

  final RegExp numberPattern = RegExp(r'\d+(?:[.,]\d+)?');
  final Match? match = numberPattern.firstMatch(text);
  if (match == null) return text;

  final String raw = match.group(0)!.replaceAll(',', '.');
  final double? original = double.tryParse(raw);
  if (original == null) return text;

  final double scaled = original * ratio;
  final String formatted = _formatAmount(scaled);

  return text.replaceRange(match.start, match.end, formatted);
}

String _formatAmount(double value) {
  final double rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return rounded.toInt().toString();
  }
  return rounded.toStringAsFixed(1);
}
