import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ocrServiceProvider = Provider((ref) {
  final service = OCRService();
  ref.onDispose(() => service.dispose());
  return service;
});

class OCRService {
  final _textRecognizer = TextRecognizer();

  Future<RecognizedText> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
