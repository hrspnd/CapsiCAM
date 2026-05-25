// login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../constants.dart';

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword     = true;
  bool _isLoading           = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _onLogin() async {
    // TODO: Validate fields
    // TODO: Call Supabase auth → supabase_service.dart → signInWithEmail()
    // TODO: On success → context.go(AppRoutes.dashboard)
    // TODO: On error   → show SnackBar with error message
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // placeholder
    setState(() => _isLoading = false);
  }

  void _onForgotPassword() {
    // TODO: context.push(AppRoutes.forgotPassword)
    // or show a bottom sheet / dialog
  }

  void _onGoogleSignIn() {
    // TODO: Call Supabase Google OAuth → supabase_service.dart → signInWithGoogle()
    // TODO: On success → context.go(AppRoutes.dashboard)
  }

  void _onSignUp() {
    context.push(AppRoutes.signup);
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWaveHeader(colors),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xxl,
              ),
              child: _buildCard(colors),
            ),
          ],
        ),
      ),
    );
  }

  // ── Wave header ───────────────────────────────────────────

  Widget _buildWaveHeader(AppColors colors) {
    return ClipPath(
      clipper: _BottomWaveClipper(),
      child: Container(
        height: 160,
        width: double.infinity,
        color: colors.primary,
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────

  Widget _buildCard(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
          'Log In',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            fontFamily: 'Onest',
            color: colors.textPrimary,
          ),
        ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 22,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmailField(colors),
              const SizedBox(height: AppSpacing.xl),
              _buildPasswordField(colors),
              const SizedBox(height: AppSpacing.xxl),
              _buildLoginButton(colors),
              const SizedBox(height: AppSpacing.lg),
              _buildSignUpRow(colors),
              const SizedBox(height: AppSpacing.lg),
              _buildDivider(colors),
              const SizedBox(height: AppSpacing.lg),
              _buildGoogleButton(colors),
            ],
          ),
        ),
      ],
    );
  }

  // ── Email field ───────────────────────────────────────────

  Widget _buildEmailField(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.primaryDarker,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
          decoration: _inputDecoration(colors, hint: 'Enter your email'),
        ),
      ],
    );
  }

  // ── Password field ────────────────────────────────────────

  Widget _buildPasswordField(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.primaryDarker,
              ),
            ),
            GestureDetector(
              onTap: _onForgotPassword,
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: colors.primaryDarker,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1.7,
                  decorationColor: colors.primaryDarker,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onLogin(),
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
          decoration: _inputDecoration(colors, hint: 'Enter your password').copyWith(
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: colors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Log In button ─────────────────────────────────────────

  Widget _buildLoginButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryDark,
          foregroundColor: colors.textWhite,
          disabledBackgroundColor: colors.primaryDark.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.textWhite,
                ),
              )
            : Text(
                'Log In',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.textWhite,
                ),
              ),
      ),
    );
  }

  // ── Sign up row ───────────────────────────────────────────

  Widget _buildSignUpRow(AppColors colors) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 13, color: colors.textSecondary, fontFamily: 'Onest'),
          children: [
            const TextSpan(text: "Don't have an account? "),
            WidgetSpan(
              child: GestureDetector(
                onTap: _onSignUp,
                child: Text(
                  'Sign up here',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Or divider ────────────────────────────────────────────

  Widget _buildDivider(AppColors colors) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or',
            style: TextStyle(fontSize: 13, color: colors.textSecondary, fontFamily: 'Onest'),
          ),
          ),

        Expanded(child: Divider(color: colors.border, thickness: 1)),
      ],
    );
  }

  // ── Google button ─────────────────────────────────────────

  Widget _buildGoogleButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _onGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border),
          foregroundColor: colors.textPrimary,
          backgroundColor: colors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/google.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Log In with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared input decoration ───────────────────────────────

  InputDecoration _inputDecoration(AppColors colors, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: colors.textSecondary),
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.danger, width: 1.5),
      ),
    );
  }
}

// ============================================================
// WAVE CLIPPER
// ============================================================

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width * 0.15, size.height - 90,
      size.width * 0.52,  size.height - 22,
    );
    path.cubicTo(
      size.width * 0.60, size.height - 8,  
      size.width * 0.82, size.height + 20,  
      size.width,        size.height - 26,  
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
 
  @override
  bool shouldReclip(_BottomWaveClipper old) => false;
}