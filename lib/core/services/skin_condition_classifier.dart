import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class SkinConditionResult {
  final String condition; // 'acne' or 'clear'
  final double confidence;
  final bool hasAcne;

  SkinConditionResult({
    required this.condition,
    required this.confidence,
    required this.hasAcne,
  });

  @override
  String toString() => '$condition (${(confidence * 100).toStringAsFixed(1)}%)';
}

class SkinConditionClassifier {
  static const String _modelPath = 'assets/models/skin_condition.tflite';
  static const int _inputSize = 224;

  Interpreter? _interpreter;
  bool _isInitialized = false;

  static final SkinConditionClassifier _instance = SkinConditionClassifier._internal();
  factory SkinConditionClassifier() => _instance;
  SkinConditionClassifier._internal();

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to load skin condition model: $e');
    }
  }

  Future<SkinConditionResult> classify(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final resized = img.copyResize(image, width: _inputSize, height: _inputSize);
    final input = _imageToInputTensor(resized);

    // Output shape: [1, 1] for binary classification with sigmoid
    final output = List.filled(1, List.filled(1, 0.0));

    _interpreter!.run(input, output);

    // Sigmoid output: closer to 1 = class 1 (clear), closer to 0 = class 0 (acne)
    final probability = output[0][0];

    // Determine class based on threshold
    final isAcne = probability < 0.5;
    final confidence = isAcne ? (1 - probability) : probability;

    return SkinConditionResult(
      condition: isAcne ? 'acne' : 'clear',
      confidence: confidence,
      hasAcne: isAcne,
    );
  }

  List<List<List<List<double>>>> _imageToInputTensor(img.Image image) {
    final tensor = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
    return tensor;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
