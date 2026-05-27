// myaccount_screen.dart

import 'package:flutter/material.dart';
import '../../constants.dart';

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

  final String _userName = 'John Doe';
  final String _userEmail = 'johndoe123@gmail.com';
  final String _dateCreated = 'Apr 20, 2026';

  // ── Edit profile photo sheet ───────────────────────────────
  void _showEditProfilePhotoSheet(AppColors colors) {
    // TODO: Replace placeholder grid with actual avatar icons and color options
    // Icons: 16 custom avatar icons from assets
    // Colors: 28 gradient/solid color options
    // On select: update user avatar in Supabase Storage
    // await Supabase.instance.client.storage.from('avatars').upload(...)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                              // TODO: Save selected avatar to Supabase
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
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Custom icons grid ──────────────────
                        // TODO: Replace with real icon assets when available
                        // 16 icons total, 4 per row
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
                            // TODO: Replace with actual avatar icon assets
                            // e.g. Image.asset(AppAssets.avatarIcons[index])
                            return GestureDetector(
                              onTap: () {
                                // TODO: Set selected icon
                              },
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

                        // ── Divider between icons and colors ───
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg),
                          child: Divider(color: colors.border),
                        ),

                        // ── Color options grid ─────────────────
                        // 28 colors total, 4 per row
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
                            // TODO: Replace with actual color/gradient options
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
                            final color = placeholderColors[
                                index % placeholderColors.length];
                            return GestureDetector(
                              onTap: () {
                                // TODO: Set selected background color
                              },
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
                                    // TODO: Replace with user initials
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
    final controller = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Edit Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(fontSize: 14, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: colors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Update display name in Supabase
              // await Supabase.instance.client.auth.updateUser(
              //   UserAttributes(data: {'display_name': controller.text.trim()}),
              // );
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Change password dialog ────────────────────────────────
  void _showChangePasswordDialog(AppColors colors) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _passwordField('Current Password', currentController, colors),
            const SizedBox(height: AppSpacing.md),
            _passwordField('New Password', newController, colors),
            const SizedBox(height: AppSpacing.md),
            _passwordField('Confirm New Password', confirmController, colors),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Validate and update password via Supabase
              // await Supabase.instance.client.auth.updateUser(
              //   UserAttributes(password: newController.text.trim()),
              // );
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(
      String label, TextEditingController controller, AppColors colors) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(fontSize: 14, color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: colors.textSecondary),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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
                  // ── Avatar ───────────────────────────────────
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
                        // Edit pencil badge
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
                                border: Border.all(
                                    color: colors.surface, width: 2),
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
                  const SizedBox(height: AppSpacing.md),
                  // ── Name & email ─────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
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

                  // ── Edit Account group ───────────────────────
                  _buildSectionLabel('Edit Account', colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsGroup([
                    _SettingsRow(
                      iconPath: AppAssets.nameIcon,
                      label: 'Name',
                      value: _userName,
                      colors: colors,
                      iconBgColor: colors.primaryLightest,
                      iconColor: colors.primaryDark,
                      onTap: () => _showEditNameDialog(colors),
                    ),
                    _SettingsRow(
                      iconPath: AppAssets.changePassword,
                      label: 'Change Password',
                      colors: colors,
                      iconBgColor: colors.primaryLightest,
                      iconColor: colors.primaryDark,
                      onTap: () => _showChangePasswordDialog(colors),
                    ),
                  ], colors),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Account Details group ────────────────────
                  _buildSectionLabel('Account Details', colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsGroup([
                    _SettingsRow(
                      iconPath: AppAssets.dateCreated,
                      label: 'Date Created',
                      value: _dateCreated,
                      colors: colors,
                      iconBgColor: colors.about,
                      iconColor: colors.textGray,
                      onTap: () {}, // not tappable
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
        top: MediaQuery.of(context).padding.top + AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              AppAssets.backIcon,
              width: 22,
              height: 22,
              color: Colors.white,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text(
            'My Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────
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

  // ── Settings group ────────────────────────────────────────
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
            // Icon
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
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: colors.textPrimary),
              ),
            ),
            // Value
            if (value != null)
              Text(
                value!,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            const SizedBox(width: AppSpacing.xs),
            // Chevron only if tappable
            if (tappable)
              Icon(Icons.chevron_right, color: colors.chevron, size: 18),
          ],
        ),
      ),
    );
  }
}