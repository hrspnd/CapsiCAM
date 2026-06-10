// login_screen.dart

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
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

  // ── Error state ───────────────────────────────────────────
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────

  bool _validate() {
    final l10n     = AppLocalizations.of(context)!;
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    String? emailErr;
    String? passwordErr;

    if (email.isEmpty) {
      emailErr = l10n.errorEmptyEmail;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emailErr = l10n.errorInvalidEmail;
    }

    if (password.isEmpty) {
      passwordErr = l10n.errorEmptyPassword;
    }

    setState(() {
      _emailError    = emailErr;
      _passwordError = passwordErr;
    });

    return emailErr == null && passwordErr == null;
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _onLogin() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    try {
      // TODO: Call Supabase auth → supabase_service.dart → signInWithEmail()
      // TODO: On success → context.go(AppRoutes.dashboard)
      await Future.delayed(const Duration(seconds: 1)); // placeholder
      
    } on Exception catch (e) {
      _handleSupabaseError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSupabaseError(String message) {
    final l10n = AppLocalizations.of(context)!;
    String? emailErr;
    String? passwordErr;

    if (message.contains('Invalid login credentials') ||
        message.contains('invalid_credentials')) {
      passwordErr = l10n.errorWrongPassword;
    } else if (message.contains('user not found') ||
        message.contains('User not found')) {
      emailErr = l10n.errorEmailNotFound;
    } else if (message.contains('email not confirmed') ||
        message.contains('Email not confirmed')) {
      emailErr = l10n.errorEmailNotVerified;
    } else if (message.contains('too many requests') ||
        message.contains('over_email_send_rate_limit')) {
      passwordErr = l10n.errorTooManyAttempts;
    } else if (message.contains('network') ||
        message.contains('SocketException') ||
        message.contains('connection')) {
      passwordErr = l10n.errorNetwork;
    } else {
      passwordErr = l10n.errorServer;
    }

    setState(() {
      _emailError    = emailErr;
      _passwordError = passwordErr;
    });
  }

  void _onForgotPassword() {
    // TODO: context.push(AppRoutes.forgotPassword)
    // or show a bottom sheet / dialog
  }

  Future<void> _onGoogleSignIn() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // TODO: Call Supabase Google OAuth → supabase_service.dart → signInWithGoogle()
      // TODO: On success → context.go(AppRoutes.dashboard)
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('cancelled') || msg.contains('canceled')) return;
      setState(() {
        if (msg.contains('network') || msg.contains('SocketException')) {
          _passwordError = l10n.errorNetwork;
        } else if (msg.contains('not found') || msg.contains('no account')) {
          _passwordError = l10n.errorGoogleNoAccount;
        } else {
          _passwordError = l10n.errorServer;
        }
      });
    }
  }

  void _onSignUp() {
    context.push(AppRoutes.signup);
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n   = AppLocalizations.of(context)!;

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
              child: _buildCard(colors, l10n),
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
        height: 155,
        width: double.infinity,
        color: colors.primary,
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────

  Widget _buildCard(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            l10n.loginTitle,
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
              _buildEmailField(colors, l10n),
              const SizedBox(height: AppSpacing.xl),
              _buildPasswordField(colors, l10n),
              const SizedBox(height: AppSpacing.xxl),
              _buildLoginButton(colors, l10n),
              const SizedBox(height: AppSpacing.lg),
              _buildSignUpRow(colors, l10n),
              const SizedBox(height: AppSpacing.lg),
              _buildDivider(colors, l10n),
              const SizedBox(height: AppSpacing.lg),
              _buildGoogleButton(colors, l10n),
            ],
          ),
        ),
      ],
    );
  }

  // ── Email field ───────────────────────────────────────────

  Widget _buildEmailField(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.textGreen,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
          onChanged: (_) { if (_emailError != null) setState(() => _emailError = null); },
          decoration: _inputDecoration(colors, hint: l10n.emailHint, errorText: _emailError),
        ),
        if (_emailError != null) ...[
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              _emailError!,
              style: TextStyle(fontSize: 12, color: colors.danger, fontFamily: 'Onest'),
            ),
          ),
        ],
      ],
    );
  }

  // ── Password field ────────────────────────────────────────

  Widget _buildPasswordField(AppColors colors, AppLocalizations l10n) {
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
                color: colors.textGreen,
              ),
            ),
            GestureDetector(
              onTap: _onForgotPassword,
              child: Text(
                l10n.forgotPassword,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: colors.textGreen,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1.7,
                  decorationColor: colors.textGreen,
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
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
          onChanged: (_) { if (_passwordError != null) setState(() => _passwordError = null); },
          decoration: _inputDecoration(colors, hint: l10n.passwordHint, errorText: _passwordError).copyWith(
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
        if (_passwordError != null) ...[
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              _passwordError!,
              style: TextStyle(fontSize: 12, color: colors.danger, fontFamily: 'Onest'),
            ),
          ),
        ],
      ],
    );
  }

  // ── Log In button ─────────────────────────────────────────

  Widget _buildLoginButton(AppColors colors, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.buttonBg,
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
                l10n.logInButton,
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

  Widget _buildSignUpRow(AppColors colors, AppLocalizations l10n) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 13, color: colors.textSecondary, fontFamily: 'Onest'),
          children: [
            TextSpan(text: l10n.noAccount),
            WidgetSpan(
              child: GestureDetector(
                onTap: _onSignUp,
                child: Text(
                  l10n.signUpHere,
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

  Widget _buildDivider(AppColors colors, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            l10n.orDivider,
            style: TextStyle(fontSize: 13, color: colors.textSecondary, fontFamily: 'Onest'),
          ),
        ),
        Expanded(child: Divider(color: colors.border, thickness: 1)),
      ],
    );
  }

  // ── Google button ─────────────────────────────────────────

  Widget _buildGoogleButton(AppColors colors, AppLocalizations l10n) {
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
              AppAssets.googleIcon,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              l10n.logInWithGoogle,
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

  InputDecoration _inputDecoration(AppColors colors, {required String hint, String? errorText}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: colors.textSecondary),
      errorText: errorText != null ? '' : null,
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      errorMaxLines: 1,
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