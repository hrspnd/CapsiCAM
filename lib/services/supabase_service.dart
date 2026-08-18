import 'dart:io';

import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Aggregated numbers for the dashboard's stat cards.
class DashboardStats {
  final int totalScans;
  final int totalHealthy;
  /// Raw classification value from the DB (e.g. 'bacterial_leaf_spot'),
  /// or null if the user has no diseased scans yet.
  final String? mostFrequentDisease;

  const DashboardStats({
    required this.totalScans,
    required this.totalHealthy,
    required this.mostFrequentDisease,
  });
}

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );

    if (response.user == null || response.session == null) {
      throw Exception('Sign up failed. Please try again.');
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null || response.session == null) {
      throw Exception('Login failed. Please try again.');
    }
  }

  // ── Dashboard ─────────────────────────────────────────────

  String get _requireUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw Exception('Not signed in.');
    }
    return id;
  }

  /// Full name from the `profiles` table for the current user.
  Future<String?> fetchFullName() async {
    try {
      final row = await _client
          .from('profiles')
          .select('full_name')
          .eq('id', _requireUserId)
          .maybeSingle();
      return row?['full_name'] as String?;
    } on SocketException {
      throw Exception('offline');
    } on PostgrestException catch (e) {
      throw Exception('Could not load profile: ${e.message}');
    }
  }

  /// Total scans, total healthy, and the most frequent *disease*
  /// (healthy scans are excluded from "most frequent" since that
  /// stat is meant to surface a problem, not a good outcome).
  ///
  /// Computed client-side by pulling just the `classification` column
  /// for the user. Fine at low-to-moderate scan volumes; if this table
  /// grows large, swap this for a Postgres RPC/view that aggregates
  /// server-side instead.
  Future<DashboardStats> fetchDashboardStats() async {
    try {
      final rows = await _client
          .from('scans')
          .select('classification')
          .eq('user_id', _requireUserId);

      final classifications = (rows as List)
          .map((r) => r['classification'] as String)
          .toList();

      final total = classifications.length;
      final healthy = classifications.where((c) => c == 'healthy').length;

      final diseaseCounts = <String, int>{};
      for (final c in classifications) {
        if (c == 'healthy') continue;
        diseaseCounts[c] = (diseaseCounts[c] ?? 0) + 1;
      }

      String? mostFrequent;
      if (diseaseCounts.isNotEmpty) {
        mostFrequent = diseaseCounts.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;
      }

      return DashboardStats(
        totalScans: total,
        totalHealthy: healthy,
        mostFrequentDisease: mostFrequent,
      );
    } on SocketException {
      throw Exception('offline');
    } on PostgrestException catch (e) {
      throw Exception('Could not load dashboard stats: ${e.message}');
    }
  }

  /// Most recent scans for the current user, newest first.
  /// Returns raw rows — mapped to ScanResult in the UI layer.
  Future<List<Map<String, dynamic>>> fetchRecentScans({int limit = 3}) async {
    try {
      final rows = await _client
          .from('scans')
          .select()
          .eq('user_id', _requireUserId)
          .order('scanned_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(rows as List);
    } on SocketException {
      throw Exception('offline');
    } on PostgrestException catch (e) {
      throw Exception('Could not load recent scans: ${e.message}');
    }
  }

  /// All scans for the current user, newest first. Used by the full
  /// Scan History screen (fetchRecentScans is for the dashboard's
  /// capped preview list).
  Future<List<Map<String, dynamic>>> fetchAllScans() async {
    try {
      final rows = await _client
          .from('scans')
          .select()
          .eq('user_id', _requireUserId)
          .order('scanned_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows as List);
    } on SocketException {
      throw Exception('offline');
    } on PostgrestException catch (e) {
      throw Exception('Could not load scan history: ${e.message}');
    }
  }

  /// Deletes all scan rows for the current user. Does not remove the
  /// underlying files from the scan-images Storage bucket — those are
  /// left in place (cheap to leave orphaned for now; revisit if
  /// storage costs become a concern).
  Future<void> clearScanHistory() async {
    try {
      await _client.from('scans').delete().eq('user_id', _requireUserId);
    } on SocketException {
      throw Exception('offline');
    } on PostgrestException catch (e) {
      throw Exception('Could not clear scan history: ${e.message}');
    }
  }
}