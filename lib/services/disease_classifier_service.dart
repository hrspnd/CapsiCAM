// disease_classifier_service.dart
//
// Runs the dual-output MobileNetV2 TFLite model fully offline, and
// computes the CAM ("Points of Interest") heatmap on-device using the
// exported feature maps + cam_weights.json — no gradients, no server,
// no internet connection required.
//

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassificationResult {
  final String predictedClass;
  final double confidence;
  final Map<String, double> confidenceByClass; // for the breakdown UI
  final img.Image heatmapOverlay; // ready to display as the "Points of Interest" image

  ClassificationResult({
    required this.predictedClass,
    required this.confidence,
    required this.confidenceByClass,
    required this.heatmapOverlay,
  });
}

class DiseaseClassifierService {
  static const int inputSize = 224;
  static const int featureMapSize = 7; // 7x7 spatial grid from MobileNetV2's last conv layer
  static const int numChannels = 1280; // MobileNetV2's last conv layer channel count

  late Interpreter _interpreter;
  late List<String> _classNames;
  late List<List<double>> _camWeights; // [numClasses][numChannels]
  late List<double> _camBias; // [numClasses]

  bool _isLoaded = false;

  /// Loads the model and supporting files. Call this once, e.g. in your
  /// app's startup or the first time the scan screen is opened.
  Future<void> loadModel() async {
    if (_isLoaded) return;

    _interpreter = await Interpreter.fromAsset('assets/model/model_dual_output.tflite');

    final classNamesJson = await rootBundle.loadString('assets/model/class_names.json');
    _classNames = List<String>.from(jsonDecode(classNamesJson));

    final camWeightsJson = await rootBundle.loadString('assets/model/cam_weights.json');
    final camData = jsonDecode(camWeightsJson);
    _camWeights = (camData['weights'] as List)
        .map<List<double>>((row) => List<double>.from(row))
        .toList();
    _camBias = List<double>.from(camData['bias']);

    _isLoaded = true;
  }

  /// Runs classification + CAM heatmap generation on a single image file
  /// (from gallery upload or camera capture).
  Future<ClassificationResult> classify(File imageFile) async {
    if (!_isLoaded) {
      throw StateError('Call loadModel() before classify().');
    }

    // --- 1. Preprocess the image to match training preprocessing ---
    final rawBytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw ArgumentError('Could not decode image file.');
    }
    final resized = img.copyResize(decoded, width: inputSize, height: inputSize);

    // ImageNet normalization, matching the training transforms exactly:
    // mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]
    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              (pixel.r / 255.0 - mean[0]) / std[0],
              (pixel.g / 255.0 - mean[1]) / std[1],
              (pixel.b / 255.0 - mean[2]) / std[2],
            ];
          },
        ),
      ),
    );

    // --- 2. Prepare output buffers matching the model's two outputs ---
    // Output 0: feature_maps [1, 7, 7, 1280]
    // Output 1: class_probs  [1, 3]
    final featureMapsOutput = List.generate(
      1,
      (_) => List.generate(
        featureMapSize,
        (_) => List.generate(featureMapSize, (_) => List.filled(numChannels, 0.0)),
      ),
    );
    final classProbsOutput = List.generate(1, (_) => List.filled(_classNames.length, 0.0));

    final outputs = <int, Object>{
      0: featureMapsOutput,
      1: classProbsOutput,
    };

    _interpreter.runForMultipleInputs([input], outputs);

    // --- 3. Parse classification result ---
    final probs = classProbsOutput[0];
    int predictedIdx = 0;
    double maxProb = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > maxProb) {
        maxProb = probs[i];
        predictedIdx = i;
      }
    }

    final confidenceByClass = <String, double>{
      for (int i = 0; i < _classNames.length; i++) _classNames[i]: probs[i],
    };

    // --- 4. Compute CAM heatmap for the predicted class ---
    final heatmap = _computeCam(featureMapsOutput[0], predictedIdx);
    final overlay = _overlayHeatmap(resized, heatmap);

    return ClassificationResult(
      predictedClass: _classNames[predictedIdx],
      confidence: maxProb,
      confidenceByClass: confidenceByClass,
      heatmapOverlay: overlay,
    );
  }

  /// Computes the raw CAM heatmap (7x7 grid) for a given class index.
  /// This is the core CAM math: for each spatial location, sum the
  /// feature map channels weighted by that class's classifier weights.
  /// No gradients needed — this is why it works fully offline via TFLite.
  List<List<double>> _computeCam(
    List<List<List<double>>> featureMaps, // [7][7][1280]
    int classIdx,
  ) {
    final weights = _camWeights[classIdx]; // [1280]
    final heatmap = List.generate(featureMapSize, (_) => List.filled(featureMapSize, 0.0));

    double maxVal = double.negativeInfinity;
    double minVal = double.infinity;

    for (int y = 0; y < featureMapSize; y++) {
      for (int x = 0; x < featureMapSize; x++) {
        double sum = 0.0;
        for (int c = 0; c < numChannels; c++) {
          sum += featureMaps[y][x][c] * weights[c];
        }
        heatmap[y][x] = sum;
        if (sum > maxVal) maxVal = sum;
        if (sum < minVal) minVal = sum;
      }
    }

    // Normalize to 0-1 range for visualization
    final range = (maxVal - minVal).abs() < 1e-8 ? 1.0 : (maxVal - minVal);
    for (int y = 0; y < featureMapSize; y++) {
      for (int x = 0; x < featureMapSize; x++) {
        heatmap[y][x] = (heatmap[y][x] - minVal) / range;
      }
    }
    return heatmap;
  }

  /// Upscales the 7x7 heatmap to the original image size and overlays it
  /// as a red-to-blue color map (matching the "Points of Interest" mockup),
  /// blended on top of the original leaf image.
  img.Image _overlayHeatmap(img.Image baseImage, List<List<double>> heatmap) {
    final overlay = img.Image.from(baseImage);
    final w = baseImage.width;
    final h = baseImage.height;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        // Map pixel coordinates back to the 7x7 heatmap grid (bilinear-ish
        // nearest-neighbor mapping; simple and fast, good enough for a
        // smoothed visual overlay).
        final gridX = (x / w * featureMapSize).floor().clamp(0, featureMapSize - 1);
        final gridY = (y / h * featureMapSize).floor().clamp(0, featureMapSize - 1);
        final intensity = heatmap[gridY][gridX]; // 0.0 - 1.0

        final heatColor = _jetColor(intensity);
        final basePixel = baseImage.getPixel(x, y);

        // Alpha-blend the heat color over the original pixel (60% heat, 40% original)
        const alpha = 0.6;
        final blendedR = (heatColor[0] * alpha + basePixel.r * (1 - alpha)).round();
        final blendedG = (heatColor[1] * alpha + basePixel.g * (1 - alpha)).round();
        final blendedB = (heatColor[2] * alpha + basePixel.b * (1 - alpha)).round();

        overlay.setPixelRgb(x, y, blendedR, blendedG, blendedB);
      }
    }
    return overlay;
  }

  /// Simple blue -> green -> yellow -> red color ramp ("jet"-style),
  /// matching the heatmap style shown in the app mockup.
  List<int> _jetColor(double value) {
    value = value.clamp(0.0, 1.0);
    final r = (255 * (value)).round().clamp(0, 255);
    final g = (255 * (1 - (value - 0.5).abs() * 2)).round().clamp(0, 255);
    final b = (255 * (1 - value)).round().clamp(0, 255);
    return [r, g, b];
  }

  void dispose() {
    if (_isLoaded) {
      _interpreter.close();
    }
  }
}
