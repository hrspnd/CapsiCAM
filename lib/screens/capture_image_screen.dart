// capture_image_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

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

  static const _tipSeenKey = 'capture_tips_seen';

  // ── Lifecycle ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _showTipsIfFirstTime()); //temporary -- uncomment later
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTipsDialog());
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
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _onUploadFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _onAnalyze() {
    if (_selectedImage == null) return;
    // TODO: Run TFLite inference on _selectedImage
    // TODO: context.push(AppRoutes.scanResults, extra: {...});
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
              ? Image.file(_selectedImage!, fit: BoxFit.cover)
              : _buildEmptyPreview(colors),
        ),
      ),
    );
  }

  Widget _buildEmptyPreview(AppColors colors) {
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
            'No image selected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Onest',
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap below to take a photo or\nupload from your gallery',
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
              _selectedImage != null ? 'Take New Photo' : 'Take Photo',
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
                  ? 'Choose Different Photo'
                  : 'Upload from Gallery',
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
          onPressed: _selectedImage != null ? _onAnalyze : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.buttonBg,
            foregroundColor: colors.textWhite,
            disabledBackgroundColor: colors.textGray.withValues(alpha: 0.8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text(
            'Analyze',
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
// TIPS DIALOG
// ============================================================

class _TipsDialog extends StatelessWidget {
  final AppColors colors;

  const _TipsDialog({required this.colors});

  static const _tips = [
    'Scan in good lighting for best results',
    'Center the leaf within the frame',
    'Hold your phone steady while scanning',
    'Scan a single leaf at a time for accurate results',
  ];

  @override
  Widget build(BuildContext context) {
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
              'Before you scan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Onest',
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'A few tips for the best results',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Onest',
                color: colors.textGray,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tips list
            ..._tips.map(
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
                  'Got it',
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
