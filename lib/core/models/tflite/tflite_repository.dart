import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/models/tflite/processing.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteRepository {
  Interpreter? _interpreter;
  List<String> labels = [];

  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
      labels = await rootBundle
          .loadString('assets/models/labels.txt')
          .then((str) => str.split('\n'));
      debugPrint('Number of labels: ${labels.length}');
      debugPrint('Model output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      throw ServerException(message: 'Initialization failed: $e');
    }
  }

  Future<List<String>> loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      return labelData.split('\n');
    } catch (e) {
      throw ServerException(message: 'Failed to load labels: $e');
    }
  }

  Future<List<List<double>>> analyzeImage(String imagePath) async {
    if (_interpreter == null) {
      throw const ServerException(message: 'Interpreter not initialized!');
    }
    final input = preprocessImage(imagePath).reshape([1, 224, 224, 3]);
    final output = List<double>.filled(1 * 5, 0.0).reshape([1, 5]);
    _interpreter!.run(input, output);
    return output.cast<List<double>>();
  }

  void dispose() {
    _interpreter?.close();
  }
}
