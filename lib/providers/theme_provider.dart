import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

class ThemeState {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeMode mode;

  ThemeState({
    required this.lightTheme,
    required this.darkTheme,
    required this.mode,
  });

  bool get isDark => mode == ThemeMode.dark;

  ThemeState copyWith({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    ThemeMode? mode,
  }) {
    return ThemeState(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      mode: mode ?? this.mode,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeIndexKey = 'theme_index';
  static const String _isDarkKey = 'is_dark';
  
  ThemeNotifier() : super(ThemeState(
    lightTheme: ThemeData.light().copyWith(
      primaryColor: Colors.blue,
    ),
    darkTheme: ThemeData.dark().copyWith(
      primaryColor: Colors.indigo,
    ),
    mode: ThemeMode.system,
  )) {
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeIndexKey) ?? 0;
    final isDark = prefs.getBool(_isDarkKey) ?? false;
    List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.indigo,
    ];
    state = ThemeState(
      lightTheme: ThemeData.light().copyWith(
        primaryColor: colors[themeIndex],
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: colors[themeIndex],
      ),
      mode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> _saveThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeIndexKey, ThemeService.themes.indexOf(state.lightTheme));
    await prefs.setBool(_isDarkKey, state.mode == ThemeMode.dark);
  }

  void toggleDarkMode() {
    state = state.copyWith(
      mode: state.mode == ThemeMode.system
          ? ThemeMode.dark
          : state.mode == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.system,
    );
    _saveThemePreferences();
  }

  void setThemeIndex(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.indigo,
    ];
    state = state.copyWith(
      lightTheme: ThemeData.light().copyWith(
        primaryColor: colors[index],
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: colors[index],
      ),
    );
    _saveThemePreferences();
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
