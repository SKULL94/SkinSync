import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
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

      Get.snackbar('Success', 'Analysis saved successfully!');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save analysis: ${e.toString()}',
        duration: const Duration(seconds: 5),
      );
      print('Full error details: $e');
    }
  }

  Future<void> _initializeModel() async {
    try {
      await _tfLiteRepo.initialize();
      isModelReady.value = true;
    } catch (e) {
      Get.snackbar("Error", "Failed to load AI model: ${e.toString()}");
    }
  }

  Future<void> _analyzeImage(String path) async {
    isLoading.value = true;
    try {
      await _initializeModel();
      final modelOutput = await _tfLiteRepo.analyzeImage(path);
      final labels = await _tfLiteRepo.loadLabels();
      results.value = parseResults(modelOutput, labels);
    } catch (e) {
      Get.snackbar("Error", "Analysis failed: ${e.toString()}");
    }
    isLoading.value = false;
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

  Future<void> shareAnalysis() async {
    try {
      final message = _buildShareMessage();
      await Share.share(
        message,
        subject: 'SkinSync Analysis Results',
        sharePositionOrigin: Rect.largest,
      );
    } catch (e) {
      Get.snackbar("Error", "Sharing failed: ${e.toString()}");
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
