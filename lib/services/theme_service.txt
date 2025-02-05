import 'package:flutter/material.dart';

class ThemeService {
  static final List<ThemeData> themes = [
    // Light Blue Theme
    ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Colors.blue[700]!,
        secondary: Colors.teal,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    
    // Purple Theme
    ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Colors.purple[700]!,
        secondary: Colors.amber,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    
    // Green Theme
    ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Colors.green[700]!,
        secondary: Colors.orange,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    
    // Deep Orange Theme
    ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Colors.deepOrange[700]!,
        secondary: Colors.lightBlue,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    
    // Indigo Theme
    ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Colors.indigo[700]!,
        secondary: Colors.pink,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  ];

  static final List<ThemeData> darkThemes = themes.map((theme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: theme.colorScheme.copyWith(
        brightness: Brightness.dark,
        surface: Colors.grey[900]!,
      ),
      cardTheme: theme.cardTheme,
    );
  }).toList();

  static ThemeData getTheme(int index, bool isDark) {
    index = index.clamp(0, themes.length - 1);
    return isDark ? darkThemes[index] : themes[index];
  }
}
