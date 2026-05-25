// signup_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants.dart';

// ============================================================
// SIGNUP SCREEN
// ============================================================

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController           = TextEditingController();
  final _displayNameController     = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword            = true;
  bool _obscureConfirmPassword     = true;
  bool _isLoading                  = false;

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _onSignUp() async {
    // TODO: Validate fields
    // TODO: Call Supabase auth → supabase_service.dart → signUpWithEmail()
    // TODO: On success → context.go(AppRoutes.dashboard)
    // TODO: On error   → show SnackBar with error message
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // placeholder
    setState(() => _isLoading = false);
  }

  void _onGoogleSignUp() {
    // TODO: Call Supabase Google OAuth → supabase_service.dart → signInWithGoogle()
    // TODO: On success → context.go(AppRoutes.dashboard)
  }

  void _onLogin() {
    context.pop();
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
      clipper: _TopWaveClipper(),
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
            'Sign Up',
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
              _buildDisplayNameField(colors),
              const SizedBox(height: AppSpacing.xl),
              _buildPasswordField(colors),
              const SizedBox(height: AppSpacing.xl),
              _buildConfirmPasswordField(colors),
              const SizedBox(height: AppSpacing.xxl),
              _buildSignUpButton(colors),
              const SizedBox(height: AppSpacing.lg),
              _buildLoginRow(colors),
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
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
          decoration: _inputDecoration(colors, hint: 'Enter your email'),
        ),
      ],
    );
  }

  // ── Display name field ────────────────────────────────────

  Widget _buildDisplayNameField(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Name',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.primaryDarker,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _displayNameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
          decoration: _inputDecoration(colors, hint: 'Enter your display name'),
        ),
      ],
    );
  }

  // ── Password field ────────────────────────────────────────

  Widget _buildPasswordField(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.primaryDarker,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
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

  // ── Confirm password field ────────────────────────────────

  Widget _buildConfirmPasswordField(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.primaryDarker,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onSignUp(),
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
          decoration: _inputDecoration(colors, hint: 'Re-enter your password').copyWith(
            suffixIcon: GestureDetector(
              onTap: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
              child: Icon(
                _obscureConfirmPassword
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

  // ── Sign Up button ────────────────────────────────────────

  Widget _buildSignUpButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSignUp,
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
                'Sign Up',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.textWhite,
                ),
              ),
      ),
    );
  }

  // ── Login row ─────────────────────────────────────────────

  Widget _buildLoginRow(AppColors colors) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
            fontFamily: 'Onest',
          ),
          children: [
            const TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: _onLogin,
                child: Text(
                  'Login here',
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
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              fontFamily: 'Onest',
            ),
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
        onPressed: _onGoogleSignUp,
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
              'Sign Up with Google',
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
// WAVE CLIPPER — horizontally flipped from login
// Mirror rule: every control x → (size.width - original_x)
// Path is redrawn right-to-left so the shape is a true mirror
// ============================================================

class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start at left edge — same Y as login's right edge
    path.lineTo(0, size.height - 26);
    // Cubic — mirrors login's cubic (c1/c2/end x values flipped)
    path.cubicTo(
      size.width * 0.18, size.height + 20, // mirror of 0.82
      size.width * 0.40, size.height - 8,  // mirror of 0.60
      size.width * 0.48, size.height - 22, // mirror of 0.52 midpoint
    );
    // Quad — mirrors login's quadratic (control/end x values flipped)
    path.quadraticBezierTo(
      size.width * 0.85, size.height - 90, // mirror of 0.15
      size.width,        size.height - 30, // mirror of left edge start
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_TopWaveClipper old) => false;
}