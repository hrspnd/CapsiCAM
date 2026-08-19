// scan_refresh_bus.dart
import 'package:flutter/foundation.dart';

// ============================================================
// SCAN REFRESH BUS
// ============================================================
//
// A tiny app-wide signal that a scan was saved, so any screen that
// shows scan data (e.g. the dashboard) knows to reload the next time
// it's visible — regardless of how deep it sits in the navigation
// stack or whether you get back to it via push/pop or go().
//
// Usage:
//   - Call `ScanRefreshBus.notify()` right before/when leaving a
//     screen that just saved a scan (e.g. ScanResultsScreen).
//   - In a screen that should react, add a listener in initState()
//     and remove it in dispose():
//
//     @override
//     void initState() {
//       super.initState();
//       ScanRefreshBus.listenable.addListener(_onScanRefresh);
//     }
//
//     void _onScanRefresh() {
//       if (!mounted) return;
//       _loadDashboard();
//     }
//
//     @override
//     void dispose() {
//       ScanRefreshBus.listenable.removeListener(_onScanRefresh);
//       super.dispose();
//     }

class ScanRefreshBus {
  ScanRefreshBus._();

  static final ValueNotifier<int> _version = ValueNotifier<int>(0);

  /// Listenable that fires every time [notify] is called.
  static ValueListenable<int> get listenable => _version;

  /// Call this whenever a scan is saved / completed, so listening
  /// screens know their cached data is stale.
  static void notify() => _version.value++;
}