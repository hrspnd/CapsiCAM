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

/// The current user's chosen avatar. [type] is either 'icon' (with
/// [value] one of the fixed icon names, e.g. 'leaf') or 'monogram'
/// (with [value] a '#RRGGBB' hex color) — matches the
/// `profiles.avatar_type` / `profiles.avatar_value` check constraints.
class ProfileAvatar {
  final String type;
  final String value;

  const ProfileAvatar({required this.type, required this.value});
}

class SupabaseService {
  final _client = Supabase.instance.client;

  // Applied to every network call below. Without this, a dead/slow
  // connection (e.g. connected to Wi-Fi with no real internet) can
  // hang for the OS's own connection timeout — commonly 30-60+
  // seconds on mobile — before failing. This makes every call fail
  // fast into the 'offline' path instead, so offline fallbacks (see
  // CacheService) kick in promptly rather than after a long stall.
  static const _networkTimeout = Duration(seconds: 8);

  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      ).timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));

      if (response.user == null || response.session == null) {
        throw Exception('Sign up failed. Please try again.');
      }
    } on SocketException {
      throw Exception('offline');
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      ).timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));

      if (response.user == null || response.session == null) {
        throw Exception('Login failed. Please try again.');
      }
    } on SocketException {
      throw Exception('offline');
    } on AuthException catch (e) {
      throw Exception(e.message);
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
          .maybeSingle()
          .timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));
      return row?['full_name'] as String?;
    } on SocketException {
      throw Exception('offline');
    } on PostgrestException catch (e) {
      throw Exception('Could not load profile: ${e.message}');
    }
  }

  /// Updates the current user's display name in the `profiles` table.
  /// Also mirrors it into the auth user's metadata so it's available
  /// immediately (e.g. right after sign-in, before `profiles` is
  /// fetched) without needing another round trip.
  Future<void> updateFullName(String fullName) async {
    try {
      await _client
          .from('profiles')
          .update({'full_name': fullName})
          .eq('id', _requireUserId)
          .timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));
    } on SocketException {
      throw Exception('offline');
    } on PostgrestException catch (e) {
      throw Exception('Could not update name: ${e.message}');
    }

    try {
      await _client.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      ).timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));
    } on SocketException {
      throw Exception('offline');
    } on AuthException catch (e) {
      // The profiles row already saved successfully at this point, so
      // don't fail the whole operation over the metadata mirror — just
      // surface it as a non-fatal exception for the caller to decide on.
      throw Exception('Name saved, but could not sync account info: ${e.message}');
    }
  }

  /// The current user's avatar from the `profiles` table. Returns
  /// null if the row (or the columns) can't be found, so callers can
  /// fall back to the schema default ('monogram' / '#F5A623').
  Future<ProfileAvatar?> fetchAvatar() async {
    try {
      final row = await _client
          .from('profiles')
          .select('avatar_type, avatar_value')
          .eq('id', _requireUserId)
          .maybeSingle()
          .timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));
      final type = row?['avatar_type'] as String?;
      final value = row?['avatar_value'] as String?;
      if (type == null || value == null) return null;
      return ProfileAvatar(type: type, value: value);
    } on SocketException {
      throw Exception('offline');
    } on PostgrestException catch (e) {
      throw Exception('Could not load avatar: ${e.message}');
    }
  }

  /// Updates the current user's avatar in the `profiles` table.
  /// [avatarType] must be 'icon' or 'monogram'; [avatarValue] must be
  /// a name from the fixed icon set (for 'icon') or a '#RRGGBB' hex
  /// color (for 'monogram') — the DB check constraints enforce this.
  Future<void> updateAvatar({
    required String avatarType,
    required String avatarValue,
  }) async {
    try {
      await _client.from('profiles').update({
        'avatar_type': avatarType,
        'avatar_value': avatarValue,
      }).eq('id', _requireUserId).timeout(
        _networkTimeout,
        onTimeout: () => throw const SocketException('timeout'),
      );
    } on SocketException {
      throw Exception('offline');
    } on PostgrestException catch (e) {
      throw Exception('Could not update avatar: ${e.message}');
    }
  }

  /// Changes the current user's password. Re-authenticates with
  /// [currentPassword] first so a wrong current password surfaces as
  /// a normal error instead of silently changing to [newPassword].
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = _client.auth.currentUser?.email;
    if (email == null) {
      throw Exception('Not signed in.');
    }

    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      ).timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));
    } on SocketException {
      throw Exception('offline');
    } on AuthException catch (e) {
      throw Exception(e.message);
    }

    try {
      await _client.auth
          .updateUser(UserAttributes(password: newPassword))
          .timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));
    } on SocketException {
      throw Exception('offline');
    } on AuthException catch (e) {
      throw Exception(e.message);
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
          .eq('user_id', _requireUserId)
          .timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));

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
          .limit(limit)
          .timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));
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
          .order('scanned_at', ascending: false)
          .timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));
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
      await _client
          .from('scans')
          .delete()
          .eq('user_id', _requireUserId)
          .timeout(_networkTimeout, onTimeout: () => throw const SocketException('timeout'));
    } on SocketException {
      throw Exception('offline');
    } on PostgrestException catch (e) {
      throw Exception('Could not clear scan history: ${e.message}');
    }
  }
}