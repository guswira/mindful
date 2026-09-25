import 'package:flutter/material.dart';

import 'glass_theme.dart';

/// App-wide Material 3 light and dark themes.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  );

  static ThemeData get dark {
    final glassTheme = GlassTheme.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: glassTheme.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
      extensions: [glassTheme],
    );
  }
}
