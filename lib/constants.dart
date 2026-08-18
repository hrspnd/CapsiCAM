// constants.dart

import 'package:flutter/material.dart';

// ============================================================
// THEME-AWARE COLORS
// Use AppColors.of(context).colorName in widgets
// ============================================================

class AppColors {
  final bool isDark;
  const AppColors._(this.isDark);

  // Factory — call this in widgets: AppColors.of(context)
  static AppColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AppColors._(brightness == Brightness.dark);
  }

  // ── Theme-aware colors ────────────────────────────────────

  Color get background =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F3);
  Color get surface =>
      isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  Color get surfaceGray =>
      isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEFEFEF);
  Color get border =>
      isDark ? const Color(0xFF414141) : const Color(0xFF949494);
  Color get chevron => const Color(0xFF6B6B6B);
  Color get bacterial =>
      isDark ? const Color(0xFFDD5D38) : const Color(0xFFA63C1D);
  Color get healthy =>
      isDark ? const Color(0xFF3EB489) : const Color(0xFF3B6D11);
  Color get primaryDark =>
      isDark ? const Color(0xFF3EB489) : const Color(0xFF0F6E56);
  Color get primaryLightest =>
      isDark ? const Color(0xFFC2FFEA) : const Color(0xFFE1F5EE);
  Color get about => isDark ? const Color(0xFFDFDCD2) : const Color(0xFFF1EFE8);
  Color get liveConfidenceBg =>
      isDark ? const Color(0x801A1A1A) : const Color(0xFFF5F5F0);
  Color get buttonBg =>
      isDark ? const Color(0xFF2C9585) : const Color(0xFF0F6E56);

  // ── text ───────────────────────────────
  Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  Color get textSecondary => const Color(0xFF989898);
  Color get textGray => const Color(0xFF5C5C5C);
  Color get textGreen =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF185743);
  Color get appSettingsIcon =>
      isDark ? const Color(0xFF0F6E56) : const Color(0xFF3EB489);

  // ── Always the same in both modes ────────────────────────

  // Primary green
  Color get primary => const Color(0xFF2C9585);
  Color get primaryDarker => const Color(0xFF085041);
  Color get primaryLight => const Color(0xFF5DCAA5);

  // Disease
  Color get bacterialBg => const Color(0xFFFAECE7);
  Color get cercospora => const Color(0xFFBA7517);
  Color get cercosporaBg => const Color(0xFFFAEEDA);
  Color get healthyBg => const Color(0xFFEAF3DE);

  // Confidence
  Color get confHigh => const Color(0xFF90BD54);
  Color get confGood => const Color(0xFF4A93D5);
  Color get confModerate => const Color(0xFFE39A2D);
  Color get confLow => const Color(0xFFA63C1D);
  Color get confidenceBar => const Color(0xFFE2E2E2);

  // Danger
  Color get danger => const Color(0xFFDD5D38);
  Color get dangerBg => const Color(0xFFFCEBEB);

  // White always
  Color get textWhite => const Color(0xFFFFFFFF);

  // Black always
  Color get textBlack => const Color(0xFF000000);

  // My Account secondary text
  Color get infoColor => const Color(0xFF5E5E5E);

  // ── Helper methods ────────────────────────────────────────

  Color forDisease(String disease) {
    final d = disease.toLowerCase();
    if (d.contains('bacterial')) return bacterial;
    if (d.contains('cercospora')) return cercospora;
    if (d.contains('healthy')) return healthy;
    return textSecondary;
  }

  Color bgForDisease(String disease) {
    final d = disease.toLowerCase();
    if (d.contains('bacterial')) return bacterialBg;
    if (d.contains('cercospora')) return cercosporaBg;
    if (d.contains('healthy')) return healthyBg;
    return surfaceGray;
  }

  Color forConfidence(double confidence) {
    if (confidence >= 0.90) return confHigh;
    if (confidence >= 0.70) return confGood;
    if (confidence >= 0.50) return confModerate;
    return confLow;
  }

  static String labelForConfidence(double confidence) {
    if (confidence >= 0.90) return 'High';
    if (confidence >= 0.70) return 'Good';
    if (confidence >= 0.50) return 'Moderate';
    return 'Low';
  }
}

// ============================================================
// SPACING & RADIUS
// ============================================================

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 14.0;
  static const double xl = 20.0;
  static const double xxl = 30.0;
  static const double full = 999.0;
}

// ============================================================
// ASSET PATHS
// ============================================================

class AppAssets {
  static const String googleIcon = 'assets/icons/google.png';
  static const String liveCameraIcon = 'assets/icons/live-camera.png';
  static const String captureImageIcon = 'assets/icons/capture-image.png';
  static const String historyIcon = 'assets/icons/history.png';
  static const String hatAvatar = 'assets/icons/hat.png';
  static const String tfliteModel = 'assets/kita_mobilenet.tflite';
  static const String labels = 'assets/labels.txt';
  static const String accountIcon = 'assets/icons/account.png';
  static const String homeIcon = 'assets/icons/home.png';
  static const String displayMode = 'assets/icons/display-mode.png';
  static const String languageIcon = 'assets/icons/language.png';
  static const String helpIcon = 'assets/icons/help.png';
  static const String aboutIcon = 'assets/icons/about.png';
  static const String trashIcon = 'assets/icons/trash.png';
  static const String backIcon = 'assets/icons/back.png';
  static const String nameIcon = 'assets/icons/account.png';
  static const String changePassword = 'assets/icons/change-password.png';
  static const String dateCreated = 'assets/icons/date.png';
  static const String editIcon = 'assets/icons/pencil.png';
  static const String noImage = 'assets/icons/no-image.png';
  static const String cameraIcon = 'assets/icons/camera.png';
  static const String uploadIcon = 'assets/icons/upload.png';
  static const String leafBullet = 'assets/icons/scan-bullet.png';
}

// ============================================================
// ROUTE NAMES
// ============================================================

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String liveScan = '/live-scan';
  static const String captureImage = '/capture-image';
  static const String scanResults = '/scan-results';
  static const String scanHistory = '/scan-history';
  static const String account = '/account';
  static const String myAccount = '/my-account';
  static const String historyResult = '/history-result';
}

// ============================================================
// APP-WIDE CONSTANTS
// ============================================================

class AppConstants {
  static const int inputSize = 224;
  static const double confidenceThreshold = 0.70;

  static const List<String> classNames = [
    'Bacterial_Leaf_Spot',
    'Cercospora_Leaf_Spot',
    'Healthy',
  ];

  static const String sourceScanned = 'Captured';
  static const String sourceUploaded = 'Uploaded';
}

// ============================================================
// LIGHT & DARK THEMES for MaterialApp
// ============================================================

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Onest',
    scaffoldBackgroundColor: const Color(0xFFF5F5F3),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2C9585),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2C9585),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Onest',
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2C9585),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2C9585),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
