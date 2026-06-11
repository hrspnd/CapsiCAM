// myaccount_screen.dart

import 'package:flutter/material.dart';
import '../../constants.dart';
import 'package:go_router/go_router.dart';
import 'package:thesis_app/l10n/app_localizations.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  // ── Supabase data ─────────────────────────────────────────
  // TODO: Replace with real data from Supabase Auth
  // final user = Supabase.instance.client.auth.currentUser;
  // final String _userName = user?.userMetadata?['display_name'] ?? '';
  // final String _userEmail = user?.email ?? '';
  // final String _dateCreated = user?.createdAt != null
  //     ? DateFormat('MMM d, yyyy').format(DateTime.parse(user!.createdAt))
  //     : '';

  void _onBack() {
    context.pop();
  }  

  final String _userName = 'John Doe';
  final String _userEmail = 'johndoe123@gmail.com';
  final String _dateCreated = 'Apr 20, 2026';

  // ── Edit profile photo sheet ───────────────────────────────
  void _showEditProfilePhotoSheet(AppColors colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colors.border,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: colors.border),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                          itemCount: 16,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.primaryLightest,
                                  border: Border.all(
                                    color: index == 0
                                        ? colors.primaryDark
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: colors.primaryDark,
                                      size: 28,
                                    ),
                                    if (index == 0)
                                      Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: colors.primaryDark,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg),
                          child: Divider(color: colors.border),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                          itemCount: 28,
                          itemBuilder: (context, index) {
                            final placeholderColors = [
                              const Color(0xFFFFE082),
                              const Color(0xFFFFCC80),
                              const Color(0xFFFFAB91),
                              const Color(0xFFEF9A9A),
                              const Color(0xFFF48FB1),
                              const Color(0xFFCE93D8),
                              const Color(0xFFB39DDB),
                              const Color(0xFF9FA8DA),
                              const Color(0xFF90CAF9),
                              const Color(0xFF81D4FA),
                              const Color(0xFF80DEEA),
                              const Color(0xFF80CBC4),
                              const Color(0xFFA5D6A7),
                              const Color(0xFFC5E1A5),
                              const Color(0xFFE6EE9C),
                              const Color(0xFFFFF59D),
                              const Color(0xFFFFCC00),
                              const Color(0xFFFF9800),
                              const Color(0xFFFF5722),
                              const Color(0xFFE91E63),
                              const Color(0xFF9C27B0),
                              const Color(0xFF3F51B5),
                              const Color(0xFF2196F3),
                              const Color(0xFF009688),
                              const Color(0xFF4CAF50),
                              const Color(0xFF8BC34A),
                              const Color(0xFF607D8B),
                              const Color(0xFF795548),
                            ];
                            final color =
                                placeholderColors[index % placeholderColors.length];
                            return GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                  border: Border.all(
                                    color: Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'MJ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Edit name dialog ──────────────────────────────────────
  void _showEditNameDialog(AppColors colors) {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController(text: _userName);
  String? nameError;
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: colors.surface,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            l10n.editDisplayName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Onest',
              color: colors.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(fontSize: 14, color: colors.textPrimary),
                  onChanged: (_) {
                    if (nameError != null) {
                      setDialogState(() => nameError = null);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.nameLabel,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: nameError != null
                            ? colors.danger
                            : colors.border,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: nameError != null
                            ? colors.danger
                            : colors.primary,
                      ),
                    ),
                  ),
                ),
                if (nameError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    nameError!,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Onest',
                      color: colors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final value = controller.text.trim();
                      String? err;

                      if (value.isEmpty) {
                        err = l10n.errorEmptyDisplayName;
                      } else if (value.length < 2) {
                        err = l10n.errorDisplayNameTooShort;
                      } else if (value.length > 32) {
                        err = l10n.errorDisplayNameTooLong;
                      }

                      if (err != null) {
                        setDialogState(() => nameError = err);
                        return;
                      }

                      setDialogState(() => isLoading = true);
                      try {
                        // TODO: Update display name in Supabase
                        // await Supabase.instance.client.auth.updateUser(
                        //   UserAttributes(data: {'display_name': value}),
                        // );
                        await Future.delayed(const Duration(seconds: 1));

                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        _showDisplayNameSuccessSnackbar(colors);
                      } on Exception {
                        setDialogState(() {
                          isLoading = false;
                          nameError = l10n.errorServer;
                        });
                      }
                    },
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Onest',
                      ),
                    ),
            ),
          ],
        );
      },
    ),
  );
}

void _showDisplayNameSuccessSnackbar(AppColors colors) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: colors.textWhite, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            l10n.successDisplayName,
            style: TextStyle(
              fontFamily: 'Onest',
              color: colors.textWhite,
              fontSize: 13,
            ),
          ),
        ],
      ),
      backgroundColor: colors.primaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      margin: const EdgeInsets.all(AppSpacing.lg),
      duration: const Duration(seconds: 3),
    ),
  );
}

  // ── Change password dialog ────────────────────────────────
  // Extracted to _ChangePasswordDialog StatefulWidget below
  void _showChangePasswordDialog(AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(colors: colors),
    );
  }

  // ── UI ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xFFFFE082),
                          child: ClipOval(
                            child: Image.asset(
                              AppAssets.hatAvatar,
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                _userName
                                    .split(' ')
                                    .map((e) => e[0])
                                    .take(2)
                                    .join(),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: colors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _showEditProfilePhotoSheet(colors),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: colors.primaryDark,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Image.asset(
                                  AppAssets.editIcon,
                                  color: Colors.white,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          _userEmail,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionLabel(l10n.editAccount, colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsGroup([
                    _SettingsRow(
                      iconPath: AppAssets.nameIcon,
                      label: l10n.displayNameLabel,
                      value: _userName,
                      colors: colors,
                      iconBgColor: colors.primaryLightest,
                      iconColor: colors.primaryDark,
                      onTap: () => _showEditNameDialog(colors),
                    ),
                    _SettingsRow(
                      iconPath: AppAssets.changePassword,
                      label: l10n.changePassword,
                      colors: colors,
                      iconBgColor: colors.primaryLightest,
                      iconColor: colors.primaryDark,
                      onTap: () => _showChangePasswordDialog(colors),
                    ),
                  ], colors),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionLabel(l10n.accountDetails, colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsGroup([
                    _SettingsRow(
                      iconPath: AppAssets.dateCreated,
                      label: l10n.dateCreated,
                      value: _dateCreated,
                      colors: colors,
                      iconBgColor: colors.about,
                      iconColor: colors.textGray,
                      onTap: () {},
                      tappable: false,
                    ),
                  ], colors),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(AppColors colors) {
    return Container(
      color: colors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 32,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _onBack,
            child: Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Image.asset(
                AppAssets.backIcon,
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'My Account',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              fontFamily: 'Onest',
              color: colors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, AppColors colors) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: colors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> rows, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast) Divider(height: 1, color: colors.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================
// CHANGE PASSWORD DIALOG
// ============================================================

class _ChangePasswordDialog extends StatefulWidget {
  final AppColors colors;

  const _ChangePasswordDialog({required this.colors});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentController  = TextEditingController();
  final _newController      = TextEditingController();
  final _confirmController  = TextEditingController();
  bool _isLoading           = false;

  // ── Error state ───────────────────────────────────────────
  String? _currentError;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────

  bool _validate() {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;
    final l10n = AppLocalizations.of(context)!;

    String? currentErr;
    String? newErr;
    String? confirmErr;

    if (current.isEmpty) {
      currentErr = l10n.errorEmptyCurrentPassword;
    }

    if (newPass.isEmpty) {
      newErr = l10n.errorEmptyNewPassword;
    } else if (newPass.length < 8) {
      newErr = l10n.errorPasswordTooShort;
    } else if (newPass == current && current.isNotEmpty) {
      newErr = l10n.errorSamePassword;
    }

    if (confirm.isEmpty) {
      confirmErr = l10n.errorEmptyConfirmNewPassword;
    } else if (newPass.isNotEmpty && confirm != newPass) {
      confirmErr = l10n.errorPasswordsNoMatch;
    }

    setState(() {
      _currentError = currentErr;
      _newError     = newErr;
      _confirmError = confirmErr;
    });

    return currentErr == null && newErr == null && confirmErr == null;
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _onSave() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    try {
      // TODO: Call Supabase → supabase_service.dart → changePassword()
      // await Supabase.instance.client.auth.updateUser(
      //   UserAttributes(password: _newController.text),
      // );
      await Future.delayed(const Duration(seconds: 1)); // placeholder

      if (!mounted) return;
      Navigator.of(context).pop();
      _showSuccessSnackbar();
    } on Exception catch (e) {
      _handleSupabaseError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSupabaseError(String message) {
    final l10n = AppLocalizations.of(context)!;
    String? currentErr;
    String? newErr;

    if (message.contains('Invalid login credentials') ||
        message.contains('invalid_credentials') ||
        message.contains('wrong password')) {
      currentErr = l10n.errorWrongPassword;
    } else if (message.contains('network') ||
        message.contains('SocketException') ||
        message.contains('connection')) {
      newErr = l10n.errorNetwork;
    } else {
      newErr = l10n.errorServer;
    }

    setState(() {
      _currentError = currentErr;
      _newError     = newErr;
    });
  }

  void _showSuccessSnackbar() {
    final l10n = AppLocalizations.of(context)!;
    final colors = widget.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: colors.textWhite, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.successPasswordChanged,
              style: TextStyle(
                fontFamily: 'Onest',
                color: colors.textWhite,
                fontSize: 13,
              ),
            ),
          ],
        ),
        backgroundColor: colors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Text(
        l10n.changePassword,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Onest',
          color: colors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPasswordField(
            label: l10n.currentPassword,
            controller: _currentController,
            errorText: _currentError,
            colors: colors,
            onChanged: (_) {
              if (_currentError != null) setState(() => _currentError = null);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPasswordField(
            label: l10n.newPassword,
            controller: _newController,
            errorText: _newError,
            colors: colors,
            onChanged: (_) {
              if (_newError != null) setState(() => _newError = null);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPasswordField(
            label: l10n.confirmNewPass,
            controller: _confirmController,
            errorText: _confirmError,
            colors: colors,
            onChanged: (_) {
              if (_confirmError != null) setState(() => _confirmError = null);
            },
          ),
        ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _onSave,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                )
              : Text(
                  'Save',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Onest',
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required AppColors colors,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: true,
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: colors.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: 13, color: colors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: errorText != null ? colors.danger : colors.border,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: errorText != null ? colors.danger : colors.primary,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Onest',
              color: colors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================
// REUSABLE WIDGETS
// ============================================================

class _SettingsRow extends StatelessWidget {
  final String iconPath;
  final String label;
  final String? value;
  final AppColors colors;
  final VoidCallback onTap;
  final Color? iconBgColor;
  final Color? iconColor;
  final bool tappable;

  const _SettingsRow({
    required this.iconPath,
    required this.label,
    required this.colors,
    required this.onTap,
    this.value,
    this.iconBgColor,
    this.iconColor,
    this.tappable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tappable ? onTap : null,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor ?? colors.primaryLightest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  iconPath,
                  color: iconColor ?? colors.primaryDark,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.settings,
                    size: 16,
                    color: iconColor ?? colors.primaryDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: colors.textPrimary),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TextStyle(fontSize: 13, color: colors.infoColor),
              ),
            const SizedBox(width: AppSpacing.xs),
            if (tappable)
              Icon(Icons.chevron_right, color: colors.chevron, size: 18),
          ],
        ),
      ),
    );
  }
}