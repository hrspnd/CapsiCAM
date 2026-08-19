// dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import 'package:thesis_app/models/scan_result.dart';
import 'package:thesis_app/services/supabase_service.dart';
import 'package:thesis_app/services/scan_refresh_bus.dart';
import 'history_result_screen.dart'; // for HistoryResultArgs

// ============================================================
// DASHBOARD SCREEN
// ============================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ── Supabase data ─────────────────────────────────────────
  final _supabaseService = SupabaseService();

  String _userName = '';
  int _totalScans = 0;
  int _totalHealthy = 0;
  String? _mostFrequentDisease; // raw classification, e.g. 'bacterial_leaf_spot'
  List<ScanResult> _recentScans = const [];

  bool _isLoading = true;
  bool _isOffline = false;
  String? _errorMessage;

  int _currentNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    ScanRefreshBus.listenable.addListener(_onScanRefreshSignal);
  }

  @override
  void dispose() {
    ScanRefreshBus.listenable.removeListener(_onScanRefreshSignal);
    super.dispose();
  }

  void _onScanRefreshSignal() {
    if (!mounted) return;
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _isOffline = false;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _supabaseService.fetchFullName(),
        _supabaseService.fetchDashboardStats(),
        _supabaseService.fetchRecentScans(limit: 3),
      ]);

      final fullName = results[0] as String?;
      final stats = results[1] as DashboardStats;
      final scanRows = results[2] as List<Map<String, dynamic>>;

      if (!mounted) return;
      setState(() {
        _userName = fullName ?? 'there';
        _totalScans = stats.totalScans;
        _totalHealthy = stats.totalHealthy;
        _mostFrequentDisease = stats.mostFrequentDisease;
        _recentScans = scanRows.map(_scanFromRow).toList();
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
            : "Couldn't load your dashboard. Pull down or tap retry.";
      });
    }
  }

  // ── Row → ScanResult mapping ───────────────────────────────

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

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    // setState(() => _currentNavIndex = index);
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
    final display = _diseaseDisplayKeys[key] ?? key;
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
                          if (_errorMessage != null) ...[
                            _buildStatusBanner(colors),
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

  Widget _buildStatusBanner(AppColors colors) {
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
            _isOffline ? Icons.wifi_off : Icons.error_outline,
            size: 18,
            color: colors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ),
          GestureDetector(
            onTap: _loadDashboard,
            child: Text(
              'Retry',
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
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: ClipOval(
                child: Image.asset(
                  AppAssets.hatAvatar,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text(
                    _userName.split(' ').map((e) => e[0]).take(2).join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────

  Widget _buildActionButtons(AppColors colors, AppLocalizations l10n) {
    return _ActionButton(
      label: 'Capture Image',
      sublabel: 'Capture or upload image to scan',
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
                    child: _ScanItem(
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
                  // const SizedBox(height: 2),
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
                              child: CircularProgressIndicator(strokeWidth: 2),
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