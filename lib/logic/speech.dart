// ── Voice narration (English / Hindi / Kannada) via the system TTS engine ──

import 'package:flutter_tts/flutter_tts.dart';

import 'i18n.dart';

class Speech {
  static final FlutterTts _tts = FlutterTts();
  static String _currentLang = '';

  static Future<void> _setup(String lang) async {
    if (_currentLang == lang) return;
    final locale = ttsLocales[lang] ?? 'en-IN';
    try {
      final available = await _tts.isLanguageAvailable(locale);
      await _tts.setLanguage(available == true ? locale : 'en-IN');
    } catch (_) {
      await _tts.setLanguage('en-IN');
    }
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    _currentLang = lang;
  }

  static Future<void> speak(String text, String lang) async {
    await _setup(lang);
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() => _tts.stop();
}
