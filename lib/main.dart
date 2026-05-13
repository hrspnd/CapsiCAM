import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/account/account_screen.dart';

// ============================================================
// SUPABASE INIT — add your credentials here when ready
// ============================================================
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Supabase.initialize(
//     url: 'YOUR_SUPABASE_URL',
//     anonKey: 'YOUR_SUPABASE_ANON_KEY',
//   );
//   runApp(const ThesisApp());
// }

void main() {
  runApp(const ThesisApp());
}

// ============================================================
// ROUTER
// ============================================================

final _router = GoRouter(
  // TODO: Change initialLocation to AppRoutes.login when auth is ready
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
  ],
);

// ============================================================
// APP
// ============================================================

class ThesisApp extends StatelessWidget {
  const ThesisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C9585),
        ),
        fontFamily: 'Onest',
        scaffoldBackgroundColor: const Color(0xFFF5F5F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C9585),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      routerConfig: _router,
    );
  }
}
