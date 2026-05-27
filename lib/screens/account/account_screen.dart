// account_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants.dart';
import '../../theme_provider.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // ── Supabase data ─────────────────────────────────────────
  // TODO: Replace with real data from Supabase Auth
  // final user = Supabase.instance.client.auth.currentUser;
  // final String _userName = user?.userMetadata?['display_name'] ?? '';
  // final String _userEmail = user?.email ?? '';

  final String _userName = 'John Doe';
  final String _userEmail = 'johndoe123@gmail.com';

  // ── Theme ─────────────────────────────────────────────────
  String _currentThemeLabel(BuildContext context) {
    final mode = context.watch<ThemeProvider>().themeMode;
    if (mode == ThemeMode.dark) return 'Dark';
    if (mode == ThemeMode.system) return 'System';
    return 'Light';
  }

  // ── Language ──────────────────────────────────────────────
  // TODO: Replace with LanguageProvider when language mode is implemented
  String _currentLanguage = 'English';

  // ── Nav index ─────────────────────────────────────────────
  int _currentNavIndex = 2;

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    switch (index) {
      case 0:
        context.push(AppRoutes.scanHistory);
        break;
      case 1:
        context.go(AppRoutes.dashboard);
        break;
      case 2:
        break;
    }
  }

  // ── Bottom sheets ─────────────────────────────────────────
  void _showDisplayModeSheet(AppColors colors) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    String selected;
    if (provider.themeMode == ThemeMode.dark)
      selected = 'Dark';
    else if (provider.themeMode == ThemeMode.system)
      selected = 'System';
    else
      selected = 'Light';
    final options = ['Light', 'Dark', 'System'];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
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
                    Text(
                      'Display Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...options.map((option) {
                      final isSelected = selected == option;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() => selected = option);
                          setState(() {});

                          if (option == 'Dark')
                            provider.setDark();
                          else if (option == 'System')
                            provider.setSystem();
                          else
                            provider.setLight();

                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primaryLightest
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primaryDark
                                  : colors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? colors.primaryDark
                                      : colors.textPrimary,
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_rounded,
                                  color: colors.primaryDark,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguageSheet(AppColors colors) {
    String selected = _currentLanguage;
    final options = ['English', 'Filipino'];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...options.map((option) {
                    final isSelected = selected == option;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() => selected = option);
                        setState(() => _currentLanguage = option);

                        // TODO: Apply language via LanguageProvider
                        // languageProvider.setLanguage(option);

                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primaryLightest
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? colors.primaryDark
                                : colors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? colors.primaryDark
                                    : colors.textPrimary,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_rounded,
                                color: colors.primaryDark,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'About',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          '____ is a chili pepper leaf disease classification app developed as part of an undergraduate thesis study.\n\nVersion 1.0.0',
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'For questions or issues, please contact your system administrator or refer to the thesis documentation.',
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }

  void _showLogOutDialog(AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
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
              Navigator.pop(context);
              // TODO: Sign out from Supabase then navigate to login
              // await Supabase.instance.client.auth.signOut();
              // context.go(AppRoutes.login);
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                color: colors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
                  _buildProfileCard(colors),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionLabel('App Settings', colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsGroup([
                    _SettingsRow(
                      iconPath: AppAssets.displayMode,
                      label: 'Display Mode',
                      value: _currentThemeLabel(context),
                      colors: colors,
                      onTap: () => _showDisplayModeSheet(colors),
                      iconColor: colors.appSettingsIcon,
                    ),
                    _SettingsRow(
                      iconPath: AppAssets.languageIcon,
                      label: 'Language',
                      value: _currentLanguage,
                      colors: colors,
                      onTap: () => _showLanguageSheet(colors),
                      iconColor: colors.appSettingsIcon,
                    ),
                  ], colors),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionLabel('About', colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsGroup([
                    _SettingsRow(
                      iconPath: AppAssets.aboutIcon,
                      label: 'About',
                      colors: colors,
                      onTap: () => _showAboutDialog(colors),
                      iconBgColor: colors.about,
                      iconColor: colors.textGray,
                    ),
                    _SettingsRow(
                      iconPath: AppAssets.helpIcon,
                      label: 'Help & Support',
                      colors: colors,
                      onTap: () => _showHelpDialog(colors),
                      iconBgColor: colors.about,
                      iconColor: colors.textGray,
                    ),
                  ], colors),
                  const SizedBox(height: AppSpacing.xxl),

                  // Log out button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showLogOutDialog(colors),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA63C1D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomNav(colors),
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
          Text(
            'Account',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile card ──────────────────────────────────────────
  Widget _buildProfileCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          // Avatar — TODO: replace with user's avatar from Supabase Storage
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFE082),
            child: ClipOval(
              child: Image.asset(
                AppAssets.hatAvatar,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Text(
                  _userName.split(' ').map((e) => e[0]).take(2).join(),
                  style: TextStyle(
                    color: colors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  _userEmail,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          // View button → navigates to My Account screen
          GestureDetector(
            onTap: () => context.push(AppRoutes.myAccount),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
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

  // ── Bottom nav ────────────────────────────────────────────
  Widget _buildBottomNav(AppColors colors) {
    return Container(
      color: colors.primary,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
        top: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            iconPath: AppAssets.historyIcon,
            label: 'History',
            isActive: _currentNavIndex == 0,
            onTap: () => _onNavTap(0),
          ),
          _NavItem(
            iconPath: AppAssets.homeIcon,
            label: 'Home',
            isActive: _currentNavIndex == 1,
            onTap: () => _onNavTap(1),
            iconSize: 22,
          ),
          _NavItem(
            iconPath: AppAssets.accountIcon,
            label: 'Account',
            isActive: _currentNavIndex == 2,
            onTap: () => _onNavTap(2),
            iconSize: 22,
          ),
        ],
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

  const _SettingsRow({
    required this.iconPath,
    required this.label,
    required this.colors,
    required this.onTap,
    this.value,
    this.iconBgColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.settings, size: 18, color: colors.primaryDark),
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
            // Value + chevron
            if (value != null)
              Text(
                value!,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right, color: colors.chevron, size: 18),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? iconPath;
  final IconData? icon;
  final double iconSize;

  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.iconPath,
    this.icon,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : Colors.white.withOpacity(0.45);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconPath != null)
            Image.asset(
              iconPath!,
              width: 20,
              height: 20,
              color: color,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.history, color: color, size: 22),
            )
          else
            Icon(icon, color: color, size: iconSize),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
