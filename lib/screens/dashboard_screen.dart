// dashboard_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import 'package:thesis_app/models/scan_result.dart';
import 'package:thesis_app/services/supabase_service.dart';
import 'package:thesis_app/services/scan_refresh_bus.dart';
import 'package:thesis_app/services/profile_refresh_bus.dart';
import 'package:thesis_app/services/cache_service.dart';
import 'package:thesis_app/widgets/nav_item.dart';
import 'package:thesis_app/widgets/scan_item.dart';
import 'history_result_screen.dart'; // for HistoryResultArgs

// ============================================================
// DASHBOARD SCREEN
// ============================================================

/// Which offline/cache banner message is currently showing, if any.
/// Stored instead of the resolved String itself so the actual text
/// is (re)computed from AppLocalizations at build time — otherwise a
/// language switch wouldn't retranslate a message that was already
/// baked into state, and it'd sit stale until the next network/cache
/// event overwrote it.
enum _DashboardBannerKind {
  offlineWithCache,
  refreshFailedWithCache,
  offlineNoCache,
  loadFailedNoCache,
  showingCachedRefreshing,
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ── Supabase data ─────────────────────────────────────────
  final _supabaseService = SupabaseService();
  final _cacheService = CacheService();

  String _userName = '';
  int _totalScans = 0;
  int _totalHealthy = 0;
  String? _mostFrequentDisease; // raw classification, e.g. 'bacterial_leaf_spot'
  List<ScanResult> _recentScans = const [];

  // True when the data currently on screen came from local cache
  // rather than a fresh fetch (i.e. we're looking at a fallback).
  bool _showingCachedData = false;
  DateTime? _cachedAt;

  // Seeded with the schema defaults ('monogram' / '#F5A623') so the
  // header avatar never flashes something else before _loadAvatar
  // resolves. Fetched separately from _loadDashboard (see _loadAvatar)
  // so a failed avatar lookup never blocks stats/scans from loading.
  String _avatarType = 'monogram';
  String _avatarValue = '#F5A623';

  bool _isLoading = true;
  bool _isOffline = false;
  _DashboardBannerKind? _bannerKind;

  // Guards against a slow cache read (see _seedFromCache) overwriting
  // a network result that already came back — mirrors the same
  // pattern used in account_screen.dart.
  bool _hasResolvedOnce = false;

  // True only while a manual "Retry" tap is in flight — distinct from
  // the silent background refresh in _loadDashboard, which by design
  // gives no visual feedback when cached content is already showing.
  // A user-initiated retry needs its own explicit feedback or it
  // looks like the tap did nothing.
  bool _isRetrying = false;

  int _currentNavIndex = 1;

  @override
  void initState() {
    super.initState();
    // Show cached data immediately (fast, local, no network round
    // trip) while _loadDashboard tries to refresh in the background.
    // Without this, a slow/offline network attempt leaves the screen
    // on a blank spinner for however long that attempt takes, even
    // though we may already have something useful to show.
    _seedFromCache();
    _loadDashboard();
    _loadAvatar();
    ScanRefreshBus.listenable.addListener(_onScanRefreshSignal);
    ProfileRefreshBus.listenable.addListener(_onProfileRefreshSignal);
  }

  @override
  void dispose() {
    ScanRefreshBus.listenable.removeListener(_onScanRefreshSignal);
    ProfileRefreshBus.listenable.removeListener(_onProfileRefreshSignal);
    super.dispose();
  }

  void _onScanRefreshSignal() {
    if (!mounted) return;
    _loadDashboard();
  }

  void _onProfileRefreshSignal() {
    if (!mounted) return;
    _loadDashboard();
    _loadAvatar();
  }

  Future<void> _seedFromCache() async {
    final cached = await _cacheService.loadDashboard();
    if (!mounted || cached == null) return;
    final cachedProfile = await _cacheService.loadProfile();
    if (!mounted || _hasResolvedOnce) return; // network already answered

    setState(() {
      if (cachedProfile?.data.fullName != null) {
        _userName = cachedProfile!.data.fullName!;
      }
      _totalScans = cached.data.totalScans;
      _totalHealthy = cached.data.totalHealthy;
      _mostFrequentDisease = cached.data.mostFrequentDisease;
      _recentScans = cached.data.recentScans;
      _isLoading = false;
      _showingCachedData = true;
      _cachedAt = cached.cachedAt;
      _bannerKind = _DashboardBannerKind.showingCachedRefreshing;
    });
  }

  Future<void> _loadDashboard() async {
    // Only block the whole screen with a spinner if there's nothing
    // on it yet (first-ever open, no cache). Otherwise — including
    // when _seedFromCache already populated the screen — refresh
    // quietly in the background instead of wiping visible content.
    final hasContentOnScreen = _recentScans.isNotEmpty || _totalScans > 0;
    if (!hasContentOnScreen) {
      setState(() {
        _isLoading = true;
        _isOffline = false;
        _bannerKind = null;
      });
    }

    try {
      final results = await Future.wait([
        _supabaseService.fetchFullName(),
        _supabaseService.fetchDashboardStats(),
        _supabaseService.fetchRecentScans(limit: 3),
      ], eagerError: true);

      final fullName = results[0] as String?;
      final stats = results[1] as DashboardStats;
      final scanRows = results[2] as List<Map<String, dynamic>>;

      final recentScans = scanRows.map(ScanResult.fromRow).toList();

      _hasResolvedOnce = true;
      if (!mounted) return;
      setState(() {
        _userName = fullName ?? 'there';
        _totalScans = stats.totalScans;
        _totalHealthy = stats.totalHealthy;
        _mostFrequentDisease = stats.mostFrequentDisease;
        _recentScans = recentScans;
        _isLoading = false;
        _showingCachedData = false;
        _cachedAt = null;
        _bannerKind = null;
      });

      // Fire-and-forget: cache the fresh data for the next offline load.
      // Uses 'there' as a neutral fallback rather than caching a null
      // name, so a later offline read never shows something worse.
      unawaited(_cacheService.saveDashboard(
        totalScans: stats.totalScans,
        totalHealthy: stats.totalHealthy,
        mostFrequentDisease: stats.mostFrequentDisease,
        recentScans: recentScans,
      ));
      if (fullName != null) {
        unawaited(_cacheService.saveProfile(fullName: fullName));
      }
    } catch (e) {
      _hasResolvedOnce = true;
      if (!mounted) return;
      final isOffline = e.toString().contains('offline');
      final cached = await _cacheService.loadDashboard();
      final cachedProfile = await _cacheService.loadProfile();

      if (!mounted) return;

      if (cached != null) {
        setState(() {
          if (cachedProfile?.data.fullName != null) {
            _userName = cachedProfile!.data.fullName!;
          }
          _totalScans = cached.data.totalScans;
          _totalHealthy = cached.data.totalHealthy;
          _mostFrequentDisease = cached.data.mostFrequentDisease;
          _recentScans = cached.data.recentScans;
          _isLoading = false;
          _isOffline = isOffline;
          _showingCachedData = true;
          _cachedAt = cached.cachedAt;
          _bannerKind = isOffline
              ? _DashboardBannerKind.offlineWithCache
              : _DashboardBannerKind.refreshFailedWithCache;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isOffline = isOffline;
          _showingCachedData = false;
          _cachedAt = null;
          _bannerKind = isOffline
              ? _DashboardBannerKind.offlineNoCache
              : _DashboardBannerKind.loadFailedNoCache;
        });
      }
    }
  }

  Future<void> _onRetryTap() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);
    await _loadDashboard();
    if (!mounted) return;
    setState(() => _isRetrying = false);

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _bannerKind == null
              ? l10n.retrySnackbarDashboardRefreshed
              : (_isOffline
                  ? l10n.retrySnackbarStillOffline
                  : l10n.retrySnackbarCouldNotRefresh),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadAvatar() async {
    try {
      final avatar = await _supabaseService.fetchAvatar();
      if (!mounted || avatar == null) return;
      setState(() {
        _avatarType = avatar.type;
        _avatarValue = avatar.value;
      });
      unawaited(_cacheService.saveProfile(
        avatarType: avatar.type,
        avatarValue: avatar.value,
      ));
    } catch (_) {
      // Non-critical: keep the default avatar rather than surfacing
      // an error for what's ultimately a cosmetic lookup. But if we
      // have a previously cached avatar, prefer that over the
      // schema-default placeholder.
      final cachedProfile = await _cacheService.loadProfile();
      if (!mounted) return;
      if (cachedProfile?.data.avatarType != null &&
          cachedProfile?.data.avatarValue != null) {
        setState(() {
          _avatarType = cachedProfile!.data.avatarType!;
          _avatarValue = cachedProfile.data.avatarValue!;
        });
      }
    }
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    switch (index) {
      case 0:
        context.push(AppRoutes.scanHistory);
        break;
      case 1:
        break;
      case 2:
        context.push(AppRoutes.account);
        break;
    }
  }

  String _mostFrequentDisplay(AppLocalizations l10n) {
    final key = _mostFrequentDisease;
    if (_totalScans == 0 || key == null) return 'None';
    final display = ScanResult.diseaseDisplayKeys[key] ?? key;
    final words = display.split('_');
    if (words.length <= 1) return display;
    return '${words.first}\n${words.sublist(1).join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors, l10n),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDashboard,
              color: colors.primary,
              child: _isLoading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        top: AppSpacing.xxl,
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_bannerKind != null) ...[
                            _buildStatusBanner(colors, l10n),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          _buildActionButtons(colors, l10n),
                          const SizedBox(height: AppSpacing.md),
                          _buildStatCards(colors, l10n),
                          const SizedBox(height: AppSpacing.lg),
                          _buildRecentScansSection(colors, l10n),
                        ],
                      ),
                    ),
            ),
          ),
          _buildBottomNav(colors),
        ],
      ),
    );
  }

  // ── Status banner (offline / error) ─────────────────────────

  /// Resolves [_bannerKind] to display text using the *current* build's
  /// AppLocalizations — computed here rather than cached in state, so
  /// switching language updates this banner immediately instead of
  /// only on the next network/cache event.
  String _bannerText(AppLocalizations l10n) {
    final kind = _bannerKind;
    if (kind == null) return '';
    final age = _cachedAt != null ? formatCacheAge(_cachedAt!, l10n) : '';
    switch (kind) {
      case _DashboardBannerKind.offlineWithCache:
        return l10n.dashboardOfflineCached(age);
      case _DashboardBannerKind.refreshFailedWithCache:
        return l10n.dashboardRefreshFailedCached(age);
      case _DashboardBannerKind.offlineNoCache:
        return l10n.offlineNoCache;
      case _DashboardBannerKind.loadFailedNoCache:
        return l10n.dashboardLoadFailed;
      case _DashboardBannerKind.showingCachedRefreshing:
        return l10n.dashboardShowingCachedRefreshing(age);
    }
  }

  Widget _buildStatusBanner(AppColors colors, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceGray,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(
            _showingCachedData
                ? Icons.cloud_off_outlined
                : (_isOffline ? Icons.wifi_off : Icons.error_outline),
            size: 18,
            color: colors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _bannerText(l10n),
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ),
          GestureDetector(
            onTap: _isRetrying ? null : _onRetryTap,
            child: _isRetrying
                ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primaryDark,
                    ),
                  )
                : Text(
                    l10n.retryButton,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.primaryDark,
                      decoration: TextDecoration.underline,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(AppColors colors, AppLocalizations l10n) {
    return Container(
      color: colors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 32,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeBack,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 0.3,
                ),
              ),
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.account),
            child: UserAvatar(
              colors: colors,
              avatarType: _avatarType,
              avatarValue: _avatarValue,
              diameter: 44,
              initials:
                  _userName.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────

  Widget _buildActionButtons(AppColors colors, AppLocalizations l10n) {
    return _ActionButton(
      label: l10n.captureImage,
      sublabel: l10n.captureUpload,
      iconPath: AppAssets.liveCameraIcon,
      colors: colors,
      onTap: () => context.push(AppRoutes.captureImage),
    );
  }

  // ── Stat cards ────────────────────────────────────────────

  Widget _buildStatCards(AppColors colors, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: _totalScans == 0 ? '0' : '$_totalScans',
            label: 'Total Scans',
            colors: colors,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            value: _mostFrequentDisplay(l10n),
            label: 'Most Frequent',
            colors: colors,
            valueColor: _totalScans == 0
                ? colors.textSecondary
                : colors.bacterial,
            valueFontSize: _mostFrequentDisplay(l10n) == 'None' ? 18 : 13,
            valueFontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            value: _totalHealthy == 0 ? '0' : '$_totalHealthy',
            label: 'Total Healthy',
            colors: colors,
            valueColor: _totalHealthy == 0
                ? colors.textPrimary
                : colors.primaryDark,
          ),
        ),
      ],
    );
  }

  // ── Recent scans ──────────────────────────────────────────

  Widget _buildRecentScansSection(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentScans,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(AppRoutes.scanHistory),
              child: Text(
                l10n.viewAll,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.primaryDark,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_recentScans.isEmpty)
          SizedBox(height: 200, child: _buildEmptyState(colors, l10n))
        else
          Column(
            children: _recentScans
                .map(
                  (scan) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ScanItem(
                      scan: scan,
                      colors: colors,
                      onTap: () {
                        context.push(
                          AppRoutes.historyResult,
                          extra: HistoryResultArgs(
                            imagePath: scan.imagePath ??
                                'assets/icons/sample_leafpic.png',
                            label: scan.disease,
                            confidence: scan.confidence,
                            predictions: scan.predictions,
                            source: scan.imageSource,
                            date: scan.scannedAt,
                            heatmapPath: scan.heatmapPath,
                          ),
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState(AppColors colors, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.historyIcon,
            width: 40,
            height: 40,
            color: colors.primary,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.history, size: 40, color: colors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.scanHistoryEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
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

class _ActionButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final String iconPath;
  final VoidCallback onTap;
  final AppColors colors;

  const _ActionButton({
    required this.label,
    required this.sublabel,
    required this.iconPath,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 56,
              height: 56,
              errorBuilder: (_, __, ___) => Icon(
                Icons.camera_alt_outlined,
                size: 56,
                color: colors.primaryDark,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.chevron, size: 22),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final AppColors colors;
  final Color? valueColor;
  final double? valueFontSize;
  final FontWeight? valueFontWeight;

  const _StatCard({
    required this.value,
    required this.label,
    required this.colors,
    this.valueColor,
    this.valueFontSize,
    this.valueFontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceGray,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: valueFontSize ?? 25,
                fontWeight: valueFontWeight ?? FontWeight.w700,
                fontFamily: 'Onest',
                color: valueColor ?? colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}