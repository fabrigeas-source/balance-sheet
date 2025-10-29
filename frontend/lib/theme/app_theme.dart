import 'package:flutter/material.dart';

class AppTheme {
  // Spacing constants (reduced for tighter layout)
  static const double spacingSmall = 4.0;
  static const double spacing = 6.0;
  static const double spacingLarge = 10.0;
  static const double spacingXL = 12.0;

  static ThemeData themeData({Color? seed}) {
    final seedColor = seed ?? Colors.teal;
    final scheme = ColorScheme.fromSeed(seedColor: seedColor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: scheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacingSmall),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacingSmall),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: spacingSmall)),
      ),
      listTileTheme: ListTileThemeData(horizontalTitleGap: spacing),
    );
  }
}
