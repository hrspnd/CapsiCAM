// lib/services/cache_service.dart
//
// Local persistence for offline fallback. Every screen that hits
// Supabase writes its last successful result here; when a fetch
// fails (offline or otherwise), the screen reads back the most
// recent cached value instead of showing an empty/broken UI.
//
// Backed by shared_preferences — add it to pubspec.yaml if it isn't
// already there:
//   dependencies:
//     shared_preferences: ^2.2.0

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/models/scan_result.dart';
import 'package:thesis_app/l10n/app_localizations.dart';

/// A cached value plus when it was written, so the UI can show
/// "Offline — showing data from 5m ago" instead of a bare fallback.
class Cached<T> {
  final T data;
  final DateTime cachedAt;

  const Cached({required this.data, required this.cachedAt});
}

class CacheService {
  // Every key is scoped by the current user's ID. Without this, User
  // B's screens would seed themselves from User A's leftover cached
  // data immediately after login (before B's own fresh fetch
  // completes) — exactly the "old user's info flashes on screen"
  // symptom this class was causing. Falls back to a fixed suffix if
  // somehow called with nobody signed in, which shouldn't normally
  // happen since these are only used from authenticated screens.
  String get _userScope =>
      Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';

  String get _profileKey => 'cache_profile_v1:$_userScope';
  String get _dashboardKey => 'cache_dashboard_v1:$_userScope';
  String get _historyKey => 'cache_history_v1:$_userScope';

  // ── Profile (name, email, avatar) ───────────────────────────
  // Shared by the dashboard header and the account screen so both
  // benefit from whichever screen fetched most recently.

  /// Merges the given fields into whatever profile is already cached
  /// (dashboard and account each know a different subset — e.g. only
  /// account screen has the email — so a save from one shouldn't
  /// blank out a field the other previously cached). Pass null for
  /// any field you don't have; it will be left as-is if something
  /// was cached before, or stored as null otherwise.
  Future<void> saveProfile({
    String? fullName,
    String? email,
    String? avatarType,
    String? avatarValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadProfile();

    await prefs.setString(
      _profileKey,
      jsonEncode({
        'fullName': fullName ?? existing?.data.fullName,
        'email': email ?? existing?.data.email,
        'avatarType': avatarType ?? existing?.data.avatarType,
        'avatarValue': avatarValue ?? existing?.data.avatarValue,
        'cachedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<Cached<ProfileCacheData>?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return Cached(
        data: ProfileCacheData(
          fullName: json['fullName'] as String?,
          email: json['email'] as String?,
          avatarType: json['avatarType'] as String?,
          avatarValue: json['avatarValue'] as String?,
        ),
        cachedAt: DateTime.parse(json['cachedAt'] as String),
      );
    } catch (_) {
      // Corrupt/old-shape cache entry — treat as absent rather than crash.
      return null;
    }
  }

  // ── Dashboard (stats + recent scans preview) ────────────────

  Future<void> saveDashboard({
    required int totalScans,
    required int totalHealthy,
    required String? mostFrequentDisease,
    required List<ScanResult> recentScans,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dashboardKey,
      jsonEncode({
        'totalScans': totalScans,
        'totalHealthy': totalHealthy,
        'mostFrequentDisease': mostFrequentDisease,
        'recentScans': recentScans.map((s) => s.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<Cached<DashboardCacheData>?> loadDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dashboardKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final scans = (json['recentScans'] as List)
          .map((e) => ScanResult.fromJson(e as Map<String, dynamic>))
          .toList();
      return Cached(
        data: DashboardCacheData(
          totalScans: json['totalScans'] as int,
          totalHealthy: json['totalHealthy'] as int,
          mostFrequentDisease: json['mostFrequentDisease'] as String?,
          recentScans: scans,
        ),
        cachedAt: DateTime.parse(json['cachedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Full scan history ────────────────────────────────────────

  Future<void> saveHistory(List<ScanResult> scans) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode({
        'scans': scans.map((s) => s.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<Cached<List<ScanResult>>?> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final scans = (json['scans'] as List)
          .map((e) => ScanResult.fromJson(e as Map<String, dynamic>))
          .toList();
      return Cached(
        data: scans,
        cachedAt: DateTime.parse(json['cachedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  /// Clears the cached history — call this alongside
  /// SupabaseService.clearScanHistory() so a cleared history doesn't
  /// reappear from cache after an offline restart.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Wipes every cache entry for the currently signed-in user. Call
  /// this at logout, *before* Supabase's sign-out completes — once
  /// signed out, currentUser is null and _userScope can no longer
  /// resolve which entries belong to this user. Keys are already
  /// scoped per-user, so a different account logging in afterward
  /// wouldn't see this data anyway; this is just hygiene so a device
  /// used for many test accounts doesn't accumulate stale entries
  /// forever.
  Future<void> clearForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_dashboardKey);
    await prefs.remove(_historyKey);
  }
}

class ProfileCacheData {
  final String? fullName;
  final String? email;
  final String? avatarType;
  final String? avatarValue;

  const ProfileCacheData({
    required this.fullName,
    required this.email,
    required this.avatarType,
    required this.avatarValue,
  });
}

class DashboardCacheData {
  final int totalScans;
  final int totalHealthy;
  final String? mostFrequentDisease;
  final List<ScanResult> recentScans;

  const DashboardCacheData({
    required this.totalScans,
    required this.totalHealthy,
    required this.mostFrequentDisease,
    required this.recentScans,
  });
}

/// Formats a cache age like "2m ago", "3h ago", "just now" for banners.
/// Localized via [l10n] since this string is embedded directly into
/// the offline/refresh messages shown to the user.
String formatCacheAge(DateTime cachedAt, AppLocalizations l10n) {
  final diff = DateTime.now().difference(cachedAt);
  if (diff.inMinutes < 1) return l10n.cacheAgeJustNow;
  if (diff.inMinutes < 60) return l10n.cacheAgeMinutes(diff.inMinutes);
  if (diff.inHours < 24) return l10n.cacheAgeHours(diff.inHours);
  return l10n.cacheAgeDays(diff.inDays);
}