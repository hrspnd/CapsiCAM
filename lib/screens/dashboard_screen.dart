import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';

// ============================================================
// SCAN RESULT MODEL — move to lib/models/scan_result.dart later
// ============================================================

class ScanResult {
  final String id;
  final String disease;
  final String imageSource; // 'Scanned' or 'Uploaded'
  final String date;
  final double confidence;
  final String? imagePath;

  const ScanResult({
    required this.id,
    required this.disease,
    required this.imageSource,
    required this.date,
    required this.confidence,
    this.imagePath,
  });
}

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
  // These will come from:
  //   services/supabase_service.dart → fetchDashboardStats()
  //   services/supabase_service.dart → fetchRecentScans(limit: 3)

  // Placeholder user data — replace with Supabase Auth user
  final String _userName = 'John Doe';

  // Placeholder stats — replace with Supabase query results
  final int _totalScans = 13;
  final int _totalHealthy = 7;
  final String? _mostFrequentDisease =
      'Bacterial_Leaf_Spot'; // null if no scans

  // Placeholder recent scans — replace with Supabase query results
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

  // ── Bottom nav index ──────────────────────────────────────
  int _currentNavIndex = 1; // 0=History, 1=Home, 2=Account

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        context.push(AppRoutes.scanHistory);
        break;
      case 1:
        break; // already on dashboard
      case 2:
        context.push(AppRoutes.account);
        break;
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  /// Formats disease name for display
  String _formatDisease(String disease) {
    return disease.replaceAll('_', ' ');
  }

  /// Returns display text for most frequent disease card
  String get _mostFrequentDisplay {
    if (_totalScans == 0 || _mostFrequentDisease == null) return 'None';
    return "Bacterial\nLeaf Spot";
  }

  // ── UI ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xxl, // increase this for more space at top
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionButtons(),
                  const SizedBox(height: AppSpacing.md),
                  _buildStatCards(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRecentScansSection(),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
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
                  color: Colors.white.withOpacity(0.75),
                  height: 0.3,
                ),
              ),
              // const SizedBox(height: 0),
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

          // Avatar — TODO: replace with user's actual avatar from Supabase Storage
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
                    // Fallback to initials if image not found
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
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Live Camera',
            sublabel: 'Real-time scan',
            iconPath: AppAssets.liveCameraIcon,
            onTap: () {
              // TODO: Navigate to live scan screen
              // context.push(AppRoutes.liveScan);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionButton(
            label: 'Capture Image',
            sublabel: 'Capture or upload',
            iconPath: AppAssets.captureImageIcon,
            onTap: () {
              // TODO: Navigate to capture image screen
              // context.push(AppRoutes.captureImage);
            },
          ),
        ),
      ],
    );
  }

  // ── Stat cards ────────────────────────────────────────────
  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: _totalScans == 0 ? '0' : '$_totalScans',
            label: 'Total Scans',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            value: _mostFrequentDisplay,
            label: 'Most Frequent',
            valueColor: _totalScans == 0
                ? AppColors.textSecondary
                : AppColors.bacterial,
            valueFontSize: _mostFrequentDisplay == 'None' ? 18 : 13,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            value: _totalHealthy == 0 ? '0' : '$_totalHealthy',
            label: 'Total Healthy',
            valueColor: _totalHealthy == 0
                ? AppColors.textPrimary
                : AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  // ── Recent scans ──────────────────────────────────────────
  Widget _buildRecentScansSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Scans',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.scanHistory),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryDark,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Empty state
          if (_recentScans.isEmpty)
            Expanded(child: _buildEmptyState())
          else
            Expanded(
              child: Column(
                children: _recentScans
                    .map(
                      (scan) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _ScanItem(
                          scan: scan,
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.historyIcon,
            width: 40,
            height: 40,
            color: AppColors.primary,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.history, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Your scan history will appear here.\nTap a button above to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      color: AppColors.primary,
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
            icon: Icons.grid_view_rounded,
            label: 'Home',
            isActive: _currentNavIndex == 1,
            onTap: () => _onNavTap(1),
            iconSize: 22,
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
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

  const _ActionButton({
    required this.label,
    required this.sublabel,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              errorBuilder: (_, __, ___) => const Icon(
                Icons.camera_alt_outlined,
                size: 40,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              sublabel,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
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
  final Color? valueColor;
  final double? valueFontSize;
  final FontWeight? valueFontWeight;

  const _StatCard({
    required this.value,
    required this.label,
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
          color: AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: valueFontSize ?? 25,
                fontWeight: FontWeight.w700,
                fontFamily: 'Onest',
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
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

  const _ScanItem({required this.scan, required this.onTap});

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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // Thumbnail
            // TODO: Replace with actual image from Supabase Storage
            // Use: Image.network(scan.imageUrl) when Supabase is connected
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgForDisease(scan.disease),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: scan.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.asset(scan.imagePath!, fit: BoxFit.cover),
                    )
                  : Icon(
                      Icons.eco_outlined,
                      color: AppColors.forDisease(scan.disease),
                      size: 24,
                    ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.disease.replaceAll('_', ' '),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${scan.imageSource} · ${scan.date}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right,
              color: AppColors.borderLight,
              size: 20,
            ),
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
