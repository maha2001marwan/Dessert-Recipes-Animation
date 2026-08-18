/// A piece of *data* (not UI chrome) available in both supported
/// languages. Recipe titles, descriptions, ingredients and steps all use
/// this instead of a single hard-coded English string.
class LocalizedText {
  final String en;
  final String ar;
  const LocalizedText({required this.en, required this.ar});

  String resolve(String languageCode) => languageCode == 'ar' ? ar : en;
}
