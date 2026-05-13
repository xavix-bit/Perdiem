import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==================== Design Tokens (Stitch) ====================

class AppColors {
  // All fields are mutable for dynamic theme switching
  static Color background = const Color(0xFFFFFDF5);
  static Color surface = const Color(0xFFfef7ff);
  static Color surfaceContainer = const Color(0xFFf3ebf8);
  static Color surfaceContainerLow = const Color(0xFFf8f1fe);
  static Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  static Color surfaceContainerHigh = const Color(0xFFede5f3);
  static Color surfaceContainerHighest = const Color(0xFFe7e0ed);

  // Primary
  static Color primary = const Color(0xFF6b38d4);
  static Color primaryContainer = const Color(0xFF8455ef);
  static Color onPrimary = const Color(0xFFFFFFFF);
  static Color onPrimaryContainer = const Color(0xFFfffbff);

  // Secondary
  static Color secondary = const Color(0xFFF472B6);
  static Color secondaryContainer = const Color(0xFFfc79bd);
  static Color onSecondary = const Color(0xFFFFFFFF);
  static Color onSecondaryContainer = const Color(0xFF76014e);

  // Tertiary
  static Color tertiary = const Color(0xFFFBBF24);
  static Color tertiaryContainer = const Color(0xFFa76500);
  static Color onTertiary = const Color(0xFFFFFFFF);
  static Color onTertiaryFixedVariant = const Color(0xFF673d00);

  // Quaternary
  static Color quaternary = const Color(0xFF34D399);

  // Text
  static Color foreground = const Color(0xFF1E293B);
  static Color onBackground = const Color(0xFF1d1a23);
  static Color onSurface = const Color(0xFF1d1a23);
  static Color onSurfaceVariant = const Color(0xFF494454);
  static Color mutedForeground = const Color(0xFF64748B);

  // Border & Outline
  static Color border = const Color(0xFFE2E8F0);
  static Color outline = const Color(0xFF7b7486);
  static Color outlineVariant = const Color(0xFFcbc3d7);
  static Color inputBorder = const Color(0xFFCBD5E1);
  static Color surfaceVariant = const Color(0xFFe7e0ed);
  static Color muted = const Color(0xFFF1F5F9);

  // Error
  static Color error = const Color(0xFFba1a1a);
  static Color errorContainer = const Color(0xFFffdad6);
  static Color onError = const Color(0xFFFFFFFF);
  static Color onErrorContainer = const Color(0xFF93000a);

  // Accent
  static Color accent = const Color(0xFF8B5CF6);
  static Color accentForeground = const Color(0xFFFFFFFF);
  static Color ring = const Color(0xFF8B5CF6);

  // Card
  static Color card = const Color(0xFFFFFFFF);

}

// ==================== Theme Data ====================

TextTheme _buildTextTheme() {
  return GoogleFonts.plusJakartaSansTextTheme(
    TextTheme(
      displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, height: 1.2, color: AppColors.onSurface, fontFamily: 'Outfit'),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.onSurface, fontFamily: 'Outfit'),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.onSurface, fontFamily: 'Outfit'),
      headlineLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, height: 1.2, color: AppColors.onSurface, fontFamily: 'Outfit'),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.onSurface, fontFamily: 'Outfit'),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.onSurface, fontFamily: 'Outfit'),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5, color: AppColors.onSurface),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.onSurfaceVariant),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.mutedForeground),
      labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.05, height: 1.2, color: AppColors.onSurface),
    ),
  );
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondary: AppColors.onSecondary,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    surface: AppColors.surface,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    error: AppColors.error,
    errorContainer: AppColors.errorContainer,
    onPrimary: AppColors.onPrimary,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    onError: AppColors.onError,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
  ),
  textTheme: _buildTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 31,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.onSurface,
    ),
    iconTheme: IconThemeData(color: AppColors.onSurface),
  ),
  cardTheme: CardThemeData(
    color: AppColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: AppColors.outlineVariant, width: 2),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceContainerLowest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.inputBorder, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.inputBorder, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
    hintStyle: TextStyle(color: AppColors.mutedForeground),
  ),
  dividerTheme: DividerThemeData(
    color: AppColors.outlineVariant,
    thickness: 1,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.outlineVariant;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary.withValues(alpha: 0.3);
      }
      return AppColors.surfaceContainerHigh;
    }),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceContainerLowest,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.mutedForeground,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);

// ==================== Theme Color Provider ====================

class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  static const defaults = ThemeColors(
    primary: Color(0xFF6b38d4),
    secondary: Color(0xFFF472B6),
    tertiary: Color(0xFFFBBF24),
  );
}

final themeColorProvider = StateNotifierProvider<ThemeColorNotifier, ThemeColors>((ref) {
  return ThemeColorNotifier();
});

class ThemeColorNotifier extends StateNotifier<ThemeColors> {
  ThemeColorNotifier() : super(ThemeColors.defaults) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final primary = prefs.getInt('theme_primary');
    final secondary = prefs.getInt('theme_secondary');
    final tertiary = prefs.getInt('theme_tertiary');
    if (primary != null) {
      state = ThemeColors(
        primary: Color(primary),
        secondary: Color(secondary ?? ThemeColors.defaults.secondary.toARGB32()),
        tertiary: Color(tertiary ?? ThemeColors.defaults.tertiary.toARGB32()),
      );
      AppColors.primary = state.primary;
      AppColors.secondary = state.secondary;
      AppColors.tertiary = state.tertiary;
    }
  }

  Future<void> setThemeColors({
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) async {
    state = ThemeColors(primary: primary, secondary: secondary, tertiary: tertiary);
    AppColors.primary = primary;
    AppColors.secondary = secondary;
    AppColors.tertiary = tertiary;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_primary', primary.toARGB32());
    await prefs.setInt('theme_secondary', secondary.toARGB32());
    await prefs.setInt('theme_tertiary', tertiary.toARGB32());
  }
}
