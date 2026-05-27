import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// ML Kit based skin/human detection service
class MLKitSkinDetector {
  ImageLabeler? _imageLabeler;

  /// Labels that indicate valid human skin image
  static const _validLabels = {
    'person',
    'human',
    'skin',
    'face',
    'hand',
    'arm',
    'leg',
    'body',
    'portrait',
    'selfie',
    'people',
    'human body',
    'human face',
    'forehead',
    'cheek',
    'nose',
    'chin',
    'neck',
  };

  /// Minimum confidence threshold for label detection
  static const _minConfidence = 0.5;

  /// Initialize the image labeler
  Future<void> initialize() async {
    _imageLabeler ??= ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: _minConfidence),
    );
  }

  /// Check if the image contains valid human skin
  /// Returns true if any human-related labels are detected
  Future<bool> isValidSkinImage(File imageFile) async {
    try {
      await initialize();

      final inputImage = InputImage.fromFile(imageFile);
      final labels = await _imageLabeler!.processImage(inputImage);

      // Check if any detected label matches our valid labels
      for (final label in labels) {
        final labelText = label.label.toLowerCase();

        // Check for exact match or partial match
        for (final validLabel in _validLabels) {
          if (labelText.contains(validLabel) || validLabel.contains(labelText)) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      // If ML Kit fails, return true to allow fallback to other methods
      return true;
    }
  }

  /// Get detected labels for debugging
  Future<List<String>> getDetectedLabels(File imageFile) async {
    try {
      await initialize();

      final inputImage = InputImage.fromFile(imageFile);
      final labels = await _imageLabeler!.processImage(inputImage);

      return labels
          .map((l) => '${l.label} (${(l.confidence * 100).toStringAsFixed(1)}%)')
          .toList();
    } catch (e) {
      return ['Error: $e'];
    }
  }

  /// Dispose resources
  void dispose() {
    _imageLabeler?.close();
    _imageLabeler = null;
  }
}
