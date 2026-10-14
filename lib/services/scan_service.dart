import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/scan_results_screen.dart'; // for ScanResultsArgs

/// Handles persisting a completed scan (image + classification result)
/// to Supabase: uploads the image (and heatmap, if present) to the
/// `scan-images` Storage bucket, then inserts a row into `scans`.
class ScanService {
  final SupabaseClient _client = Supabase.instance.client;
  static const _bucket = 'scan-images';

  // scan-images is a private bucket, so we can't use getPublicUrl() —
  // that returns a link that 403s. Instead we generate a signed URL.
  // 10-year expiry: simplest option for now (no re-signing logic needed
  // elsewhere yet); if we ever need shorter-lived links, switch to
  // storing the raw object path and signing on read instead.
  static const _signedUrlExpirySeconds = 60 * 60 * 24 * 365 * 10;

  /// Saves [args] for the currently logged-in user.
  ///
  /// Throws a [StateError] if no user is logged in, or rethrows any
  /// Supabase/storage exception so the caller can decide how to
  /// surface it (e.g. a snackbar) without blocking navigation.
  Future<void> saveScan(ScanResultsArgs args) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Cannot save scan: no logged-in user.');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // ── Upload original image ──────────────────────────────
    final imagePath = '$userId/scan_$timestamp.jpg';
    await _client.storage
        .from(_bucket)
        .upload(
          imagePath,
          File(args.imagePath),
          fileOptions: const FileOptions(upsert: false),
        );
    final imageUrl = await _client.storage
        .from(_bucket)
        .createSignedUrl(imagePath, _signedUrlExpirySeconds);

    // ── Upload heatmap, if any ─────────────────────────────
    String? heatmapUrl;
    if (args.heatmapPath != null) {
      final heatmapStoragePath = '$userId/heatmap_$timestamp.png';
      await _client.storage
          .from(_bucket)
          .upload(
            heatmapStoragePath,
            File(args.heatmapPath!),
            fileOptions: const FileOptions(upsert: false),
          );
      heatmapUrl = await _client.storage
          .from(_bucket)
          .createSignedUrl(heatmapStoragePath, _signedUrlExpirySeconds);
    }

    // ── Pull confidences by translated class name ──────────
    final confidenceHealthy = args.predictions['Healthy'] ?? 0.0;
    final confidenceBls = args.predictions['Bacterial_Leaf_Spot'] ?? 0.0;
    final confidenceCls = args.predictions['Cercospora_Leaf_Spot'] ?? 0.0;

    // ── Insert scan row ─────────────────────────────────────
    await _client.from('scans').insert({
      'user_id': userId,
      'image_url': imageUrl,
      'classification': args.label.toLowerCase(),
      'confidence_healthy': confidenceHealthy,
      'confidence_bls': confidenceBls,
      'confidence_cls': confidenceCls,
      'image_source': args.source.toLowerCase(),
      'heatmap_url': heatmapUrl,
      'scanned_at': args.date.toUtc().toIso8601String(),
    });
  }
}