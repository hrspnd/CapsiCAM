// myaccount_screen.dart

import 'package:flutter/material.dart';
import '../../constants.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/l10n/app_localizations.dart';
import 'package:thesis_app/services/supabase_service.dart';
import 'package:thesis_app/services/profile_refresh_bus.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  // ── Supabase data ─────────────────────────────────────────
  final _supabaseService = SupabaseService();

  late String _userName;
  late String _userEmail;
  late String _dateCreated;

  // Seeded with the schema defaults ('monogram' / '#F5A623') so the
  // avatar circle never flashes something else before _loadAvatar
  // resolves.
  String _avatarType = 'monogram';
  String _avatarValue = '#F5A623';

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _userEmail = user?.email ?? '';
    // Seed with whatever's cheaply available so the screen never
    // flashes placeholder text, then upgrade with the real profile
    // name (see _loadProfile).
    _userName =
        (user?.userMetadata?['full_name'] as String?)?.trim().isNotEmpty ==
            true
        ? (user!.userMetadata!['full_name'] as String)
        : (user?.email?.split('@').first ?? 'User');
    _dateCreated = user?.createdAt != null
        ? DateFormat('MMM d, yyyy').format(
            DateTime.parse(user!.createdAt).toLocal(),
          )
        : '';
    _loadProfile();
    _loadAvatar();
  }

  Future<void> _loadProfile() async {
    try {
      final fullName = await _supabaseService.fetchFullName();
      if (!mounted || fullName == null || fullName.trim().isEmpty) return;
      setState(() => _userName = fullName);
    } catch (_) {
      // Non-critical: keep the metadata/email-derived name we already
      // have rather than surfacing an error for a profile-name lookup.
    }
  }

  Future<void> _loadAvatar() async {
    try {
      final avatar = await _supabaseService.fetchAvatar();
      if (!mounted || avatar == null) return;
      setState(() {
        _avatarType = avatar.type;
        _avatarValue = avatar.value;
      });
    } catch (_) {
      // Non-critical: keep the default avatar rather than surfacing
      // an error for what's ultimately a cosmetic lookup.
    }
  }

  String get _userInitials {
    final trimmed = _userName.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  // Set true whenever a change actually saves successfully, so _onBack
  // only tells other screens to refresh when there's something to see.
  bool _hasChanges = false;

  /// Renders the current avatar (icon-on-color or monogram) at the
  /// given [diameter]. Shared by the profile header and the picker
  /// sheet's "current selection" preview. Thin wrapper around the
  /// shared [UserAvatar] widget (also used by the dashboard and
  /// account screens) so all three stay visually in sync.
  Widget _buildAvatarCircle({
    required AppColors colors,
    required double diameter,
    String? type,
    String? value,
  }) {
    return UserAvatar(
      colors: colors,
      avatarType: type ?? _avatarType,
      avatarValue: value ?? _avatarValue,
      diameter: diameter,
      initials: _userInitials,
    );
  }

  void _onBack() {
    context.pop();
  }

  // ── Edit profile photo sheet ───────────────────────────────
  void _showEditProfilePhotoSheet(AppColors colors) {
    // Local, pending selection — only written back to Supabase (and
    // to _avatarType/_avatarValue) if the user taps Save.
    String pendingType = _avatarType;
    String pendingValue = _avatarValue;
    bool isSaving = false;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> onSave() async {
              setSheetState(() {
                isSaving = true;
                errorText = null;
              });
              try {
                await _supabaseService.updateAvatar(
                  avatarType: pendingType,
                  avatarValue: pendingValue,
                );
                if (!mounted) return;
                setState(() {
                  _avatarType = pendingType;
                  _avatarValue = pendingValue;
                  _hasChanges = true;
                });
                Navigator.pop(sheetContext);
                _showAvatarSuccessSnackbar(colors);
              } catch (e) {
                final isOffline = e.toString().contains('offline');
                setSheetState(() {
                  isSaving = false;
                  errorText = isOffline
                      ? 'You appear to be offline. Please try again.'
                      : 'Could not save your avatar. Please try again.';
                });
              }
            }

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
                              margin:
                                  const EdgeInsets.only(bottom: AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: colors.border,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: isSaving
                                    ? null
                                    : () => Navigator.pop(sheetContext),
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
                                onPressed: isSaving ? null : onSave,
                                child: isSaving
                                    ? SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.primary,
                                        ),
                                      )
                                    : Text(
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
                          if (errorText != null) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                errorText!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.danger,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
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
                              itemCount: AppAvatarIcons.names.length,
                              itemBuilder: (context, index) {
                                final name = AppAvatarIcons.names[index];
                                final isSelected = pendingType == 'icon' &&
                                    pendingValue == name;
                                return GestureDetector(
                                  onTap: isSaving
                                      ? null
                                      : () => setSheetState(() {
                                            pendingType = 'icon';
                                            pendingValue = name;
                                          }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.primaryDark
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ClipOval(
                                          child: SizedBox.expand(
                                            child: Image.asset(
                                              AppAvatarIcons.path(name),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  CircleAvatar(
                                                backgroundColor:
                                                    colors.primaryLightest,
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  color: colors.primaryDark,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
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
                              itemCount: AppAvatarColors.palette.length,
                              itemBuilder: (context, index) {
                                final hex = AppAvatarColors.palette[index];
                                final isSelected = pendingType == 'monogram' &&
                                    pendingValue.toUpperCase() ==
                                        hex.toUpperCase();
                                return GestureDetector(
                                  onTap: isSaving
                                      ? null
                                      : () => setSheetState(() {
                                            pendingType = 'monogram';
                                            pendingValue = hex;
                                          }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppAvatarColors.fromHex(hex),
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.primaryDark
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(
                                          _userInitials,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        if (isSelected)
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
      },
    );
  }

  void _showAvatarSuccessSnackbar(AppColors colors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: colors.textWhite, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Avatar updated',
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
                        await _supabaseService.updateFullName(value);

                        if (!context.mounted) return;
                        setState(() {
                          _userName = value;
                          _hasChanges = true;
                        });
                        Navigator.of(context).pop();
                        _showDisplayNameSuccessSnackbar(colors);
                      } catch (e) {
                        final isOffline = e.toString().contains('offline');
                        setDialogState(() {
                          isLoading = false;
                          nameError = isOffline
                              ? l10n.errorNetwork
                              : l10n.errorServer;
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

    // Wrapping in PopScope (rather than only notifying inside the
    // in-app back-arrow's onTap) makes sure the dashboard gets told
    // to refresh no matter HOW this screen is left — tapping the
    // arrow, swiping back, or the Android hardware back button. All
    // of those trigger a pop, and PopScope is the one hook that
    // fires for all of them.
    return PopScope<Object?>(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _hasChanges) {
          ProfileRefreshBus.notify();
        }
      },
      child: Scaffold(
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
                        _buildAvatarCircle(colors: colors, diameter: 84),
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
  final _supabaseService = SupabaseService();
  final _currentController  = TextEditingController();
  final _newController      = TextEditingController();
  final _confirmController  = TextEditingController();
  bool _isLoading           = false;

  // ── Error state ───────────────────────────────────────────
  String? _currentError;
  String? _newError;
  String? _confirmError;

  // ── Obscure/visibility state (per field) ────────────────────
  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;

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
      await _supabaseService.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );

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
    } else if (message.contains('offline') ||
        message.contains('network') ||
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
            obscureText: _obscureCurrent,
            onToggleObscure: () =>
                setState(() => _obscureCurrent = !_obscureCurrent),
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
            obscureText: _obscureNew,
            onToggleObscure: () =>
                setState(() => _obscureNew = !_obscureNew),
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
            obscureText: _obscureConfirm,
            onToggleObscure: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
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
    required bool obscureText,
    required VoidCallback onToggleObscure,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
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
            suffixIcon: GestureDetector(
              onTap: onToggleObscure,
              child: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: colors.textSecondary,
                size: 20,
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