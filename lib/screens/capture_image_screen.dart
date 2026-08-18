// capture_image_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../constants.dart';
import '../l10n/app_localizations.dart';
import '../services/disease_classifier_service.dart';
import '../services/scan_service.dart';
import 'scan_results_screen.dart'; // for ScanResultsArgs

// Add path_provider if not already present:
//   flutter pub add path_provider

// ============================================================
// CAPTURE IMAGE SCREEN
// ============================================================

class CaptureImageScreen extends StatefulWidget {
  const CaptureImageScreen({super.key});

  @override
  State<CaptureImageScreen> createState() => _CaptureImageScreenState();
}

class _CaptureImageScreenState extends State<CaptureImageScreen> {
  // ── Image state ───────────────────────────────────────────
  File? _selectedImage;
  final _picker = ImagePicker();

  final _classifier = DiseaseClassifierService();
  final _scanService = ScanService();
  bool _isAnalyzing = false;

  // Translates the model's raw output class names to the exact strings
  // AppConstants.classNames / the rest of the app already uses. Keeping
  // this mapping in one place means constants.dart doesn't need to change,
  // and every other screen that relies on those exact strings is unaffected.
  static const Map<String, String> _modelToAppClassName = {
    'Bacterial_Spot': 'Bacterial_Leaf_Spot',
    'Cercospora_Leaf_Spot': 'Cercospora_Leaf_Spot',
    'Healthy_Leaf': 'Healthy',
  };

  static const _tipSeenKey = 'capture_tips_seen';

  // ── Lifecycle ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _showTipsIfFirstTime()); //temporary -- uncomment later
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTipsDialog());
    _classifier.loadModel();
  }

  //TEMPORARY (UNCOMMENT PAG GAGAWIN NA FIRST TIME YUNG TIPS)
  // Future<void> _showTipsIfFirstTime() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final seen = prefs.getBool(_tipSeenKey) ?? false;
  //   if (!seen && mounted) {
  //     await _showTipsDialog();
  //     await prefs.setBool(_tipSeenKey, true);
  //   }
  // }

  Future<void> _showTipsDialog() async {
    final colors = AppColors.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TipsDialog(colors: colors),
    );
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _onTakePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (image != null) {
      final file = File(image.path);
      debugPrint(
        'picked path: ${image.path}, exists: ${await file.exists()}, size: ${await file.length()}',
      );
      if (mounted) {
        setState(() => _selectedImage = file);
      }
    }
  }

  Future<void> _onUploadFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image != null && mounted) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _onAnalyze() async {
    if (_selectedImage == null || _isAnalyzing) return;

    setState(() => _isAnalyzing = true);

    try {
      await _classifier.loadModel(); // no-op if already loaded

      final result = await _classifier.classify(_selectedImage!);

      // Translate model output names -> app's existing naming convention
      final translatedLabel =
          _modelToAppClassName[result.predictedClass] ?? result.predictedClass;
      final translatedPredictions = <String, double>{
        for (final entry in result.confidenceByClass.entries)
          (_modelToAppClassName[entry.key] ?? entry.key): entry.value,
      };

      // Save the heatmap overlay to a real file, since ScanResultsScreen
      // needs a file path (see Image.file fix noted separately)
      final heatmapPath = await _saveHeatmapToFile(result.heatmapOverlay);

      final args = ScanResultsArgs(
        imagePath: _selectedImage!.path,
        label: translatedLabel,
        confidence: result.confidence,
        predictions: translatedPredictions,
        source: AppConstants
            .sourceScanned, // adjust per capture vs gallery if tracked separately
        date: DateTime.now(),
        heatmapPath: heatmapPath,
      );

      // Persist the scan (image + classification) to Supabase. If this
      // fails, the user still sees their result — we just surface a
      // warning rather than blocking navigation on a save error.
      try {
        await _scanService.saveScan(args);
      } catch (saveError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scan analyzed but not saved: $saveError')),
          );
        }
      }

      if (!mounted) return;
      context.push(AppRoutes.scanResults, extra: args);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  /// Saves the CAM heatmap overlay (in-memory img.Image) to a temp file
  /// so it has a real file path, same as the original scanned image.
  Future<String> _saveHeatmapToFile(img.Image heatmap) async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/heatmap_${DateTime.now().millisecondsSinceEpoch}.png';
    final bytes = img.encodePng(heatmap);
    await File(path).writeAsBytes(bytes);
    return path;
  }

  void _onBack() => context.pop();

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    _buildImagePreview(colors),
                    const SizedBox(height: AppSpacing.lg),
                    Divider(color: colors.border, thickness: 1),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTakePhotoButton(colors),
                    const SizedBox(height: AppSpacing.sm),
                    _buildUploadButton(colors),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
          _buildAnalyzeButton(colors),
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
        children: [
          GestureDetector(
            onTap: _onBack,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Image.asset(
                AppAssets.backIcon,
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Scan Image',
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

  // ── Image preview ─────────────────────────────────────────

  Widget _buildImagePreview(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: _selectedImage != null
              ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildEmptyPreview(colors),
                )
              : _buildEmptyPreview(colors),
        ),
      ),
    );
  }

  Widget _buildEmptyPreview(AppColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: colors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.primaryDark,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Image.asset(
                AppAssets.noImage,
                width: 52,
                height: 52,
                color: colors.textWhite,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported_outlined,
                  size: 50,
                  color: colors.textWhite,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.noImageSelected,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Onest',
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.tapBelowHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Onest',
              color: colors.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Take photo button ─────────────────────────────────────

  Widget _buildTakePhotoButton(AppColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _onTakePhoto,
      child: Container(
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primaryDark,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Image.asset(
                  AppAssets.cameraIcon,
                  width: 22,
                  height: 22,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.camera_alt_outlined,
                    size: 22,
                    color: colors.background,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              _selectedImage != null ? l10n.takeNewPhoto : l10n.takePhoto,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Onest',
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Upload button ─────────────────────────────────────────

  Widget _buildUploadButton(AppColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _onUploadFromGallery,
      child: Container(
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primaryDark,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Image.asset(
                  AppAssets.uploadIcon,
                  width: 22,
                  height: 22,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.photo_library_outlined,
                    size: 22,
                    color: colors.primaryDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              _selectedImage != null
                  ? l10n.chooseDifferentPhoto
                  : l10n.uploadFromGallery,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Onest',
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Analyze button ────────────────────────────────────────

  Widget _buildAnalyzeButton(AppColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: colors.background,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: (_selectedImage != null && !_isAnalyzing)
              ? _onAnalyze
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.buttonBg,
            foregroundColor: colors.textWhite,
            disabledBackgroundColor: colors.textGray.withValues(alpha: 0.8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: _isAnalyzing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  l10n.analyzeButton,
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

  // ── Lifecycle: dispose ────────────────────────────────────

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }
}

// ============================================================
// TIPS DIALOG
// ============================================================

class _TipsDialog extends StatelessWidget {
  final AppColors colors;

  const _TipsDialog({required this.colors});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tips = [l10n.tip1, l10n.tip2, l10n.tip3, l10n.tip4];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      backgroundColor: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              l10n.beforeYouScan,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Onest',
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.tipsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Onest',
                color: colors.textGray,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tips list
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.sm,
                  bottom: AppSpacing.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(AppAssets.leafBullet, width: 24, height: 24),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        tip,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Onest',
                          color: colors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Got it button
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.buttonBg,
                  foregroundColor: colors.textWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
                  l10n.gotIt,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Onest',
                    color: colors.textWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}