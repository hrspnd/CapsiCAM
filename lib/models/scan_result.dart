// lib/models/scan_result.dart

class ScanResult {
  final String id;
  final String disease;
  final String imageSource;
  final String date;
  final double confidence;
  final String? imagePath;

  const ScanResult({
    required this.id,
    required this.disease,
    required this.imageSource,
    required this.date,
    required this.confidence,
    this.imagePath,
  });
}