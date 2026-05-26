// signup_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants.dart';

// ============================================================
// SIGN UP SCREEN
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

  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading              = false;

  // ── Error state ───────────────────────────────────────────
  String? _displayNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  static const int _minDisplayNameLength = 2;
  static const int _minPasswordLength    = 8;

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
    final displayName     = _displayNameController.text.trim();
    final email           = _emailController.text.trim();
    final password        = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? displayNameErr;
    String? emailErr;
    String? passwordErr;
    String? confirmPasswordErr;

    // Display name
    if (displayName.isEmpty) {
      displayNameErr = 'Please enter your display name.';
    } else if (displayName.length < _minDisplayNameLength) {
      displayNameErr =
          'Display name must be at least $_minDisplayNameLength characters.';
    }

    // Email
    if (email.isEmpty) {
      emailErr = 'Please enter your email address.';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emailErr = 'Please enter a valid email address.';
    }

    // Password
    if (password.isEmpty) {
      passwordErr = 'Please enter your password.';
    } else if (password.length < _minPasswordLength) {
      passwordErr = 'Password must be at least $_minPasswordLength characters.';
    }

    // Confirm password
    if (confirmPassword.isEmpty) {
      confirmPasswordErr = 'Please confirm your password.';
    } else if (password.isNotEmpty && confirmPassword != password) {
      confirmPasswordErr = 'Passwords do not match.';
    }

    setState(() {
      _displayNameError     = displayNameErr;
      _emailError           = emailErr;
      _passwordError        = passwordErr;
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
      // TODO: Call Supabase auth → supabase_service.dart → signUpWithEmail()
      // TODO: On success → show success banner, then context.go(AppRoutes.login)
      await Future.delayed(const Duration(seconds: 1)); // placeholder

      if (!mounted) return;
      _showSuccessBanner();
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go(AppRoutes.login);
    } on Exception catch (e) {
      _handleSupabaseError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessBanner() {
    final colors = AppColors.of(context);
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: colors.primaryLightest,
        leading: Icon(Icons.check_circle_outline, color: colors.primaryDark),
        content: Text(
          'Account created! Please check your email to verify your account.',
          style: TextStyle(
            fontSize: 13,
            color: colors.primaryDarker,
            fontFamily: 'Onest',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: Text(
              'OK',
              style: TextStyle(
                color: colors.primaryDark,
                fontWeight: FontWeight.w700,
                fontFamily: 'Onest',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSupabaseError(String message) {
    String? emailErr;
    String? passwordErr;

    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('User already registered') ||
        message.contains('email_exists')) {
      emailErr =
          'An account with this email already exists. Try logging in instead.';
    } else if (message.contains('weak_password') ||
        message.contains('Password should be') ||
        message.contains('password is too weak')) {
      passwordErr =
          'Password is too weak. Please choose a stronger password.';
    } else if (message.contains('network') ||
        message.contains('SocketException') ||
        message.contains('connection')) {
      passwordErr = 'No internet connection. Please check your network.';
    } else {
      passwordErr = 'Something went wrong. Please try again.';
    }

    setState(() {
      _emailError    = emailErr;
      _passwordError = passwordErr;
    });
  }

  Future<void> _onGoogleSignUp() async {
    try {
      // TODO: Call Supabase Google OAuth → supabase_service.dart → signUpWithGoogle()
      // TODO: On success → show success banner, then context.go(AppRoutes.login)
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('cancelled') || msg.contains('canceled')) return; // silent
      setState(() {
        if (msg.contains('network') || msg.contains('SocketException')) {
          _passwordError =
              'No internet connection. Please check your network.';
        } else if (msg.contains('already registered') ||
            msg.contains('already exists') ||
            msg.contains('email_exists')) {
          _passwordError =
              'An account already exists with this Google account. Try logging in instead.';
        } else {
          _passwordError = 'Something went wrong. Please try again.';
        }
      });
    }
  }

  void _onLogin() {
    context.go(AppRoutes.login);
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

  Widget _buildCard(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
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
              const SizedBox(height: AppSpacing.lg),
              _buildDisplayNameField(colors),
              const SizedBox(height: AppSpacing.lg),
              _buildPasswordField(colors),
              const SizedBox(height: AppSpacing.lg),
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
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          decoration: _inputDecoration(
            colors,
            hint: 'Enter your email',
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
          textCapitalization: TextCapitalization.words,
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
          onChanged: (_) {
            if (_displayNameError != null) {
              setState(() => _displayNameError = null);
            }
          },
          decoration: _inputDecoration(
            colors,
            hint: 'Enter your display name',
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
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
          decoration: _inputDecoration(
            colors,
            hint: 'Enter your password',
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
          onChanged: (_) {
            if (_confirmPasswordError != null) {
              setState(() => _confirmPasswordError = null);
            }
          },
          decoration: _inputDecoration(
            colors,
            hint: 'Confirm your password',
            errorText: _confirmPasswordError,
          ).copyWith(
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

  Widget _buildSignUpButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryDark,
          foregroundColor: colors.textWhite,
          disabledBackgroundColor:
              colors.primaryDark.withValues(alpha: 0.6),
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
              AppAssets.googleIcon,
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