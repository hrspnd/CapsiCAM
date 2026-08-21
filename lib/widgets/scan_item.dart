// lib/widgets/scan_item.dart
//
// Shared row widget for a single scan, used by both the dashboard's
// "Recent Scans" preview and the full Scan History list. Previously
// two near-identical copies of this widget lived in each screen file.

import 'package:flutter/material.dart';
import 'package:thesis_app/constants.dart';
import 'package:thesis_app/l10n/app_localizations.dart';
import 'package:thesis_app/models/scan_result.dart';

class ScanItem extends StatelessWidget {
  final ScanResult scan;
  final VoidCallback onTap;
  final AppColors colors;

  const ScanItem({
    super.key,
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