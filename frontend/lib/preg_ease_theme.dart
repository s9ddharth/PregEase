import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PregEase's shared visual system.
///
/// Keep these tokens as the single source of truth for shared colors,
/// spacing, corner radii, typography, and Material component defaults.
class PregEaseColors {
  static const Color primary = Color(0xFFE9655B);
  static const Color primaryDark = Color(0xFFC94F49);

  static const Color background = Color(0xFFFFFAF7);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color text = Color(0xFF29243A);
  static const Color mutedText = Color(0xFF746D7A);

  // Soft, supportive accent surfaces for pregnancy content cards.
  static const Color lavender = Color(0xFFF0ECFF);
  static const Color lavenderBorder = Color(0xFFDED5FF);

  static const Color pink = Color(0xFFFFEEE9);
  static const Color pinkBorder = Color(0xFFF7D5CD);

  static const Color peach = Color(0xFFFFF0E2);
  static const Color peachBorder = Color(0xFFF2DCC5);

  static const Color mint = Color(0xFFE6F7ED);
  static const Color mintBorder = Color(0xFFCFE9D9);

  static const Color blue = Color(0xFFEAF4FF);
  static const Color blueBorder = Color(0xFFD5E6FA);

  static const Color border = Color(0xFFECE4E0);
  static const Color error = Color(0xFFC74747);
}

class PregEaseSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class PregEaseRadius {
  static const double sm = 10;
  static const double md = 18;
  static const double lg = 26;
}

class PregEaseTheme {
  PregEaseTheme._();

  static ThemeData get light {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    TextStyle textStyle({
      required double size,
      required FontWeight weight,
      Color color = PregEaseColors.text,
      double height = 1.25,
    }) {
      return GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
    }

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: PregEaseColors.background,
      visualDensity: VisualDensity.standard,
      colorScheme: const ColorScheme.light(
        primary: PregEaseColors.primary,
        onPrimary: Colors.white,
        primaryContainer: PregEaseColors.pink,
        onPrimaryContainer: PregEaseColors.text,
        secondary: PregEaseColors.primaryDark,
        onSecondary: Colors.white,
        secondaryContainer: PregEaseColors.mint,
        onSecondaryContainer: PregEaseColors.text,
        surface: PregEaseColors.surface,
        onSurface: PregEaseColors.text,
        error: PregEaseColors.error,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: textStyle(size: 32, weight: FontWeight.w800, height: 1.12),
        displayMedium: textStyle(size: 28, weight: FontWeight.w800, height: 1.15),
        headlineLarge: textStyle(size: 24, weight: FontWeight.w800),
        headlineMedium: textStyle(size: 21, weight: FontWeight.w800),
        titleLarge: textStyle(size: 18, weight: FontWeight.w800),
        titleMedium: textStyle(size: 15, weight: FontWeight.w700),
        titleSmall: textStyle(size: 13, weight: FontWeight.w700),
        bodyLarge: textStyle(size: 15, weight: FontWeight.w400, height: 1.5),
        bodyMedium: textStyle(
          size: 13,
          weight: FontWeight.w400,
          color: PregEaseColors.mutedText,
          height: 1.45,
        ),
        bodySmall: textStyle(
          size: 11,
          weight: FontWeight.w400,
          color: PregEaseColors.mutedText,
          height: 1.4,
        ),
        labelLarge: textStyle(size: 14, weight: FontWeight.w800),
        labelMedium: textStyle(size: 12, weight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: PregEaseColors.background,
        foregroundColor: PregEaseColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textStyle(size: 19, weight: FontWeight.w800),
        iconTheme: const IconThemeData(color: PregEaseColors.text),
      ),
      cardTheme: CardThemeData(
        color: PregEaseColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PregEaseRadius.lg),
          side: const BorderSide(color: PregEaseColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PregEaseColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PregEaseSpacing.md,
          vertical: 15,
        ),
        hintStyle: textStyle(
          size: 13,
          weight: FontWeight.w400,
          color: PregEaseColors.mutedText,
        ),
        labelStyle: textStyle(
          size: 13,
          weight: FontWeight.w600,
          color: PregEaseColors.mutedText,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PregEaseRadius.md),
          borderSide: const BorderSide(color: PregEaseColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PregEaseRadius.md),
          borderSide: const BorderSide(color: PregEaseColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PregEaseRadius.md),
          borderSide: const BorderSide(
            color: PregEaseColors.primary,
            width: 1.7,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PregEaseRadius.md),
          borderSide: const BorderSide(color: PregEaseColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PregEaseRadius.md),
          borderSide: const BorderSide(
            color: PregEaseColors.error,
            width: 1.7,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PregEaseColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: PregEaseColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(
            horizontal: PregEaseSpacing.lg,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PregEaseRadius.md),
          ),
          textStyle: textStyle(size: 14, weight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PregEaseColors.primaryDark,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: PregEaseSpacing.lg,
            vertical: 13,
          ),
          side: const BorderSide(color: PregEaseColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PregEaseRadius.md),
          ),
          textStyle: textStyle(size: 14, weight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PregEaseColors.primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PregEaseRadius.sm),
          ),
          textStyle: textStyle(size: 13, weight: FontWeight.w800),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PregEaseColors.pink,
        selectedColor: PregEaseColors.mint,
        disabledColor: PregEaseColors.border,
        labelStyle: textStyle(size: 12, weight: FontWeight.w700),
        secondaryLabelStyle: textStyle(
          size: 12,
          weight: FontWeight.w700,
          color: PregEaseColors.primaryDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide.none,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: PregEaseColors.border,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PregEaseColors.primary,
        linearTrackColor: PregEaseColors.pink,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: PregEaseColors.text,
        contentTextStyle: textStyle(
          size: 13,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PregEaseRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: PregEaseColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PregEaseRadius.lg),
        ),
        titleTextStyle: textStyle(size: 20, weight: FontWeight.w800),
        contentTextStyle: textStyle(
          size: 14,
          weight: FontWeight.w400,
          color: PregEaseColors.mutedText,
          height: 1.45,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PregEaseColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
    );
  }
}
