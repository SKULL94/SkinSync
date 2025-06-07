import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:skin_sync/services/supabase_services.dart';
import 'package:skin_sync/utils/app_constants.dart';
import 'package:skin_sync/utils/custom_snackbar.dart';
import 'package:skin_sync/model/skin_analysis_history.dart';
import 'package:skin_sync/services/sqflite_database.dart';
import 'package:skin_sync/services/storage.dart';
import '../../../model/tflite/tflite_repository.dart';

class SkincareAnalysisController extends GetxController {
  final TFLiteRepository _tfLiteRepo = TFLiteRepository();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxList<dynamic> results = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isModelReady = false.obs;
  final RxBool isImageLoading = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> initializeModel() async {
    try {
      await _tfLiteRepo.initialize();
      isModelReady.value = true;
    } catch (e) {
      print("Model initialization error: $e");
    }
  }

  Future<void> setImageAndAnalyze(File imageFile) async {
    try {
      isLoading.value = true;
      selectedImage.value = imageFile;
      if (!isModelReady.value) {
        await initializeModel();
      }
      await _analyzeImage(imageFile.path);
    } catch (e) {
      showCustomSnackbar("Analysis Error", e.toString());
      selectedImage.value = null;
      results.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _analyzeImage(String path) async {
    isLoading.value = true;
    try {
      await initializeModel();

      final imageFile = File(path);
      final bytes = await imageFile.readAsBytes();

      final orientedImage = await compute(_correctOrientationFromBytes, bytes);
      final correctedFile = File(imageFile.path)
        ..writeAsBytesSync(img.encodeJpg(orientedImage));

      final correctedBytes = await correctedFile.readAsBytes();
      final isSkin = await compute(_isHumanSkinFromBytes, correctedBytes);

      if (!isSkin) {
        showCustomSnackbar(
            "Error", 'Not a valid skin image. Please upload clear skin photo');
        return;
      }

      final modelOutput = await _tfLiteRepo.analyzeImage(correctedFile.path);
      final labels = await _tfLiteRepo.loadLabels();
      results.value = parseResults(modelOutput, labels);
    } catch (e) {
      showCustomSnackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
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

  List<Map<String, dynamic>> parseResults(
      List<List<double>> modelOutput, List<String> labels) {
    final scores = modelOutput[0];

    final resultList = List.generate(scores.length, (index) {
      final medicalLabel = labels[index];
      final riskLevel = _getRiskLevel(medicalLabel);
      final color = _getRiskColor(riskLevel);

      return {
        'medicalLabel': medicalLabel,
        'displayLabel': _mapLabel(medicalLabel),
        'riskLevel': riskLevel,
        'riskColorValue': color.toARGB32(),
        'confidence': scores[index],
      };
    });

    resultList.sort((a, b) =>
        (b['confidence'] as double).compareTo(a['confidence'] as double));
    return resultList;
  }

  String _requireUserId() {
    final userId = StorageService.instance.fetch(AppConstants.userId);
    if (userId == null || userId.isEmpty) {
      showCustomSnackbar("Error", 'User not authenticated');
    }
    return userId;
  }

  Future<Uint8List> readFileWithoutBlocking(File file) async {
    final completer = Completer<Uint8List>();
    file
        .readAsBytes()
        .then(completer.complete)
        .catchError(completer.completeError);
    return completer.future;
  }

  Future<void> saveAnalysis() async {
    isSaving.value = true;
    showCustomSnackbar('Saving', 'Processing your analysis...');

    try {
      final imageFile = selectedImage.value;
      if (imageFile == null) {
        showCustomSnackbar("Error", 'No image to save');
        isSaving.value = false;
        return;
      }
      if (!await imageFile.exists()) {
        showCustomSnackbar("Error", 'Local image file not found');
      }

      final userId = _requireUserId();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'users/$userId/analysis/$timestamp.jpg';

      final placeholderHistory = SkinAnalysisHistory(
        imageUrl: AppConstants.placeholderImageUrl,
        results: results.map((r) => r as Map<String, dynamic>).toList(),
        date: DateTime.now(),
        id: userId,
      );

      final dbHelper = DatabaseHelper.instance;
      final localId = await dbHelper.insertAnalysis(placeholderHistory);

      showCustomSnackbar('Success', 'Analysis saved! Syncing in background');
      isSaving.value = false;

      final imageBytes = await readFileWithoutBlocking(imageFile);

      await SupabaseService.client.storage
          .from('images')
          .uploadBinary(filePath, imageBytes);

      final imageUrl =
          SupabaseService.client.storage.from('images').getPublicUrl(filePath);

      await dbHelper.updateAnalysis(localId, {'imageUrl': imageUrl});

      final completeHistory = SkinAnalysisHistory(
        imageUrl: imageUrl,
        results: placeholderHistory.results,
        date: placeholderHistory.date,
        id: userId,
      );

      await SupabaseService.client
          .from('images')
          .upsert(completeHistory.toMap());
      showCustomSnackbar('All done!', 'Good to go ✅');
    } catch (e) {
      showCustomSnackbar('Error',
          'Failed to save analysis: ${e.toString().split('\n').first}');
      isSaving.value = false;
    }
  }

  Future<void> shareAnalysis() async {
    try {
      final message = _buildShareMessage();
      await Share.share(
        message,
        subject: 'SkinSync Analysis Results',
        sharePositionOrigin: Rect.largest,
      );
    } catch (e) {
      showCustomSnackbar("Error", "Sharing failed: ${e.toString()}");
    }
  }

  String _buildShareMessage() {
    final topResult = results.isNotEmpty ? results[0] : null;
    return '''
🚨 SkinSync Analysis Report 🚨

Top Result: ${topResult?['displayLabel']} (${(topResult?['confidence'] * 100)?.toStringAsFixed(1)}%)
Risk Level: ${topResult?['riskLevel']}

Download App: https://skinsync.app/download
''';
  }

  @override
  void onClose() {
    _tfLiteRepo.dispose();
    super.onClose();
  }
}

// Skin Check Conditions

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

      final r = (pixel.r).toInt();
      final g = (pixel.g).toInt();
      final b = (pixel.b).toInt();

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

  final result = (skinPixels / totalPixels) > minSkinPercentage;
  print(
      'Skin detection: ${(skinPixels / totalPixels * 100).toStringAsFixed(1)}%');
  return result;
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
