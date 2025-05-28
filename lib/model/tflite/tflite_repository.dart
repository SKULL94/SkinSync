import 'package:flutter/services.dart';
import 'package:skin_sync/model/tflite/processing.dart';
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
      print('Number of labels: ${labels.length}');
      print('Model output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      throw Exception('Initialization failed: $e');
    }
  }

  Future<List<String>> loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      return labelData.split('\n');
    } catch (e) {
      throw Exception('Failed to load labels: $e');
    }
  }

  Future<List<List<double>>> analyzeImage(String imagePath) async {
    if (_interpreter == null) throw Exception('Interpreter not initialized!');
    final input = preprocessImage(imagePath).reshape([1, 224, 224, 3]);
    final output = List<double>.filled(1 * 5, 0.0).reshape([1, 5]);
    _interpreter!.run(input, output);
    return output.cast<List<double>>();
  }

  void dispose() {
    _interpreter?.close();
  }
}
