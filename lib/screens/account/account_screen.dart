// account_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants.dart';
import '../../theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:thesis_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/services/supabase_service.dart';
import 'package:thesis_app/services/profile_refresh_bus.dart';
import 'package:thesis_app/services/cache_service.dart';
import 'package:thesis_app/widgets/nav_item.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // ── Supabase data ─────────────────────────────────────────
  final _supabaseService = SupabaseService();
  final _cacheService = CacheService();

  late String _userName;
  late String _userEmail;

  // True while what's on screen is a cached fallback rather than a
  // value confirmed by a successful network fetch this session.
  bool _showingCachedName = false;
  bool _showingCachedAvatar = false;

  // Guards so a slow network response can't overwrite a value that
  // an even-slower cache read hasn't gotten to yet, and vice versa —
  // once the network has answered for a field, cache seeding leaves
  // it alone.
  bool _profileFetchedFromNetwork = false;
  bool _avatarFetchedFromNetwork = false;

  // Seeded with the schema defaults ('monogram' / '#F5A623') so the
  // profile-card avatar never flashes something else before
  // _loadAvatar resolves.
  String _avatarType = 'monogram';
  String _avatarValue = '#F5A623';

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _userEmail = user?.email ?? '';
    // Seed with whatever's cheaply available (auth metadata, or the
    // email's local part) so the card never flashes placeholder text,
    // then try to upgrade it with the real profile name below.
    _userName =
        (user?.userMetadata?['full_name'] as String?)?.trim().isNotEmpty ==
            true
        ? (user!.userMetadata!['full_name'] as String)
        : (user?.email?.split('@').first ?? 'User');
    _seedFromCache();
    _loadProfile();
    _loadAvatar();
    ProfileRefreshBus.listenable.addListener(_onProfileRefreshSignal);
  }

  @override
  void dispose() {
    ProfileRefreshBus.listenable.removeListener(_onProfileRefreshSignal);
    super.dispose();
  }

  void _onProfileRefreshSignal() {
    if (!mounted) return;
    _loadProfile();
    _loadAvatar();
  }

  /// Seeds name/avatar/email from local cache so the profile card
  /// shows the user's real info offline instead of just the
  /// metadata/email-derived guess. Only applied to fields the
  /// network hasn't already answered for by the time this resolves.
  Future<void> _seedFromCache() async {
    final cached = await _cacheService.loadProfile();
    if (!mounted || cached == null) return;
    setState(() {
      if (!_profileFetchedFromNetwork && cached.data.fullName != null) {
        _userName = cached.data.fullName!;
        _showingCachedName = true;
      }
      if (!_avatarFetchedFromNetwork &&
          cached.data.avatarType != null &&
          cached.data.avatarValue != null) {
        _avatarType = cached.data.avatarType!;
        _avatarValue = cached.data.avatarValue!;
        _showingCachedAvatar = true;
      }
      if (_userEmail.isEmpty && cached.data.email != null) {
        _userEmail = cached.data.email!;
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      final fullName = await _supabaseService.fetchFullName();
      if (!mounted) return;
      _profileFetchedFromNetwork = true;
      if (fullName == null || fullName.trim().isEmpty) return;
      setState(() {
        _userName = fullName;
        _showingCachedName = false;
      });
      unawaited(_cacheService.saveProfile(
        fullName: fullName,
        email: _userEmail.isNotEmpty ? _userEmail : null,
      ));
    } catch (_) {
      // Non-critical: keep whichever name is already on screen (the
      // metadata/email-derived guess, or a cached value from
      // _seedFromCache) rather than surfacing an error for a
      // profile-name lookup.
    }
  }

  Future<void> _loadAvatar() async {
    try {
      final avatar = await _supabaseService.fetchAvatar();
      if (!mounted) return;
      _avatarFetchedFromNetwork = true;
      if (avatar == null) return;
      setState(() {
        _avatarType = avatar.type;
        _avatarValue = avatar.value;
        _showingCachedAvatar = false;
      });
      unawaited(_cacheService.saveProfile(
        avatarType: avatar.type,
        avatarValue: avatar.value,
      ));
    } catch (_) {
      // Non-critical: keep the default/cached avatar rather than
      // surfacing an error for what's ultimately a cosmetic lookup.
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

  // ── Theme ─────────────────────────────────────────────────
  String _currentThemeLabel(BuildContext context) {
    final mode = context.watch<ThemeProvider>().themeMode;
    if (mode == ThemeMode.dark) return 'Dark';
    if (mode == ThemeMode.system) return 'System';
    return 'Light';
  }

  // ── Nav index ─────────────────────────────────────────────
  final int _currentNavIndex = 2;

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
    if (provider.themeMode == ThemeMode.dark) {
      selected = 'Dark';
    } else if (provider.themeMode == ThemeMode.system)
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

                          if (option == 'Dark') {
                            provider.setDark();
                          } else if (option == 'System')
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
    String selected = Localizations.localeOf(context).languageCode == 'fil'
        ? 'Filipino'
        : 'English';
    final options = ['English', 'Filipino'];
    final l10n = AppLocalizations.of(context)!;

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
                    l10n.languageLabel,
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

                        context.read<ThemeProvider>().setLocale(
                          option == 'Filipino'
                              ? const Locale('fil')
                              : const Locale('en'),
                        );

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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          l10n.aboutLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          l10n.aboutMsg,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          l10n.helpSupport,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          l10n.helpSupportmsg,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          l10n.logOut,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          l10n.logOutSure,
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
            onPressed: () => _onLogOut(context),
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

  Future<void> _onLogOut(BuildContext dialogContext) async {
    // Close the confirmation dialog first.
    Navigator.pop(dialogContext);

    // Clear this user's cached data before signing out — CacheService
    // scopes keys by the current user's ID, and once signed out,
    // currentUser is null, so it can no longer resolve which entries
    // were this user's. The per-user key scoping is what actually
    // prevents the next login from seeing this data; this call is
    // just hygiene so a device used for multiple test accounts
    // doesn't accumulate stale entries forever.
    await _cacheService.clearForCurrentUser();

    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e, stackTrace) {
      debugPrint('Error during logout: $e');
      debugPrint('$stackTrace');
      // Even if sign-out errors (e.g. no network), still send the user
      // to the login screen — there's nothing useful to keep them here for.
    }

    if (!mounted) return;
    context.go(AppRoutes.login);
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
                  _buildProfileCard(colors, l10n),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionLabel(l10n.appSettings, colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsGroup([
                    _SettingsRow(
                      iconPath: AppAssets.displayMode,
                      label: l10n.displayMode,
                      value: _currentThemeLabel(context),
                      colors: colors,
                      onTap: () => _showDisplayModeSheet(colors),
                      iconColor: colors.appSettingsIcon,
                    ),
                    _SettingsRow(
                      iconPath: AppAssets.languageIcon,
                      label: l10n.languageLabel,
                      value:
                          Localizations.localeOf(context).languageCode == 'fil'
                          ? 'Filipino'
                          : 'English',
                      colors: colors,
                      onTap: () => _showLanguageSheet(colors),
                      iconColor: colors.appSettingsIcon,
                    ),
                  ], colors),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionLabel(l10n.aboutAppLabel, colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsGroup([
                    _SettingsRow(
                      iconPath: AppAssets.aboutIcon,
                      label: l10n.aboutLabel,
                      colors: colors,
                      onTap: () => _showAboutDialog(colors),
                      iconBgColor: colors.about,
                      iconColor: colors.textGray,
                    ),
                    _SettingsRow(
                      iconPath: AppAssets.helpIcon,
                      label: l10n.helpSupport,
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
                        backgroundColor: colors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.logOut,
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
  Widget _buildProfileCard(AppColors colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          UserAvatar(
            colors: colors,
            avatarType: _avatarType,
            avatarValue: _avatarValue,
            diameter: 44,
            initials: _userInitials,
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
                if (_showingCachedName || _showingCachedAvatar) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 11,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        l10n.offlineSavedData,
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
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
          NavItem(
            iconPath: AppAssets.historyIcon,
            label: 'History',
            isActive: _currentNavIndex == 0,
            onTap: () => _onNavTap(0),
          ),
          NavItem(
            iconPath: AppAssets.homeIcon,
            label: 'Home',
            isActive: _currentNavIndex == 1,
            onTap: () => _onNavTap(1),
          ),
          NavItem(
            iconPath: AppAssets.accountIcon,
            label: 'Account',
            isActive: _currentNavIndex == 2,
            onTap: () => _onNavTap(2),
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