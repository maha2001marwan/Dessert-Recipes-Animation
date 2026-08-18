import 'package:flutter/material.dart';

/// A minimal controller for the app's current [Locale]. Only English and
/// Arabic are supported, so `toggle()` simply flips between the two.
class LocaleController extends ValueNotifier<Locale> {
  LocaleController() : super(const Locale('en'));

  bool get isArabic => value.languageCode == 'ar';

  void toggle() {
    value = isArabic ? const Locale('en') : const Locale('ar');
  }
}
