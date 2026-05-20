// login_screen.dart

import 'package:flutter/material.dart';
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
        Text(
          'Log In',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            fontFamily: 'Onest',
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmailField(colors),
              const SizedBox(height: AppSpacing.lg),
              _buildPasswordField(colors),
              const SizedBox(height: AppSpacing.xl),
              _buildLoginButton(colors),
              const SizedBox(height: AppSpacing.md),
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: 14, color: colors.textPrimary),
          decoration: _inputDecoration(colors, hint: 'johndoe123@gmail.com'),
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: _onForgotPassword,
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.primaryDark,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.primaryDark,
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
          style: TextStyle(fontSize: 14, color: colors.textPrimary),
          decoration: _inputDecoration(colors, hint: '••••••••••').copyWith(
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
          disabledBackgroundColor: colors.primaryDark.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
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
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
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
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google 'G' logo — drawn with colored arcs, no external package needed
            _GoogleLogo(size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Log In with Google',
              style: TextStyle(
                fontSize: 15,
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
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5,  size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 40,
      size.width,        size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BottomWaveClipper old) => false;
}

// ============================================================
// GOOGLE LOGO — four-color 'G', no external packages
// ============================================================

class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r  = size.width / 2;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Blue arc (top-right, going clockwise)
    canvas.drawArc(
      rect, -1.57, 1.57, false,
      Paint()
        ..color  = const Color(0xFF4285F4)
        ..style  = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22
        ..strokeCap = StrokeCap.butt,
    );

    // Red arc (top-left)
    canvas.drawArc(
      rect, -3.14, 1.57, false,
      Paint()
        ..color  = const Color(0xFFEA4335)
        ..style  = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22
        ..strokeCap = StrokeCap.butt,
    );

    // Yellow arc (bottom-left)
    canvas.drawArc(
      rect, 1.57, 0.8, false,
      Paint()
        ..color  = const Color(0xFFFBBC05)
        ..style  = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22
        ..strokeCap = StrokeCap.butt,
    );

    // Green arc (bottom-right)
    canvas.drawArc(
      rect, 2.37, 0.78, false,
      Paint()
        ..color  = const Color(0xFF34A853)
        ..style  = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22
        ..strokeCap = StrokeCap.butt,
    );

    // White horizontal bar for the 'G' cut-out
    final barPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.height * 0.22
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r, cy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}