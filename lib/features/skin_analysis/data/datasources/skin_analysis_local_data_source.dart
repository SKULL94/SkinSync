import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/services/ml_kit_skin_detector.dart';

abstract class SkinAnalysisLocalDataSource {
  Future<void> initialize();
  Future<bool> validateSkinImage(File imageFile);
  Future<File> prepareImage(File imageFile);
  void dispose();
}

class SkinAnalysisLocalDataSourceImpl implements SkinAnalysisLocalDataSource {
  final MLKitSkinDetector _mlKitDetector = MLKitSkinDetector();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _mlKitDetector.initialize();
      _isInitialized = true;
    }
  }

  @override
  Future<bool> validateSkinImage(File imageFile) async {
    try {
      await initialize();

      // Two-tier validation: ML Kit first, then color-based fallback
      final isValidByMLKit = await _mlKitDetector.isValidSkinImage(imageFile);

      if (isValidByMLKit) return true;

      // Fallback to color-based skin detection
      final bytes = await imageFile.readAsBytes();
      final isSkinByColor = await compute(_isHumanSkinFromBytes, bytes);

      return isSkinByColor;
    } catch (e) {
      debugPrint('Validation error: $e');
      return false;
    }
  }

  @override
  Future<File> prepareImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final orientedImage = await compute(_correctOrientationFromBytes, bytes);
      final correctedFile = File(imageFile.path)
        ..writeAsBytesSync(img.encodeJpg(orientedImage));
      return correctedFile;
    } catch (e) {
      throw ServerException(message: 'Failed to prepare image: $e');
    }
  }

  @override
  void dispose() {
    _mlKitDetector.dispose();
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
  const minSkinPercentage = 0.15;

  for (int y = 0; y < resized.height; y++) {
    for (int x = 0; x < resized.width; x++) {
      final pixel = resized.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      final hsv = _rgbToHsv(r, g, b);
      final yCbCr = _rgbToYCbCr(r, g, b);

      // HSV-based detection
      final isSkinHSV = (hsv[0] >= 0.0 && hsv[0] <= 0.15) &&
          (hsv[1] >= 0.10 && hsv[1] <= 0.95) &&
          (hsv[2] >= 0.15 && hsv[2] <= 0.98);

      // YCbCr-based detection
      final isSkinYCbCr = (yCbCr[1] >= 70 && yCbCr[1] <= 145) &&
          (yCbCr[2] >= 125 && yCbCr[2] <= 200);

      // RGB ratio-based detection
      final isSkinRGB = r > 60 &&
          g > 40 &&
          b > 20 &&
          r > g &&
          g > b &&
          (r - g).abs() > 10 &&
          r - b > 15;

      if (isSkinHSV || isSkinYCbCr || isSkinRGB) skinPixels++;
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
