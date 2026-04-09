import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  static final AppTheme _instance = AppTheme._internal();
  factory AppTheme() => _instance;
  AppTheme._internal();

  Color _appAccentColor = const Color(0xFF6366F1);
  Color get appAccentColor => _appAccentColor;

  void updateAccentColor(Color newColor) {
    _appAccentColor = newColor;
    notifyListeners(); // This makes the whole app change color instantly!
  }

  // LIGHT PALETTE
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color cardLight = Colors.white;
  static const Color textLight = Color(0xFF1E293B);

  // DARK PALETTE
  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textDark = Color(0xFFF1F5F9);

  static ThemeData _base(Brightness brightness, Color seed) {
    bool isDark = brightness == Brightness.dark;

    // This is the magic part: Generate the color scheme first
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    // Use the generated 'surfaceContainerLowest' for the deep background feel
    // or 'surface' for a slightly lighter tinted background.
    final Color dynamicBg =
        isDark ? colorScheme.surfaceContainerLowest : bgLight;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(
        primary: seed,
        surface: isDark ? colorScheme.surfaceContainerLow : bgLight,
      ),
      scaffoldBackgroundColor: dynamicBg,

      // Card Theme: Tinted to match the background
      cardTheme: CardThemeData(
        color: isDark ? colorScheme.surfaceContainer : cardLight,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),

      // Input Decoration: Keep it consistent
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? textDark : textLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ThemeData get lightTheme => _base(Brightness.light, _appAccentColor);
  ThemeData get darkTheme => _base(Brightness.dark, _appAccentColor);
}
