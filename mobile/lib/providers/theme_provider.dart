import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

final themeColorProvider = StateProvider<Color>(
  (ref) => Colors.deepPurpleAccent,
);

const String themeKey = 'is_dark_mode';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(_prefs.getBool(themeKey) ?? false);

  void toggleTheme() {
    state = !state;
    _prefs.setBool(themeKey, state);
  }
}
