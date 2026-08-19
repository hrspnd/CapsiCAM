// profile_refresh_bus.dart
import 'package:flutter/foundation.dart';

// ============================================================
// PROFILE REFRESH BUS
// ============================================================
//
// Same idea as ScanRefreshBus, but for profile data (display name,
// etc.) instead of scans. Call `ProfileRefreshBus.notify()` after a
// successful profile change, and any screen showing profile data
// (account screen, dashboard greeting) can listen and reload.

class ProfileRefreshBus {
  ProfileRefreshBus._();

  static final ValueNotifier<int> _version = ValueNotifier<int>(0);

  /// Listenable that fires every time [notify] is called.
  static ValueListenable<int> get listenable => _version;

  /// Call this whenever the user's profile is actually changed, so
  /// listening screens know their cached data is stale.
  static void notify() => _version.value++;
}