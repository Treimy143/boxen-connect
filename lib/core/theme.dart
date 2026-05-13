import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: C.red,
      primaryContainer: C.redDark,
      secondary: C.blue,
      secondaryContainer: C.blueDark,
      surface: C.surface,
      error: C.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: C.text,
      onError: Colors.white,
      outline: C.border,
    ),
    scaffoldBackgroundColor: C.bg,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: C.surface,
      foregroundColor: C.text,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color: C.text,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      color: C.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: C.border, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.red, width: 2),
      ),
      labelStyle: const TextStyle(color: C.textMuted),
      hintStyle: const TextStyle(color: C.textMuted),
      prefixIconColor: C.textMuted,
    ),

    // Buttons
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.red,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.red,
        side: const BorderSide(color: C.red),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: C.red),
    ),

    // Navigation
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.surface,
      indicatorColor: C.red.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: C.red);
        }
        return const IconThemeData(color: C.textMuted);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: C.red, fontSize: 12, fontWeight: FontWeight.w600);
        }
        return const TextStyle(color: C.textMuted, fontSize: 12);
      }),
    ),

    // Divider
    dividerTheme: const DividerThemeData(color: C.border, thickness: 0.5, space: 1),

    // ListTile
    listTileTheme: const ListTileThemeData(
      textColor: C.text,
      iconColor: C.textMuted,
      tileColor: Colors.transparent,
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.surface,
      contentTextStyle: const TextStyle(color: C.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    // Tab Bar
    tabBarTheme: const TabBarThemeData(
      labelColor: C.red,
      unselectedLabelColor: C.textMuted,
      indicatorColor: C.red,
      dividerColor: C.border,
    ),

    // Icon
    iconTheme: const IconThemeData(color: C.textMuted),

    // Progress
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: C.red),

    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: C.red,
      foregroundColor: Colors.white,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: C.surface2,
      labelStyle: const TextStyle(color: C.text, fontSize: 12),
      side: const BorderSide(color: C.border, width: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Text
    textTheme: const TextTheme(
      headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: C.text, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: C.text),
      titleLarge:     TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: C.text),
      titleMedium:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.text),
      bodyLarge:      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: C.text, height: 1.5),
      bodyMedium:     TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: C.text),
      labelLarge:     TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: C.textMuted, letterSpacing: 1.0),
      labelMedium:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: C.textMuted),
    ),
  );
}
