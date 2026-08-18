import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';
import 'theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/account/account_screen.dart';
import 'screens/account/my_account_screen.dart';
// import 'screens/live_scan_screen.dart';
import 'screens/capture_image_screen.dart';
import 'screens/scan_results_screen.dart';
import 'screens/history_result_screen.dart';

// ============================================================
// SUPABASE INIT
// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://urcxjpcvnhebqomcamuf.supabase.co',
    anonKey: 'sb_publishable_0fsa0DkN88ZykQNz_eYaMA_p7gsjHTV',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const _AppWithTheme(),
    ),
  );
}

class _AppWithTheme extends StatelessWidget {
  const _AppWithTheme();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return ThesisApp(themeProvider: themeProvider);
  }
}

// ============================================================
// ROUTER
// ============================================================

/// Bridges a Stream (Supabase's auth state changes) into a Listenable
/// that GoRouter can watch, so `redirect` re-runs whenever the user
/// logs in or out — not just when a navigation is manually triggered.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Routes reachable without a logged-in session.
const _authRoutes = {AppRoutes.login, AppRoutes.signup};

final _router = GoRouter(
  initialLocation: AppRoutes.login,
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final isAuthRoute = _authRoutes.contains(state.matchedLocation);

    // Not logged in and trying to reach a protected screen → send to login.
    if (!isLoggedIn && !isAuthRoute) {
      return AppRoutes.login;
    }

    // Already logged in but sitting on login/signup (e.g. pressed back) →
    // send to dashboard instead.
    if (isLoggedIn && isAuthRoute) {
      return AppRoutes.dashboard;
    }

    // No redirect needed.
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.scanHistory,
      builder: (context, state) => const ScanHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.account,
      builder: (context, state) => const AccountScreen(),
    ),
    GoRoute(
      path: AppRoutes.myAccount,
      builder: (context, state) => const MyAccountScreen(),
    ),
    // GoRoute(
    //   path: AppRoutes.liveScan,
    //   builder: (context, state) => const LiveScanScreen(),
    // ),
    GoRoute(
      path: AppRoutes.captureImage,
      builder: (context, state) => const CaptureImageScreen(),
    ),
    // GoRoute(
    //   path: AppRoutes.scanResults,
    //   builder: (context, state) {
    //     final extra = state.extra as Map<String, dynamic>;
    //     return ScanResultsScreen(scanData: extra);
    //   },
    // ),
    GoRoute(
      path: AppRoutes.scanResults,
      builder: (context, state) {
        final args = state.extra as ScanResultsArgs;
        return ScanResultsScreen(args: args);
      },
    ),
    GoRoute(
      path: AppRoutes.historyResult,
      builder: (context, state) {
        final args = state.extra as HistoryResultArgs;
        return HistoryResultScreen(args: args);
      },
    ),
  ],
);

// ============================================================
// APP
// ============================================================

class ThesisApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const ThesisApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'thesis-app',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
      // ── Localization ──────────────────────────────────────
      locale: themeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('en'), Locale('fil')],
    );
  }
}