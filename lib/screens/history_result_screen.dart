// history_result_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import 'package:thesis_app/services/scan_refresh_bus.dart';

// ============================================================
// HISTORY RESULT SCREEN
// ============================================================

// Pass this as `extra` when navigating to this screen:
//
// context.push(AppRoutes.historyResult, extra: HistoryResultArgs(
//   imagePath:   '/path/to/image.jpg',
//   label:       'Bacterial_Leaf_Spot',
//   confidence:  0.91,
//   predictions: {
//     'Bacterial_Leaf_Spot':  0.91,
//     'Cercospora_Leaf_Spot': 0.27,
//     'Healthy':              0.02,
//   },
//   source:      AppConstants.sourceScanned,
//   date:        DateTime.now(),
//   heatmapPath: '/path/to/heatmap.jpg', // nullable
// ));

class HistoryResultArgs {
  final String imagePath;
  final String label;
  final double confidence;
  final Map<String, double> predictions;
  final String source;
  final DateTime date;
  final String? heatmapPath;

  const HistoryResultArgs({
    required this.imagePath,
    required this.label,
    required this.confidence,
    required this.predictions,
    required this.source,
    required this.date,
    this.heatmapPath,
  });
}

class HistoryResultScreen extends StatelessWidget {
  final HistoryResultArgs args;

  const HistoryResultScreen({super.key, required this.args});

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

  bool _isNetworkPath(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  /// Renders [path] as a network image when it's a URL (e.g. a Supabase
  /// storage link), or a bundled asset image otherwise (e.g. the
  /// placeholder sample images used as fallbacks).
  Widget _scanImage(
    String path, {
    required BoxFit fit,
    double? width,
    required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
  }) {
    if (_isNetworkPath(path)) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        errorBuilder: errorBuilder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
    return Image.asset(path, fit: fit, width: width, errorBuilder: errorBuilder);
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

  void _onBack(BuildContext context) {
    // Let listening screens (history list, dashboard) know to
    // reload, in case anything changed while viewing this scan.
    ScanRefreshBus.notify();
    context.pop();
  }

  void _showFullImage(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (_) => GestureDetector(
        onTap: () => context.pop(),
        onVerticalDragStart: (_) => context.pop(),
        onHorizontalDragStart: (_) => context.pop(),
        child: Scaffold(
          backgroundColor: colors.textBlack,
          body: Center(
            child: InteractiveViewer(
              child: _scanImage(
                args.imagePath,
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported_outlined,
                  color: colors.textGray,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullHeatmap(BuildContext context, AppColors colors) {
    if (args.heatmapPath == null) return;
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (_) => GestureDetector(
        onTap: () => context.pop(),
        onVerticalDragStart: (_) => context.pop(),
        onHorizontalDragStart: (_) => context.pop(),
        child: Scaffold(
          backgroundColor: colors.textBlack,
          body: Center(
            child: InteractiveViewer(
              child: _scanImage(
                args.heatmapPath!,
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported_outlined,
                  color: colors.textGray,
                  size: 64,
                ),
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
    final l10n = AppLocalizations.of(context)!;

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
                    if (args.label == 'Healthy') ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildHealthyDisclaimer(colors, l10n),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _buildInfoAndHeatmapRow(context, colors),
                    const SizedBox(height: AppSpacing.lg),
                    Divider(color: colors.border, thickness: 1),
                    const SizedBox(height: AppSpacing.lg),
                    _buildConfidenceBreakdown(colors),
                    const SizedBox(height: AppSpacing.lg),
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
            'Scan Details',
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
          child: _scanImage(
            args.imagePath,
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

  // ── Healthy-result disclaimer ─────────────────────────────

  /// Shown only when the diagnosis is "Healthy" — clarifies that this
  /// means none of the diseases the model was trained on were
  /// detected, not that the plant is guaranteed problem-free.
  Widget _buildHealthyDisclaimer(AppColors colors, AppLocalizations l10n) {
    // Splits the localized string around the literal "'Healthy'" so
    // just that word can be italicized, while the rest of the
    // sentence stays fully translatable via l10n.healthyWarning. If
    // the ARB text is ever edited and no longer contains this exact
    // substring, falls back to showing the plain string rather than
    // assuming a match that isn't there.
    const target = "'Healthy'";
    final fullText = l10n.healthyWarning;
    final parts = fullText.split(target);
    final baseStyle = TextStyle(
      fontSize: 10,
      fontFamily: 'Onest',
      color: colors.textSecondary,
      height: 1.4,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.healthyDisclaimer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: parts.length == 2
                ? Text.rich(
                    TextSpan(
                      style: baseStyle,
                      children: [
                        TextSpan(text: parts[0]),
                        TextSpan(
                          text: target,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(text: parts[1]),
                      ],
                    ),
                  )
                : Text(fullText, style: baseStyle),
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
                  GestureDetector(
                    onTap: () => _showFullHeatmap(context, colors),
                    child: FractionallySizedBox(
                      widthFactor: 0.85,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: args.heatmapPath != null
                              ? _scanImage(
                                  args.heatmapPath!,
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
              _buildInfoRow(l10n.imageSource, _translatedSource(context), colors),
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
}

// ============================================================
// CONFIDENCE ROW
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