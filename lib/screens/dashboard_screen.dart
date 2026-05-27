// dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';
import 'package:thesis_app/models/scan_result.dart';

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
  // TODO: Replace with real data from Supabase
  // services/supabase_service.dart → fetchDashboardStats()
  // services/supabase_service.dart → fetchRecentScans(limit: 3)

  final String _userName = 'John Doe';
  final int _totalScans = 13;
  final int _totalHealthy = 7;
  final String? _mostFrequentDisease = 'Bacterial_Leaf_Spot';

  final List<ScanResult> _recentScans = [
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
  ];

  int _currentNavIndex = 1;

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
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

  String get _mostFrequentDisplay {
    if (_totalScans == 0 || _mostFrequentDisease == null) return 'None';
    return "Bacterial\nLeaf Spot";
  }

  @override
  Widget build(BuildContext context) {
    // Get theme-aware colors — pass context so it knows light/dark
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xxl,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionButtons(colors),
                  const SizedBox(height: AppSpacing.md),
                  _buildStatCards(colors),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRecentScansSection(colors),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back,',
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
              backgroundColor: Colors.white.withOpacity(0.2),
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
  Widget _buildActionButtons(AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Live Camera',
            sublabel: 'Real-time scan',
            iconPath: AppAssets.liveCameraIcon,
            colors: colors,
            onTap: () {
              context.push(AppRoutes.liveScan);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionButton(
            label: 'Capture Image',
            sublabel: 'Capture or upload',
            iconPath: AppAssets.captureImageIcon,
            colors: colors,
            onTap: () {
              context.push(AppRoutes.captureImage);
            },
          ),
        ),
      ],
    );
  }

  // ── Stat cards ────────────────────────────────────────────
  Widget _buildStatCards(AppColors colors) {
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
            value: _mostFrequentDisplay,
            label: 'Most Frequent',
            colors: colors,
            valueColor: _totalScans == 0
                ? colors.textSecondary
                : colors.bacterial,
            valueFontSize: _mostFrequentDisplay == 'None' ? 18 : 13,
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
  Widget _buildRecentScansSection(AppColors colors) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Scans',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.scanHistory),
                child: Text(
                  'View All',
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
            Expanded(child: _buildEmptyState(colors))
          else
            Expanded(
              child: Column(
                children: _recentScans
                    .map(
                      (scan) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ScanItem(
                          scan: scan,
                          colors: colors,
                          onTap: () {
                            // TODO: Navigate to scan results from history
                            // context.push(
                            //   AppRoutes.scanResults,
                            //   extra: {'scan': scan, 'fromHistory': true},
                            // );
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
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
            'Your scan history will appear here.\nTap a button above to get started.',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => Icon(
                Icons.camera_alt_outlined,
                size: 40,
                color: colors.primaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(fontSize: 11, color: colors.textSecondary),
            ),
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
                    '${scan.imageSource} · ${scan.date}',
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
