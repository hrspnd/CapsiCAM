// scan_history_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import 'package:thesis_app/models/scan_result.dart';
import 'package:thesis_app/services/supabase_service.dart';
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
  final _supabaseService = SupabaseService();

  List<ScanResult> _scans = const [];

  bool _isLoading = true;
  bool _isOffline = false;
  String? _errorMessage;

  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ── Row → ScanResult mapping ────────────────────────────────
  // Mirrors dashboard_screen.dart's _scanFromRow. Kept in sync
  // manually for now — if these two ever drift, pull this into a
  // shared mapper (e.g. models/scan_result.dart) instead.

  static const Map<String, String> _diseaseDisplayKeys = {
    'healthy': 'Healthy',
    'bacterial_leaf_spot': 'Bacterial_Leaf_Spot',
    'cercospora_leaf_spot': 'Cercospora_Leaf_Spot',
  };

  ScanResult _scanFromRow(Map<String, dynamic> row) {
    final classification = row['classification'] as String;

    double confidence;
    switch (classification) {
      case 'healthy':
        confidence = (row['confidence_healthy'] as num).toDouble();
        break;
      case 'bacterial_leaf_spot':
        confidence = (row['confidence_bls'] as num).toDouble();
        break;
      case 'cercospora_leaf_spot':
        confidence = (row['confidence_cls'] as num).toDouble();
        break;
      default:
        confidence = 0.0;
    }

    final scannedAt = DateTime.parse(row['scanned_at'] as String).toLocal();

    return ScanResult(
      id: row['id'] as String,
      disease: _diseaseDisplayKeys[classification] ?? classification,
      imageSource: row['image_source'] == 'captured'
          ? AppConstants.sourceScanned
          : AppConstants.sourceUploaded,
      date: DateFormat('MMM d, yyyy').format(scannedAt),
      scannedAt: scannedAt,
      confidence: confidence,
      predictions: {
        'Healthy': (row['confidence_healthy'] as num).toDouble(),
        'Bacterial_Leaf_Spot': (row['confidence_bls'] as num).toDouble(),
        'Cercospora_Leaf_Spot': (row['confidence_cls'] as num).toDouble(),
      },
      imagePath: row['image_url'] as String?,
      heatmapPath: row['heatmap_url'] as String?,
    );
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _isOffline = false;
      _errorMessage = null;
    });

    try {
      final rows = await _supabaseService.fetchAllScans();
      if (!mounted) return;
      setState(() {
        _scans = rows.map(_scanFromRow).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final isOffline = e.toString().contains('offline');
      setState(() {
        _isLoading = false;
        _isOffline = isOffline;
        _errorMessage = isOffline
            ? "You're offline. Showing what we could load."
            : "Couldn't load your scan history. Pull down or tap retry.";
      });
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n   = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors, l10n),
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              color: _isOffline ? colors.surfaceGray : colors.dangerBg,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                _errorMessage!,
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
              return _ScanItem(
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
                      child: Image.network(
                        scan.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.eco_outlined,
                          color: colors.forDisease(scan.disease),
                          size: 24,
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            ),
                          );
                        },
                      ),
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