import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:skin_sync/custom_snackbar.dart';
import 'package:skin_sync/model/skin_analysis_history.dart';
import 'package:skin_sync/utils/sqflite_database.dart';
import 'package:skin_sync/utils/storage.dart';
import '../../model/tflite/tflite_repository.dart';

class SkincareAnalysisController extends GetxController {
  final TFLiteRepository _tfLiteRepo = TFLiteRepository();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxList<dynamic> results = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isModelReady = false.obs;
  final RxBool isImageLoading = false.obs;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    _initializeModel();
    final imagePath = Get.parameters['imagePath'];
    if (imagePath != null) {
      selectedImage.value = File(imagePath);
      _analyzeImage(imagePath);
    }
    super.onInit();
  }

  Future<void> _initializeModel() async {
    try {
      await _tfLiteRepo.initialize();
      isModelReady.value = true;
    } catch (e) {
      showErrorSnackbar("Error", "Failed to load AI model: ${e.toString()}");
    }
  }

  Future<void> _analyzeImage(String path) async {
    isLoading.value = true;
    try {
      await _initializeModel();
      // final correctedFile = await _correctImageOrientation(imageFile);

      // We are adding human skin check
      final imageFile = File(path);
      final correctedFile = await _correctImageOrientation(imageFile);
      if (!await _isHumanSkin(correctedFile)) {
        throw Exception(
            'Not a valid skin image. Please upload clear skin photo');
      }

      final modelOutput = await _tfLiteRepo.analyzeImage(path);
      final labels = await _tfLiteRepo.loadLabels();
      results.value = parseResults(modelOutput, labels);
    } catch (e) {
      showErrorSnackbar("Error", e.toString());
    }
    isLoading.value = false;
  }

  Future<File> _correctImageOrientation(File file) async {
    final image = img.decodeImage(await file.readAsBytes());
    final oriented = img.bakeOrientation(image!);
    return File(file.path)..writeAsBytesSync(img.encodeJpg(oriented));
  }

  Future<bool> _isHumanSkin(File imageFile) async {
    try {
      final image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) return false;

      // Resize while maintaining aspect ratio
      final resized = img.copyResize(image, width: 200, height: 200);

      int skinPixels = 0;
      final totalPixels = resized.width * resized.height;
      const minSkinPercentage = 0.25; // 25% of image must be skin-like

      for (int y = 0; y < resized.height; y++) {
        for (int x = 0; x < resized.width; x++) {
          final pixel = resized.getPixel(x, y);

          // Convert to both color spaces
          final hsv = _rgbToHsv(
              (pixel.r).toInt(), (pixel.g).toInt(), (pixel.b).toInt());
          final yCbCr = _rgbToYCbCr(
              (pixel.r).toInt(), (pixel.g).toInt(), (pixel.b).toInt());

          // Combined skin detection conditions
          final bool isSkin =
              // HSV conditions (broader ranges)
              (hsv[0] >= 0.0 && hsv[0] <= 0.1) && // Hue 0-36°
                  (hsv[1] >= 0.15 && hsv[1] <= 0.9) && // Saturation 15-90%
                  (hsv[2] >= 0.2 && hsv[2] <= 0.95) && // Value 20-95%

                  // YCbCr conditions (known skin ranges)
                  (yCbCr[1] >= 80 && yCbCr[1] <= 130) && // Cb
                  (yCbCr[2] >= 135 && yCbCr[2] <= 180); // Cr

          if (isSkin) skinPixels++;
        }
      }

      final isSkin = (skinPixels / totalPixels) > minSkinPercentage;
      print(
          'Skin detection: ${(skinPixels / totalPixels * 100).toStringAsFixed(1)}%');
      return isSkin;
    } catch (e) {
      print('Skin validation error: $e');
      return false;
    }
  }

// New YCbCr conversion method
  List<int> _rgbToYCbCr(int r, int g, int b) {
    final y = (0.299 * r + 0.587 * g + 0.114 * b).round();
    final cb = (128 - 0.168736 * r - 0.331264 * g + 0.5 * b).round();
    final cr = (128 + 0.5 * r - 0.418688 * g - 0.081312 * b).round();
    return [y.clamp(0, 255), cb.clamp(0, 255), cr.clamp(0, 255)];
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

    return [
      h / 360, // Hue (0-1)
      max == 0 ? 0 : delta / max, // Saturation
      max // Value
    ];
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

      return {
        'medicalLabel': medicalLabel,
        'displayLabel': _mapLabel(medicalLabel),
        'riskLevel': riskLevel,
        'riskColor': _getRiskColor(riskLevel),
        'confidence': scores[index],
      };
    });
    resultList.sort((a, b) => ((b['confidence'] ?? 0) as double)
        .compareTo((a['confidence'] ?? 0) as double));
    return resultList;
  }

  Future<void> saveAnalysis() async {
    try {
      final imageFile = selectedImage.value;
      if (imageFile == null) throw Exception('No image to save');
      if (!await imageFile.exists()) {
        throw Exception('Local image file not found');
      }
      final userId = StorageService.instance.fetch('userId');
      if (userId == null || userId.isEmpty) {
        throw Exception('User not authenticated');
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage.ref('users/$userId/analysis/$timestamp.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
      final imageUrl = await storageRef.getDownloadURL();
      final history = SkinAnalysisHistory(
        imageUrl: imageUrl,
        results: results.map((r) => r as Map<String, dynamic>).toList(),
        date: DateTime.now(),
      );

      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertAnalysis(history);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('skinAnalysis')
          .doc(history.id.toString())
          .set(history.toMap());

      showErrorSnackbar('Success', 'Analysis saved successfully!');
    } catch (e) {
      showErrorSnackbar(
        'Error',
        'Failed to save analysis: ${e.toString()}',
      );
      print('Full error details: $e');
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
      showErrorSnackbar("Error", "Sharing failed: ${e.toString()}");
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
