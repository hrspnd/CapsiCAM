// live_scan_screen.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';

// ============================================================
// LIVE SCAN SCREEN
// ============================================================

class LiveScanScreen extends StatefulWidget {
  const LiveScanScreen({super.key});

  @override
  State<LiveScanScreen> createState() => _LiveScanScreenState();
}

class _LiveScanScreenState extends State<LiveScanScreen>
    with WidgetsBindingObserver {
  // ── Camera ────────────────────────────────────────────────
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isTorchOn = false;

  // ── ML state ──────────────────────────────────────────────
  // TODO: Wire to TFLite inference loop
  String? _topLabel;
  double? _topConfidence;
  Map<String, double>? _predictions;

  // ── Simulate detection (remove when TFLite is wired) ──────
  void _simulateDetection() {
    setState(() {
      _topLabel = 'Healthy';
      _topConfidence = 0.92;
      _predictions = {
        'Bacterial_Leaf_Spot': 0.91,
        'Cercospora_Leaf_Spot': 0.27,
        'Healthy': 0.02,
      };
    });
  }

  // ── Lifecycle ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _initCamera(); // temporary disable_cam - UNCOMMENT PAG GAGAMITIN CAMERA
    _simulateDetection(); //temporary (PARA MAKITA YUNG LIVE SCAN N LIVE CONFIDENCE) -- delete after
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
      });

      // TODO: Start image stream for TFLite inference:
      // await controller.startImageStream((CameraImage image) {
      //   tfliteService.runInference(image).then((result) {
      //     if (!mounted) return;
      //     setState(() {
      //       _topLabel      = result.topLabel;
      //       _topConfidence = result.topConfidence;
      //       _predictions   = result.predictions;
      //     });
      //   });
      // });
    } on CameraException catch (e) {
      debugPrint('Camera init error: ${e.description}');
    }
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _onToggleTorch() async {
    if (_cameraController == null || !_isCameraReady) return;
    try {
      await _cameraController!.setFlashMode(
        _isTorchOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() => _isTorchOn = !_isTorchOn);
    } on CameraException catch (e) {
      debugPrint('Torch error: ${e.description}');
    }
  }

  void _onCapture() {
    // TODO: Freeze frame, save scan result, navigate to scan results
    // context.push(AppRoutes.scanResults, extra: {...});
  }

  void _onBack() {
    _cameraController?.dispose();
    context.pop();
  }

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
                    _buildCameraPreview(colors),
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
          _buildCaptureButton(colors),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(AppColors colors) {
    return Container(
      color: colors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.sm,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _onBack,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Text(
            'Live Scan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Onest',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Camera preview ────────────────────────────────────────

  Widget _buildCameraPreview(AppColors colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera feed or loading state
            if (_isCameraReady && _cameraController != null) 
              CameraPreview(_cameraController!, child: const SizedBox.expand())
            else
              Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colors.primaryLight,
                    strokeWidth: 2,
                  ),
                ),
              ),

            // Fixed scan overlay — only shown when detection exists
            // if (_isCameraReady && _topLabel != null && _topConfidence != null) //TEMPORARY -- UNCOMMENT PAG OKAY NA LELS
            if (_topLabel != null && _topConfidence != null) //TEMPORARY -- delete pag dna kailangan
              _FixedScanOverlay(
                label: _topLabel!,
                confidence: _topConfidence!,
                colors: colors,
              ),

            // Torch toggle
            Positioned(
              bottom: AppSpacing.lg,
              right: AppSpacing.lg,
              child: GestureDetector(
                onTap: _onToggleTorch,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isTorchOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Confidence breakdown ──────────────────────────────────

  Widget _buildConfidenceBreakdown(AppColors colors) {
    return Column(
      children: [
        // Title box
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

        // Rows box
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
              final confidence = _predictions?[className] ?? 0.0;
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

  // ── Capture button ────────────────────────────────────────

  Widget _buildCaptureButton(AppColors colors) {
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
          onPressed: _onCapture,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primaryDark,
            foregroundColor: colors.textWhite,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text(
            'Capture',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
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
// FIXED SCAN OVERLAY — centered box, no tracking needed
// ============================================================

class _FixedScanOverlay extends StatelessWidget {
  final String label;
  final double confidence;
  final AppColors colors;

  const _FixedScanOverlay({
    required this.label,
    required this.confidence,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Fixed box — always centered, 60% wide, 45% tall
        final boxW = w * 0.75;
        final boxH = h * 0.60;
        final left = (w - boxW) / 2;
        final top = (h - boxH) / 2;

        return Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Scanner box
      Container(
        width: boxW,
        height: boxH,
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.primaryLight,
            width: 5,
          ),
          // borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),

      const SizedBox(height: AppSpacing.sm),

      // Live confidence card
      Container(
        width: boxW * 0.9,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.bacterialBg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withValues(alpha: 0.12),
          //     blurRadius: 8,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Onest',
                color: colors.forDisease(label),
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Confidence ${(confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Onest',
                color: colors.textBlack.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
      },
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
    final barColor = colors.forDisease(label);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
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
              backgroundColor: colors.border,
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
