import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'constants.dart';
import 'theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/account/account_screen.dart';

// ============================================================
// SUPABASE INIT — uncomment and add credentials when ready
// ============================================================
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Supabase.initialize(
//     url: 'YOUR_SUPABASE_URL',
//     anonKey: 'YOUR_SUPABASE_ANON_KEY',
//   );
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: const ThesisApp(),
//     ),
//   );
// }

void main() {
  runApp(
    // ThemeProvider wraps the entire app so any screen can access it
    // Access in any widget: context.read<ThemeProvider>() or
    // watch changes: context.watch<ThemeProvider>()
    _AppWithTheme(),
  );
}

// Simple theme wrapper without extra packages
class _AppWithTheme extends StatefulWidget {
  @override
  State<_AppWithTheme> createState() => _AppWithThemeState();
}

class _AppWithThemeState extends State<_AppWithTheme> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThesisApp(themeProvider: _themeProvider);
  }
}

// ============================================================
// ROUTER
// ============================================================

final _router = GoRouter(

  // TODO: Change to AppRoutes.login when auth is ready
  
  initialLocation: AppRoutes.dashboard,
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

    // TODO: Uncomment as screens are built
    // GoRoute(
    //   path: AppRoutes.liveScan,
    //   builder: (context, state) => const LiveScanScreen(),
    // ),
    // GoRoute(
    //   path: AppRoutes.captureImage,
    //   builder: (context, state) => const CaptureImageScreen(),
    // ),
    // GoRoute(
    //   path: AppRoutes.scanResults,
    //   builder: (context, state) {
    //     final extra = state.extra as Map<String, dynamic>;
    //     return ScanResultsScreen(scanData: extra);
    //   },
    // ),
    // GoRoute(
    //   path: AppRoutes.myAccount,
    //   builder: (context, state) => const MyAccountScreen(),
    // ),
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
    );
  }
}
