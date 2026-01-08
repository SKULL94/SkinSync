import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

Float32List preprocessImage(String imagePath) {
  final image = img.decodeImage(File(imagePath).readAsBytesSync())!;
  final resized = img.copyResize(image, width: 224, height: 224);

  final input = Float32List(1 * 224 * 224 * 3);
  var pixelIndex = 0;
  for (var y = 0; y < 224; y++) {
    for (var x = 0; x < 224; x++) {
      final pixel = resized.getPixel(x, y);
      input[pixelIndex++] = (pixel.r / 127.5) - 1.0; // R
      input[pixelIndex++] = (pixel.g / 127.5) - 1.0; // G
      input[pixelIndex++] = (pixel.b / 127.5) - 1.0; // B
    }
  }
  return input;
}
