import 'package:flutter/material.dart';

// ============================================================
// COLORS
// ============================================================

class AppColors {
  // Primary
  static const Color primary        = Color(0xFF2C9585);
  static const Color primaryDark    = Color(0xFF0F6E56);
  static const Color primaryDarker  = Color(0xFF085041);
  static const Color primaryLight   = Color(0xFF5DCAA5);
  static const Color primaryLightest = Color(0xFFE1F5EE);

  // Background
  static const Color background     = Color(0xFFF5F5F3);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceGray    = Color(0xFFEFEFEF);

  // Text
  static const Color textPrimary    = Color(0xFF1A1A1A);
  static const Color textSecondary  = Color(0xFF888888);
  static const Color textWhite      = Color(0xFFFFFFFF);

  // Border
  static const Color border         = Color(0xFF949494);
  static const Color borderLight    = Color(0xFFD0D0CC);

  // Disease labels
  static const Color bacterial      = Color(0xFFA63C1D);
  static const Color bacterialBg    = Color(0xFFFAECE7);
  static const Color cercospora     = Color(0xFFBA7517);
  static const Color cercosporaBg   = Color(0xFFFAEEDA);
  static const Color healthy        = Color(0xFF3B6D11);
  static const Color healthyBg      = Color(0xFFEAF3DE);

  // Confidence levels
  static const Color confHigh       = Color(0xFF3B6D11);
  static const Color confGood       = Color(0xFF185FA5);
  static const Color confModerate   = Color(0xFFBA7517);
  static const Color confLow        = Color(0xFF993C1D);

  // Danger
  static const Color danger         = Color(0xFF993C1D);
  static const Color dangerBg       = Color(0xFFFCEBEB);

  // ── Helper methods ────────────────────────────────────────

  /// Returns color based on disease class name
  static Color forDisease(String disease) {
    final d = disease.toLowerCase();
    if (d.contains('bacterial')) return bacterial;
    if (d.contains('cercospora')) return cercospora;
    if (d.contains('healthy')) return healthy;
    return textSecondary;
  }

  /// Returns background color based on disease class name
  static Color bgForDisease(String disease) {
    final d = disease.toLowerCase();
    if (d.contains('bacterial')) return bacterialBg;
    if (d.contains('cercospora')) return cercosporaBg;
    if (d.contains('healthy')) return healthyBg;
    return surfaceGray;
  }

  /// Returns color based on confidence level
  static Color forConfidence(double confidence) {
    if (confidence >= 0.90) return confHigh;
    if (confidence >= 0.70) return confGood;
    if (confidence >= 0.50) return confModerate;
    return confLow;
  }

  /// Returns confidence label text
  static String labelForConfidence(double confidence) {
    if (confidence >= 0.90) return 'High';
    if (confidence >= 0.70) return 'Good';
    if (confidence >= 0.50) return 'Moderate';
    return 'Low';
  }
}

// ============================================================
// TEXT STYLES
// ============================================================

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );
}

// ============================================================
// SPACING & RADIUS
// ============================================================

class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
}

class AppRadius {
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 14.0;
  static const double xl  = 20.0;
  static const double full = 999.0;
}

// ============================================================
// ASSET PATHS
// ============================================================

class AppAssets {
  static const String liveCameraIcon    = 'assets/icons/live-camera.png';
  static const String captureImageIcon  = 'assets/icons/capture-image.png';
  static const String historyIcon       = 'assets/icons/history.png';
  static const String hatAvatar         = 'assets/icons/hat.png';
  static const String tfliteModel       = 'assets/kita_mobilenet.tflite';
  static const String labels            = 'assets/labels.txt';
}

// ============================================================
// ROUTE NAMES
// ============================================================

class AppRoutes {
  static const String login         = '/login';
  static const String signup        = '/signup';
  static const String dashboard     = '/dashboard';
  static const String liveScan      = '/live-scan';
  static const String captureImage  = '/capture-image';
  static const String scanResults   = '/scan-results';
  static const String scanHistory   = '/scan-history';
  static const String account       = '/account';
  static const String myAccount     = '/my-account';
}

// ============================================================
// APP-WIDE CONSTANTS
// ============================================================

class AppConstants {
  // TFLite
  static const int    inputSize         = 224;
  static const double confidenceThreshold = 0.70;

  // Class names — must match labels.txt order
  static const List<String> classNames = [
    'Bacterial_Leaf_Spot',
    'Cercospora_Leaf_Spot',
    'Healthy',
  ];

  // Image sources
  static const String sourceScanned   = 'Scanned';
  static const String sourceUploaded  = 'Uploaded';
}
