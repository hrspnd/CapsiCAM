// scan_history_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import 'package:thesis_app/models/scan_result.dart';
import 'package:thesis_app/services/supabase_service.dart';
import 'package:thesis_app/services/cache_service.dart';
import 'package:thesis_app/widgets/nav_item.dart';
import 'package:thesis_app/widgets/scan_item.dart';
import 'history_result_screen.dart';

// ============================================================
// SCAN HISTORY SCREEN
// ============================================================

/// Which offline/cache banner message is currently showing, if any.
/// Stored instead of the resolved String itself so the text is
/// (re)computed from AppLocalizations at build time — see the same
/// pattern (and rationale) in dashboard_screen.dart's
/// _DashboardBannerKind.
enum _HistoryBannerKind {
  offlineWithCache,
  refreshFailedWithCache,
  offlineNoCache,
  loadFailedNoCache,
}

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  // ── Supabase data ─────────────────────────────────────────
  final _supabaseService = SupabaseService();
  final _cacheService = CacheService();

  List<ScanResult> _scans = const [];

  bool _isLoading = true;
  bool _isOffline = false;
  bool _showingCachedData = false;
  _HistoryBannerKind? _bannerKind;
  DateTime? _cachedAt;

  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _isOffline = false;
      _bannerKind = null;
    });

    try {
      final rows = await _supabaseService.fetchAllScans();
      final scans = rows.map(ScanResult.fromRow).toList();
      if (!mounted) return;
      setState(() {
        _scans = scans;
        _isLoading = false;
        _showingCachedData = false;
        _cachedAt = null;
        _bannerKind = null;
      });
      unawaited(_cacheService.saveHistory(scans));
    } catch (e) {
      if (!mounted) return;
      final isOffline = e.toString().contains('offline');
      final cached = await _cacheService.loadHistory();

      if (!mounted) return;

      if (cached != null) {
        setState(() {
          _scans = cached.data;
          _isLoading = false;
          _isOffline = isOffline;
          _showingCachedData = true;
          _cachedAt = cached.cachedAt;
          _bannerKind = isOffline
              ? _HistoryBannerKind.offlineWithCache
              : _HistoryBannerKind.refreshFailedWithCache;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isOffline = isOffline;
          _showingCachedData = false;
          _cachedAt = null;
          _bannerKind = isOffline
              ? _HistoryBannerKind.offlineNoCache
              : _HistoryBannerKind.loadFailedNoCache;
        });
      }
    }
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        context.push(AppRoutes.dashboard);
        break;
      case 2:
        context.push(AppRoutes.account);
        break;
    }
  }

  void _onClearHistory() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) {
        final colors = AppColors.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl + 10),
          ),
          backgroundColor: colors.surface,
          title: Text(
            l10n.clearHistoryButton,
            style: TextStyle(
              fontFamily: 'Onest',
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          content: Text(
            l10n.clearHistoryConfirm,
            style: TextStyle(
              fontFamily: 'Onest',
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                l10n.clearHistoryCancel,
                style: TextStyle(
                  fontFamily: 'Onest',
                  color: colors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final previousScans = _scans;
                setState(() => _scans = const []); // optimistic
                try {
                  await _supabaseService.clearScanHistory();
                  // Only drop the local cache once the server-side
                  // clear actually succeeds — otherwise a rollback
                  // below would leave stale scans in state but no
                  // cached fallback if the app goes offline next.
                  unawaited(_cacheService.clearHistory());
                } catch (e) {
                  if (!mounted) return;
                  setState(() => _scans = previousScans); // roll back
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not clear history: $e'),
                    ),
                  );
                }
              },
              child: Text(
                l10n.clearHistoryConfirmButton,
                style: TextStyle(
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w700,
                  color: colors.danger,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Resolves [_bannerKind] to display text using the current build's
  /// AppLocalizations — see _DashboardBannerKind's rationale in
  /// dashboard_screen.dart for why this isn't cached in state.
  String _bannerText(AppLocalizations l10n) {
    final kind = _bannerKind;
    if (kind == null) return '';
    final age = _cachedAt != null ? formatCacheAge(_cachedAt!, l10n) : '';
    switch (kind) {
      case _HistoryBannerKind.offlineWithCache:
        return l10n.historyOfflineCached(age);
      case _HistoryBannerKind.refreshFailedWithCache:
        return l10n.historyRefreshFailedCached(age);
      case _HistoryBannerKind.offlineNoCache:
        return l10n.offlineNoCache;
      case _HistoryBannerKind.loadFailedNoCache:
        return l10n.historyLoadFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n   = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors, l10n),
          if (_bannerKind != null)
            Container(
              width: double.infinity,
              color: (_isOffline || _showingCachedData)
                  ? colors.surfaceGray
                  : colors.dangerBg,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                _bannerText(l10n),
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadHistory,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _scans.isEmpty
                      ? _buildEmptyState(colors)
                      : _buildScanList(colors, l10n),
            ),
          ),
          _buildBottomNav(colors),
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
        children: [
          Text(
            l10n.scanHistoryTitle,
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

  // ── Scan list ─────────────────────────────────────────────

  Widget _buildScanList(AppColors colors, AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _scans.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, index) {
              final scan = _scans[index];
              return ScanItem(
                scan: scan,
                colors: colors,
                onTap: () {
                  context.push(
                    AppRoutes.historyResult,
                    extra: HistoryResultArgs(
                      imagePath:
                          scan.imagePath ?? 'assets/icons/sample_leafpic.png',
                      label: scan.disease,
                      confidence: scan.confidence,
                      predictions: scan.predictions,
                      source: scan.imageSource,
                      date: scan.scannedAt,
                      heatmapPath: scan.heatmapPath,
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: _buildClearHistory(colors, l10n),
        ),
      ],
    );
  }

  // ── Clear history ─────────────────────────────────────────

  Widget _buildClearHistory(AppColors colors, AppLocalizations l10n) {
    return Column(
      children: [
        Divider(color: colors.border, thickness: 1),
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: AppSpacing.md,
          ),
          child: GestureDetector(
            onTap: _onClearHistory,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.trashIcon,
                  width: 14,
                  height: 14,
                  color: colors.danger,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.delete_outline_rounded,
                    size: 14,
                    color: colors.danger,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.clearHistoryButton,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Onest',
                    color: colors.danger,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Empty state ───────────────────────────────────────────

  Widget _buildEmptyState(AppColors colors) {
    final l10n   = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
        child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.historyIcon,
              width: 48,
              height: 48,
              color: colors.primary,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.history, size: 48, color: colors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noScanHistory,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Onest',
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.completedScans,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Onest',
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
          ),
        ),
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