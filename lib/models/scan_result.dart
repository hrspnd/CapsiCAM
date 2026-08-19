// lib/models/scan_result.dart

class ScanResult {
  final String id;
  final String disease;
  final String imageSource;

  /// Pre-formatted display string (e.g. "Aug 19, 2026"), used by list
  /// views like the dashboard and history list.
  final String date;

  /// The actual scan timestamp. Use this (not [date]) wherever a real
  /// DateTime is needed, e.g. screens that show both date and time.
  final DateTime scannedAt;

  /// Confidence of the winning/predicted class.
  final double confidence;

  /// Confidence for every class, keyed by display name
  /// (e.g. 'Healthy', 'Bacterial_Leaf_Spot', 'Cercospora_Leaf_Spot'),
  /// matching AppConstants.classNames. Used for confidence-breakdown UI.
  final Map<String, double> predictions;

  final String? imagePath;

  /// URL/path to the Grad-CAM heatmap image for this scan, if one was
  /// generated and stored. Null if not available.
  final String? heatmapPath;

  const ScanResult({
    required this.id,
    required this.disease,
    required this.imageSource,
    required this.date,
    required this.scannedAt,
    required this.confidence,
    required this.predictions,
    this.imagePath,
    this.heatmapPath,
  });
}