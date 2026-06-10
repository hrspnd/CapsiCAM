// scan_history_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import 'package:thesis_app/models/scan_result.dart';
import 'history_result_screen.dart';

// ============================================================
// SCAN HISTORY SCREEN
// ============================================================

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  // ── Supabase data ─────────────────────────────────────────
  // TODO: Replace with real data from Supabase
  // services/supabase_service.dart → fetchAllScans()

  final List<ScanResult> _scans = [
    ScanResult(
      id: '1',
      disease: 'Bacterial_Leaf_Spot',
      imageSource: AppConstants.sourceScanned,
      date: 'Apr 24, 2026',
      confidence: 0.91,
    ),
    ScanResult(
      id: '2',
      disease: 'Healthy',
      imageSource: AppConstants.sourceUploaded,
      date: 'Apr 24, 2026',
      confidence: 0.97,
    ),
    ScanResult(
      id: '3',
      disease: 'Cercospora_Leaf_Spot',
      imageSource: AppConstants.sourceUploaded,
      date: 'Apr 24, 2026',
      confidence: 0.81,
    ),
    ScanResult(
      id: '4',
      disease: 'Bacterial_Leaf_Spot',
      imageSource: AppConstants.sourceScanned,
      date: 'Apr 23, 2026',
      confidence: 0.88,
    ),
    ScanResult(
      id: '5',
      disease: 'Healthy',
      imageSource: AppConstants.sourceScanned,
      date: 'Apr 21, 2026',
      confidence: 0.95,
    ),
  ];

  int _currentNavIndex = 0;

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
    // TODO: Call Supabase → supabase_service.dart → clearScanHistory()
    // TODO: On success → setState(() => _scans.clear())
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
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() => _scans.clear());
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n   = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors, l10n),
          Expanded(
            child: _scans.isEmpty
                ? _buildEmptyState(colors)
                : _buildScanList(colors, l10n),
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
            itemBuilder: (_, index) => _ScanItem(
              scan: _scans[index],
              colors: colors,
              onTap: () {
                // TODO: Navigate to scan results from history
                // context.push(
                //   AppRoutes.scanResults,
                //   extra: {'scan': _scans[index], 'fromHistory': true},
                // );

                //temporary -- temp data, remove later
                context.push(
                  AppRoutes.historyResult,
                  extra: HistoryResultArgs(
                    imagePath:
                        _scans[index].imagePath ??
                        'assets/icons/sample_leafpic.png',
                    label: _scans[index].disease,
                    confidence: _scans[index].confidence,
                    predictions: {
                      'Bacterial_Leaf_Spot': 1.0,
                      'Cercospora_Leaf_Spot': 0.3,
                      'Healthy': 0.1,
                    },
                    source: _scans[index].imageSource,
                    date: DateTime.now(),
                    heatmapPath: 'assets/icons/sample_heatmap.png',
                  ),
                );
                //end
              },
            ),
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
    return Center(
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

class _ScanItem extends StatelessWidget {
  final ScanResult scan;
  final VoidCallback onTap;
  final AppColors colors;

  const _ScanItem({
    required this.scan,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sourceLabel = scan.imageSource == AppConstants.sourceScanned
        ? l10n.sourceScanned
        : l10n.sourceUploaded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            // Thumbnail
            // TODO: Replace with Image.network(scan.imageUrl) when Supabase is connected
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.bgForDisease(scan.disease),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: scan.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.asset(scan.imagePath!, fit: BoxFit.cover),
                    )
                  : Icon(
                      Icons.eco_outlined,
                      color: colors.forDisease(scan.disease),
                      size: 24,
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.disease.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$sourceLabel · ${scan.date}',
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.chevron, size: 20),
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
  final double iconSize;

  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.iconPath,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Colors.white
        : Colors.white.withValues(alpha: 0.45);

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
            ),
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