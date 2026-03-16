import 'package:flutter/material.dart';

/// Modern Professional Theme - Clean and sophisticated design
/// Blue-based color palette with refined accents
class AppColors {
  // Dark Theme - Deep navy with cyan accents
  static const Color darkPrimary = Color(0xFF0A0E27);
  static const Color darkSecondary = Color(0xFF151B3D);
  static const Color darkSurface = Color(0xFF1E2542);
  static const Color sticker_color = Color.fromARGB(255, 199, 166, 0);
  
  // Light Theme - Clean white with subtle blue tints
  static const Color lightPrimary = Color(0xFFF8FAFB);
  static const Color lightSecondary = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF0F4F8);
  
  // Gradient Colors - Modern blue to cyan
  static const Color gradientStart = Color(0xFF4F46E5); // Indigo
  static const Color gradientMiddle = Color(0xFF6366F1); // Bright Indigo
  static const Color gradientEnd = Color(0xFF818CF8); // Light Indigo
  
  // Secondary gradient - Teal to Cyan
  static const Color secondaryGradientStart = Color(0xFF0891B2); // Teal
  static const Color secondaryGradientEnd = Color(0xFF06B6D4); // Cyan
  
  // Accent colors - Modern professional palette
  static const Color accentAmber = Color(0xFF6366F1); // Indigo (replacing amber)
  static const Color accentOrange = Color(0xFF0891B2); // Teal (replacing orange)
  static const Color accentYellow = Color(0xFF8B5CF6); // Purple (replacing yellow)
  static const Color accentRed = Color(0xFFDC2626); // Emergency red
  
  // Emergency and status
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF3B82F6);
  
  // Text colors - Dark theme
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  
  // Text colors - Light theme
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF64748B);
  
  // Borders and dividers
  static const Color darkBorder = Color(0xFF334155);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color darkDivider = Color(0xFF475569);
  static const Color lightDivider = Color(0xFFCBD5E1);
  
  // Utility
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientMiddle, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryGradientStart, secondaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E27), Color(0xFF151B3D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Backwards compatibility aliases for old color names
  static const Color primaryBackground = darkPrimary;
  static const Color secondaryBackground = darkSecondary;
  static const Color lightPrimaryBackground = lightPrimary;
  static const Color lightSecondaryBackground = lightSecondary;
  static const Color surfaceWhite = white;
  static const Color surfaceLight = lightSurface;
  static const Color surfaceDark = darkSurface;
  static const Color textLight = white;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textHint = lightTextTertiary;
  static const Color border = lightBorder;
  static const Color divider = lightDivider;
  
  // Additional backward compatibility for accent colors
  static const Color accentBlue = accentAmber; // Map old blue to new amber
  static const Color accentPurple = accentOrange; // Map old purple to new orange
  static const Color accentCyan = accentYellow; // Map old cyan to new yellow
  static const Color accentPink = accentRed; // Map old pink to new red
}

/// Modern app typography with SF Pro / Inter style
class AppTypography {
  static const String fontFamily = 'Inter';
  
  // Display styles - Extra large headings
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.1,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.2,
  );
  
  // Heading styles
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
  );
  
  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.3,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.3,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.2,
  );
  
  // Caption and overline
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.2,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.2,
  );
  
  // Button styles
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.2,
  );
}

/// Modern spacing system - 4px base unit
class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Modern border radius system
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double full = 9999.0;
}

/// Elevation system
class AppElevation {
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double xxl = 16.0;
}

/// Main app theme with modern Material 3 design
class AppTheme {
  /// Dark theme with deep charcoal and amber accents
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkPrimary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.accentAmber,
        secondary: AppColors.accentOrange,
        tertiary: AppColors.accentYellow,
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkSecondary,
        error: AppColors.error,
        onPrimary: AppColors.darkPrimary,
        onSecondary: AppColors.darkPrimary,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.white,
        outline: AppColors.darkBorder,
      ),
      
      // AppBar theme - gradient style
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: AppTypography.h3.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: AppElevation.sm,
        shadowColor: AppColors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accentAmber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextTertiary,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),
      
      // Elevated button theme - gradient style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentAmber,
          foregroundColor: Colors.white,
          elevation: AppElevation.sm,
          shadowColor: AppColors.accentAmber.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button,
          minimumSize: const Size(double.infinity, 54),
        ),
      ),
      
      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentAmber,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentAmber,
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentAmber,
        foregroundColor: Colors.white,
        elevation: AppElevation.md,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSecondary,
        selectedItemColor: AppColors.accentAmber,
        unselectedItemColor: AppColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: AppTypography.h1.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: AppTypography.h2.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall: AppTypography.h3.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: AppTypography.h4.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.darkTextSecondary),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.darkTextPrimary),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.darkTextSecondary),
      ),
    );
  }

  /// Light theme with clean, bright high-visibility design
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightPrimary,
      colorScheme: ColorScheme.light(
        primary: AppColors.accentAmber,
        secondary: AppColors.accentOrange,
        tertiary: AppColors.accentYellow,
        surface: AppColors.lightSecondary,
        surfaceContainerHighest: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: AppColors.darkPrimary,
        onSecondary: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
        onError: AppColors.white,
        outline: AppColors.lightBorder,
      ),
      
      // AppBar theme - gradient style
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: AppTypography.h3.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.lightSecondary,
        elevation: AppElevation.sm,
        shadowColor: AppColors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accentAmber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightTextTertiary,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        ),
      ),
      
      // Elevated button theme - modern indigo style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentAmber,
          foregroundColor: Colors.white,
          elevation: AppElevation.sm,
          shadowColor: AppColors.accentAmber.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button,
          minimumSize: const Size(double.infinity, 54),
        ),
      ),
      
      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentAmber,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentAmber,
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentAmber,
        foregroundColor: Colors.white,
        elevation: AppElevation.md,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSecondary,
        selectedItemColor: AppColors.accentAmber,
        unselectedItemColor: AppColors.lightTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.lightTextPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.lightTextPrimary),
        headlineLarge: AppTypography.h1.copyWith(color: AppColors.lightTextPrimary),
        headlineMedium: AppTypography.h2.copyWith(color: AppColors.lightTextPrimary),
        headlineSmall: AppTypography.h3.copyWith(color: AppColors.lightTextPrimary),
        titleLarge: AppTypography.h4.copyWith(color: AppColors.lightTextPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.lightTextPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextPrimary),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.lightTextPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.lightTextPrimary),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.lightTextSecondary),
      ),
    );
  }
}
