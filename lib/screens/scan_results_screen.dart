// scan_results_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import 'package:thesis_app/services/scan_refresh_bus.dart';

// ============================================================
// SCAN RESULTS SCREEN
// ============================================================

// Pass this as `extra` when navigating to this screen:
//
// context.push(AppRoutes.scanResults, extra: ScanResultsArgs(
//   imagePath:   '/path/to/image.jpg',
//   label:       'Bacterial_Leaf_Spot',
//   confidence:  0.91,
//   predictions: {
//     'Bacterial_Leaf_Spot':  0.91,
//     'Cercospora_Leaf_Spot': 0.27,
//     'Healthy':              0.02,
//   },
//   source:      AppConstants.sourceScanned,   // or sourceUploaded
//   date:        DateTime.now(),
//   heatmapPath: '/path/to/heatmap.jpg',       // nullable
// ));

class ScanResultsArgs {
  final String imagePath;
  final String label;
  final double confidence;
  final Map<String, double> predictions;
  final String source;
  final DateTime date;
  final String? heatmapPath;

  const ScanResultsArgs({
    required this.imagePath,
    required this.label,
    required this.confidence,
    required this.predictions,
    required this.source,
    required this.date,
    this.heatmapPath,
  });
}

class ScanResultsScreen extends StatelessWidget {
  final ScanResultsArgs args;

  const ScanResultsScreen({super.key, required this.args});

  // ── Helpers ───────────────────────────────────────────────

  String get _formattedDate {
    final d = args.date;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String get _formattedTime {
    final d = args.date;
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get _displayLabel => args.label.replaceAll('_', ' ');

  void _onBack(BuildContext context) {
    // A scan was just saved for this screen to show, so let the
    // dashboard know to refresh its recent scans whenever it's
    // next visible, however far back it sits in the stack.
    ScanRefreshBus.notify();
    context.pop();
  }

  void _onBackToHome(BuildContext context) {
    ScanRefreshBus.notify();
    context.go(AppRoutes.dashboard);
  }

  void _showFullImage(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (_) => GestureDetector(
        onTap: () => context.pop(),
        onVerticalDragStart: (_) => Navigator.of(context).pop(),
        onHorizontalDragStart: (_) => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: colors.textBlack,
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(args.imagePath),
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _translatedSource(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (args.source == AppConstants.sourceScanned) {
      return l10n.sourceScanned;
    }
    if (args.source == AppConstants.sourceUploaded) {
      return l10n.sourceUploaded;
    }
    return args.source;
  }

  void _showFullHeatmap(BuildContext context, AppColors colors) {
    if (args.heatmapPath == null) return;
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (_) => GestureDetector(
        onTap: () => context.pop(),
        onVerticalDragStart: (_) => Navigator.of(context).pop(),
        onHorizontalDragStart: (_) => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: colors.textBlack,
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(args.heatmapPath!),
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(context, colors),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeafImage(context, colors),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDiagnosisChip(colors),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInfoAndHeatmapRow(context, colors),
                    const SizedBox(height: AppSpacing.lg),
                    Divider(color: colors.border, thickness: 1),
                    const SizedBox(height: AppSpacing.lg),
                    _buildConfidenceBreakdown(colors),
                    const SizedBox(height: AppSpacing.lg),
                    _buildBackToHomeButton(context, colors),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, AppColors colors) {
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
          GestureDetector(
            onTap: () => _onBack(context),
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Image.asset(AppAssets.backIcon, width: 20, height: 20),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Scan Results',
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

  // ── Leaf image ────────────────────────────────────────────

  Widget _buildLeafImage(BuildContext context, AppColors colors) {
    return GestureDetector(
      onTap: () => _showFullImage(context, colors),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Image.file(
            File(args.imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: colors.surfaceGray,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: colors.textGray,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Diagnosis chip ────────────────────────────────────────

  Widget _buildDiagnosisChip(AppColors colors) {
    final labelColor = colors.forDisease(args.label);
    final pct = (args.confidence * 100).toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 3),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _displayLabel,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Onest',
                color: labelColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '$pct%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Onest',
                color: colors.textWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scan info + heatmap row ───────────────────────────────

  Widget _buildInfoAndHeatmapRow(BuildContext context, AppColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 48, child: _buildScanInfo(context, colors)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 52,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.pointsOfInterest.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Onest',
                      letterSpacing: 0.5,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // GestureDetector wraps only the image
                  GestureDetector(
                    onTap: () => _showFullHeatmap(context, colors),
                    child: FractionallySizedBox(
                      widthFactor: 0.85,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: args.heatmapPath != null
                              ? Image.file(
                                  File(args.heatmapPath!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      _heatmapPlaceholder(colors),
                                )
                              : _heatmapPlaceholder(colors),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                  Text(
                    l10n.heatmapCaption,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Onest',
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanInfo(BuildContext context, AppColors colors) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            l10n.scanInformation.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Onest',
              letterSpacing: 0.5,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(l10n.imageSource, _translatedSource(context),colors),
              const SizedBox(height: AppSpacing.xs),
              _buildInfoRow(l10n.dateLabel, _formattedDate, colors),
              const SizedBox(height: AppSpacing.xs),
              _buildInfoRow(l10n.timeLabel, _formattedTime, colors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'Onest',
            color: colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Onest',
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _heatmapPlaceholder(AppColors colors) {
    return SizedBox.expand(
      child: ColoredBox(
        color: colors.surfaceGray,
        child: Center(
          child: Icon(
            Icons.image_search_rounded,
            color: colors.textSecondary,
            size: 32,
          ),
        ),
      ),
    );
  }

  // ── Confidence breakdown ──────────────────────────────────

  Widget _buildConfidenceBreakdown(AppColors colors) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            'CONFIDENCE BREAKDOWN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Onest',
              letterSpacing: 0.6,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: AppConstants.classNames.map((className) {
              final confidence = args.predictions[className] ?? 0.0;
              final isLast = className == AppConstants.classNames.last;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
                child: _ConfidenceRow(
                  label: className.replaceAll('_', ' '),
                  confidence: confidence,
                  colors: colors,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Back to Home button ───────────────────────────────────

  Widget _buildBackToHomeButton(BuildContext context, AppColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => _onBackToHome(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.buttonBg,
            foregroundColor: colors.textWhite,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text(
            l10n.backToHome,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Onest',
              color: colors.textWhite,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CONFIDENCE ROW  (mirrors live_scan_screen.dart)
// ============================================================

class _ConfidenceRow extends StatelessWidget {
  final String label;
  final double confidence;
  final AppColors colors;

  const _ConfidenceRow({
    required this.label,
    required this.confidence,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = colors.forConfidence(confidence);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Onest',
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: confidence,
              backgroundColor: colors.confidenceBar,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 36,
          child: Text(
            '${(confidence * 100).toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Onest',
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}