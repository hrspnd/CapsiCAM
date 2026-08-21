// lib/models/scan_result.dart

import 'package:intl/intl.dart';
import 'package:thesis_app/constants.dart';

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

  // ── Row → ScanResult mapping ───────────────────────────────
  // Single source of truth for turning a raw `scans` table row (as
  // returned by SupabaseService.fetchRecentScans/fetchAllScans) into
  // a ScanResult. Previously duplicated separately in the dashboard
  // and scan history screens — kept here now so they can't drift.

  static const Map<String, String> diseaseDisplayKeys = {
    'healthy': 'Healthy',
    'bacterial_leaf_spot': 'Bacterial_Leaf_Spot',
    'cercospora_leaf_spot': 'Cercospora_Leaf_Spot',
  };

  factory ScanResult.fromRow(Map<String, dynamic> row) {
    final classification = row['classification'] as String;

    double confidence;
    switch (classification) {
      case 'healthy':
        confidence = (row['confidence_healthy'] as num).toDouble();
        break;
      case 'bacterial_leaf_spot':
        confidence = (row['confidence_bls'] as num).toDouble();
        break;
      case 'cercospora_leaf_spot':
        confidence = (row['confidence_cls'] as num).toDouble();
        break;
      default:
        confidence = 0.0;
    }

    final scannedAt = DateTime.parse(row['scanned_at'] as String).toLocal();

    return ScanResult(
      id: row['id'] as String,
      disease: diseaseDisplayKeys[classification] ?? classification,
      imageSource: row['image_source'] == 'captured'
          ? AppConstants.sourceScanned
          : AppConstants.sourceUploaded,
      date: DateFormat('MMM d, yyyy').format(scannedAt),
      scannedAt: scannedAt,
      confidence: confidence,
      predictions: {
        'Healthy': (row['confidence_healthy'] as num).toDouble(),
        'Bacterial_Leaf_Spot': (row['confidence_bls'] as num).toDouble(),
        'Cercospora_Leaf_Spot': (row['confidence_cls'] as num).toDouble(),
      },
      imagePath: row['image_url'] as String?,
      heatmapPath: row['heatmap_url'] as String?,
    );
  }

  // ── Cache (de)serialization ─────────────────────────────────
  // Used by CacheService to persist scans locally for offline
  // fallback. Not tied to the Supabase row shape — this is our own
  // flat JSON representation.

  Map<String, dynamic> toJson() => {
        'id': id,
        'disease': disease,
        'imageSource': imageSource,
        'date': date,
        'scannedAt': scannedAt.toIso8601String(),
        'confidence': confidence,
        'predictions': predictions,
        'imagePath': imagePath,
        'heatmapPath': heatmapPath,
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
        id: json['id'] as String,
        disease: json['disease'] as String,
        imageSource: json['imageSource'] as String,
        date: json['date'] as String,
        scannedAt: DateTime.parse(json['scannedAt'] as String),
        confidence: (json['confidence'] as num).toDouble(),
        predictions: (json['predictions'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
        imagePath: json['imagePath'] as String?,
        heatmapPath: json['heatmapPath'] as String?,
      );
}