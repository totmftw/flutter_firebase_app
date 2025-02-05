import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeState {
  final int themeIndex;
  final bool isDark;

  ThemeState({this.themeIndex = 0, this.isDark = false});

  ThemeState copyWith({int? themeIndex, bool? isDark}) {
    return ThemeState(
      themeIndex: themeIndex ?? this.themeIndex,
      isDark: isDark ?? this.isDark,
    );
  }

  ThemeData get theme => ThemeService.getTheme(themeIndex, isDark);
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeIndexKey = 'theme_index';
  static const String _isDarkKey = 'is_dark';
  
  ThemeNotifier() : super(ThemeState()) {
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeIndexKey) ?? 0;
    final isDark = prefs.getBool(_isDarkKey) ?? false;
    state = ThemeState(themeIndex: themeIndex, isDark: isDark);
  }

  Future<void> _saveThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeIndexKey, state.themeIndex);
    await prefs.setBool(_isDarkKey, state.isDark);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDark: !state.isDark);
    _saveThemePreferences();
  }

  void setThemeIndex(int index) {
    if (index >= 0 && index < ThemeService.themes.length) {
      state = state.copyWith(themeIndex: index);
      _saveThemePreferences();
    }
  }
}
