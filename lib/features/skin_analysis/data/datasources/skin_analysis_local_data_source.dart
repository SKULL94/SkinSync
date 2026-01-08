import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/features/skin_analysis/data/models/analysis_result_model.dart';
import 'package:skin_sync/core/models/tflite/tflite_repository.dart';

abstract class SkinAnalysisLocalDataSource {
  Future<void> initializeModel();
  Future<List<AnalysisResultModel>> analyzeImage(File imageFile);
  void dispose();
}

class SkinAnalysisLocalDataSourceImpl implements SkinAnalysisLocalDataSource {
  final TFLiteRepository _tfLiteRepo = TFLiteRepository();
  bool _isModelReady = false;

  @override
  Future<void> initializeModel() async {
    if (!_isModelReady) {
      await _tfLiteRepo.initialize();
      _isModelReady = true;
    }
  }

  @override
  Future<List<AnalysisResultModel>> analyzeImage(File imageFile) async {
    try {
      await initializeModel();

      final bytes = await imageFile.readAsBytes();
      final orientedImage = await compute(_correctOrientationFromBytes, bytes);
      final correctedFile = File(imageFile.path)
        ..writeAsBytesSync(img.encodeJpg(orientedImage));

      final correctedBytes = await correctedFile.readAsBytes();
      final isSkin = await compute(_isHumanSkinFromBytes, correctedBytes);

      if (!isSkin) {
        throw const ValidationException(
          message: 'Not a valid skin image. Please upload clear skin photo',
        );
      }

      final modelOutput = await _tfLiteRepo.analyzeImage(correctedFile.path);
      final labels = await _tfLiteRepo.loadLabels();
      return _parseResults(modelOutput, labels);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(message: 'Analysis failed: $e');
    }
  }

  List<AnalysisResultModel> _parseResults(
    List<List<double>> modelOutput,
    List<String> labels,
  ) {
    final scores = modelOutput[0];

    final resultList = List.generate(scores.length, (index) {
      final medicalLabel = labels[index];
      final riskLevel = _getRiskLevel(medicalLabel);
      final color = _getRiskColor(riskLevel);

      return AnalysisResultModel(
        medicalLabel: medicalLabel,
        displayLabel: _mapLabel(medicalLabel),
        riskLevel: riskLevel,
        riskColorValue: color.toARGB32(),
        confidence: scores[index],
      );
    });

    resultList.sort(
      (a, b) => b.confidence.compareTo(a.confidence),
    );
    return resultList;
  }

  String _mapLabel(String medicalLabel) {
    const labelMap = {
      'Melanocytic nevi (nv)': 'Benign Mole',
      'Melanoma (mel)': 'Possible Skin Cancer',
      'Benign keratosis (bkl)': 'Harmless Skin Growth',
      'Basal cell carcinoma (bcc)': 'Skin Cancer (BCC)',
      'Actinic keratoses (akiec)': 'Pre-Cancerous Spot',
    };
    return labelMap[medicalLabel] ?? medicalLabel;
  }

  String _getRiskLevel(String label) {
    switch (label) {
      case 'Melanoma (mel)':
      case 'Basal cell carcinoma (bcc)':
        return 'High Risk';
      case 'Actinic keratoses (akiec)':
        return 'Medium Risk';
      default:
        return 'Low Risk';
    }
  }

  Color _getRiskColor(String riskLevel) {
    return switch (riskLevel) {
      'High Risk' => Colors.red,
      'Medium Risk' => Colors.orange,
      _ => Colors.green,
    };
  }

  @override
  void dispose() {
    _tfLiteRepo.dispose();
  }
}

img.Image _correctOrientationFromBytes(Uint8List bytes) {
  final image = img.decodeImage(bytes)!;
  return img.bakeOrientation(image);
}

bool _isHumanSkinFromBytes(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return false;

  final resized = img.copyResize(image, width: 200, height: 200);

  int skinPixels = 0;
  final totalPixels = resized.width * resized.height;
  const minSkinPercentage = 0.25;

  for (int y = 0; y < resized.height; y++) {
    for (int x = 0; x < resized.width; x++) {
      final pixel = resized.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      final hsv = _rgbToHsv(r, g, b);
      final yCbCr = _rgbToYCbCr(r, g, b);

      final isSkin = (hsv[0] >= 0.0 && hsv[0] <= 0.1) &&
          (hsv[1] >= 0.15 && hsv[1] <= 0.9) &&
          (hsv[2] >= 0.2 && hsv[2] <= 0.95) &&
          (yCbCr[1] >= 80 && yCbCr[1] <= 130) &&
          (yCbCr[2] >= 135 && yCbCr[2] <= 180);

      if (isSkin) skinPixels++;
    }
  }

  return (skinPixels / totalPixels) > minSkinPercentage;
}

List<double> _rgbToHsv(int r, int g, int b) {
  final double rd = r / 255;
  final double gd = g / 255;
  final double bd = b / 255;

  final double max = [rd, gd, bd].reduce((a, b) => a > b ? a : b);
  final double min = [rd, gd, bd].reduce((a, b) => a < b ? a : b);
  final double delta = max - min;

  double h = 0;
  if (delta != 0) {
    if (max == rd) h = (gd - bd) / delta % 6;
    if (max == gd) h = (bd - rd) / delta + 2;
    if (max == bd) h = (rd - gd) / delta + 4;
    h *= 60;
    if (h < 0) h += 360;
  }

  return [h / 360, max == 0 ? 0 : delta / max, max];
}

List<int> _rgbToYCbCr(int r, int g, int b) {
  final y = (0.299 * r + 0.587 * g + 0.114 * b).round();
  final cb = (128 - 0.168736 * r - 0.331264 * g + 0.5 * b).round();
  final cr = (128 + 0.5 * r - 0.418688 * g - 0.081312 * b).round();
  return [y.clamp(0, 255), cb.clamp(0, 255), cr.clamp(0, 255)];
}
