import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => darkTheme;
  static ThemeData get darkTheme => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    const violet = Color(0xff7c6cff);
    const cyan = Color(0xff22d3ee);
    const pink = Color(0xfff472b6);

    // Darker palette
    const darkBg = Color(0xff05050d); // almost black navy
    const darkSurface = Color(0xff0e0e1d);
    const darkSurfaceHigh = Color(0xff181829);
    const lightBg = Colors.white; // pure white main background
    const lightSurface = Color(
      0xfff7f6fc,
    ); // very light, so cards still stand out
    const lightSurfaceHigh = Color(0xffeeecf8);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: violet,
          brightness: brightness,
        ).copyWith(
          primary: violet,
          onPrimary: Colors.white,
          secondary: cyan,
          tertiary: pink,
          surface: isDark ? darkSurface : lightSurface,
          onSurface: isDark ? const Color(0xffeeecff) : const Color(0xff14132a),
          onSurfaceVariant: isDark
              ? const Color(0xffa9a6c8)
              : const Color(0xff4a4868),
          surfaceContainerHighest: isDark ? darkSurfaceHigh : lightSurfaceHigh,
          outlineVariant: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xffbfbbd8),
        );

    final baseTextTheme = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final textTheme = baseTextTheme
        .apply(fontFamily: GoogleFonts.inter().fontFamily)
        .copyWith(
          displayLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          displayMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? darkBg : lightBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: colorScheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 54),
          shape: const StadiumBorder(),
          elevation: 2,
          shadowColor: violet.withValues(alpha: 0.35),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
          foregroundColor: const Color(0xffeeecff),
          backgroundColor: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 54),
          shape: const StadiumBorder(),
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        hintStyle: const TextStyle(color: Color(0xffa9a6c8)),
        labelStyle: const TextStyle(color: Color(0xffa9a6c8)),
        floatingLabelStyle: const TextStyle(color: violet),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: violet, width: 1.5),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        backgroundColor: isDark
            ? const Color(0xff1c1c30)
            : const Color(0xff1b1a30),
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
      ),
    );
  }
}
