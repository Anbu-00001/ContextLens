// ── On-device OCR (Google ML Kit, Latin + Devanagari) ──────────────────────
// Reads text from a screenshot entirely on-device — nothing is uploaded. This
// keeps the scam scanner private and lets it work offline. ML Kit recognizes
// Latin and Devanagari (Hindi), which covers the bulk of Indian scam messages.

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class Ocr {
  static final _latin = TextRecognizer(script: TextRecognitionScript.latin);
  static final _devanagari =
      TextRecognizer(script: TextRecognitionScript.devanagiri);

  /// Returns recognized text (Latin + Devanagari merged), or '' on failure.
  static Future<String> readImage(String path) async {
    final input = InputImage.fromFilePath(path);
    final buffer = StringBuffer();
    try {
      final latin = await _latin.processImage(input);
      buffer.writeln(latin.text);
    } catch (_) {}
    try {
      final dev = await _devanagari.processImage(input);
      if (dev.text.trim().isNotEmpty) buffer.writeln(dev.text);
    } catch (_) {}
    return buffer.toString().trim();
  }

  static Future<void> dispose() async {
    await _latin.close();
    await _devanagari.close();
  }
}
