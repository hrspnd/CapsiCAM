// signup_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import 'package:thesis_app/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// SIGN UP SCREEN
// ============================================================

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // ── Error state ───────────────────────────────────────────
  String? _displayNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  static const int _minDisplayNameLength = 2;
  static const int _minPasswordLength = 8;

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────

  bool _validate() {
    final l10n = AppLocalizations.of(context)!;
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? displayNameErr;
    String? emailErr;
    String? passwordErr;
    String? confirmPasswordErr;

    // Display name
    if (displayName.isEmpty) {
      displayNameErr = l10n.errorEmptyDisplayName;
    } else if (displayName.length < _minDisplayNameLength) {
      displayNameErr = l10n.errorDisplayNameTooShort;
    }

    // Email
    if (email.isEmpty) {
      emailErr = l10n.errorEmptyEmail;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emailErr = l10n.errorInvalidEmail;
    }

    // Password
    if (password.isEmpty) {
      passwordErr = l10n.errorEmptyPassword;
    } else if (password.length < _minPasswordLength) {
      passwordErr = l10n.errorPasswordTooShort;
    }

    // Confirm password
    if (confirmPassword.isEmpty) {
      confirmPasswordErr = l10n.errorEmptyConfirmPassword;
    } else if (password.isNotEmpty && confirmPassword != password) {
      confirmPasswordErr = l10n.errorPasswordsNoMatch;
    }

    setState(() {
      _displayNameError = displayNameErr;
      _emailError = emailErr;
      _passwordError = passwordErr;
      _confirmPasswordError = confirmPasswordErr;
    });

    return displayNameErr == null &&
        emailErr == null &&
        passwordErr == null &&
        confirmPasswordErr == null;
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _onSignUp() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    try {
      await SupabaseService().signUpWithEmail(
        fullName: _displayNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      _showSuccessBanner();
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    } on AuthException catch (e) {
      debugPrint('AuthException during signup: ${e.message}');
      _handleSupabaseError(e.message);
    } catch (e, stackTrace) {
      debugPrint('Unexpected error during signup: $e');
      debugPrint('$stackTrace');
      _handleSupabaseError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessBanner() {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    // Clear out any lingering/queued snack bars first so we're never
    // dismissing (or leaving behind) the wrong one.
    messenger.clearSnackBars();

    // Keep a handle to *this specific* snack bar instance so both the
    // OK button and our manual timer close exactly this one.
    late final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
        controller;

    controller = messenger.showSnackBar(
      SnackBar(
        backgroundColor: colors.primaryLightest,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom:
              MediaQuery.of(context).padding.bottom +
              70, // ← lifts it above the bottom nav
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        // NOTE: SnackBar's built-in `duration` auto-dismiss is skipped
        // by Flutter when accessible/screen-reader navigation is on,
        // and can also get cut short by rebuilds. We don't rely on it —
        // see the Timer below, which force-closes this exact snack bar
        // after 3 seconds regardless.
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: colors.primaryDark),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              // ← this is what prevents overflow on long text
              child: Text(
                l10n.accountCreated,
                style: TextStyle(
                  color: colors.primaryDarker,
                  fontFamily: 'Onest',
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: colors.primaryDark,
          onPressed: () => controller.close(),
        ),
      ),
    );

    Timer(const Duration(seconds: 4), () => controller.close());
  }

  void _handleSupabaseError(String message) {
    final l10n = AppLocalizations.of(context)!;
    String? emailErr;
    String? passwordErr;

    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('User already registered') ||
        message.contains('email_exists')) {
      emailErr = l10n.errorEmailInUse;
    } else if (message.contains('rate limit') ||
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
      _emailError = emailErr;
      _passwordError = passwordErr;
    });
  }

  void _onLogin() {
    context.go(AppRoutes.login);
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

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

  // ── Wave header (horizontally flipped) ───────────────────

  Widget _buildWaveHeader(AppColors colors) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
      child: ClipPath(
        clipper: _BottomWaveClipper(),
        child: Container(
          height: 150,
          width: double.infinity,
          color: colors.primary,
        ),
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────

  Widget _buildCard(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Text(
            l10n.signUpTitle,
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
              const SizedBox(height: AppSpacing.lg),
              _buildDisplayNameField(colors, l10n),
              const SizedBox(height: AppSpacing.lg),
              _buildPasswordField(colors, l10n),
              const SizedBox(height: AppSpacing.lg),
              _buildConfirmPasswordField(colors, l10n),
              const SizedBox(height: AppSpacing.xxl),
              _buildSignUpButton(colors, l10n),
              const SizedBox(height: AppSpacing.lg),
              _buildLoginRow(colors, l10n),
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
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          decoration: _inputDecoration(
            colors,
            hint: l10n.emailHint,
            errorText: _emailError,
          ),
        ),
        if (_emailError != null) ...[
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              _emailError!,
              style: TextStyle(
                fontSize: 12,
                color: colors.danger,
                fontFamily: 'Onest',
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Display name field ────────────────────────────────────

  Widget _buildDisplayNameField(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.displayNameLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.textGreen,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _displayNameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
          onChanged: (_) {
            if (_displayNameError != null) {
              setState(() => _displayNameError = null);
            }
          },
          decoration: _inputDecoration(
            colors,
            hint: l10n.displayNameHint,
            errorText: _displayNameError,
          ),
        ),
        if (_displayNameError != null) ...[
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              _displayNameError!,
              style: TextStyle(
                fontSize: 12,
                color: colors.danger,
                fontFamily: 'Onest',
              ),
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
        Text(
          'Password',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.textGreen,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
          decoration:
              _inputDecoration(
                colors,
                hint: l10n.passwordHint,
                errorText: _passwordError,
              ).copyWith(
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
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
              style: TextStyle(
                fontSize: 12,
                color: colors.danger,
                fontFamily: 'Onest',
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Confirm password field ────────────────────────────────

  Widget _buildConfirmPasswordField(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.confirmPasswordLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.textGreen,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onSignUp(),
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
          onChanged: (_) {
            if (_confirmPasswordError != null) {
              setState(() => _confirmPasswordError = null);
            }
          },
          decoration:
              _inputDecoration(
                colors,
                hint: l10n.confirmPasswordHint,
                errorText: _confirmPasswordError,
              ).copyWith(
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
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
        if (_confirmPasswordError != null) ...[
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              _confirmPasswordError!,
              style: TextStyle(
                fontSize: 12,
                color: colors.danger,
                fontFamily: 'Onest',
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Sign Up button ────────────────────────────────────────

  Widget _buildSignUpButton(AppColors colors, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSignUp,
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
                l10n.signUpButton,
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

  Widget _buildLoginRow(AppColors colors, AppLocalizations l10n) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
            fontFamily: 'Onest',
          ),
          children: [
            TextSpan(text: l10n.alreadyHaveAccount),
            WidgetSpan(
              child: GestureDetector(
                onTap: _onLogin,
                child: Text(
                  l10n.loginHere,
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

  // ── Shared input decoration ───────────────────────────────

  InputDecoration _inputDecoration(
    AppColors colors, {
    required String hint,
    String? errorText,
  }) {
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
// WAVE CLIPPER  (same path as LoginScreen — flipped via Transform)
// ============================================================

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height - 90,
      size.width * 0.52,
      size.height - 22,
    );
    path.cubicTo(
      size.width * 0.60,
      size.height - 8,
      size.width * 0.82,
      size.height + 20,
      size.width,
      size.height - 26,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BottomWaveClipper old) => false;
}