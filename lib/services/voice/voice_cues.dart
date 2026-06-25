import 'package:flutter_tts/flutter_tts.dart';

abstract class VoiceCues {
  Future<void> say(String text);
}

/// Sin voz (tests / usuario que la desactiva).
class SilentVoiceCues implements VoiceCues {
  const SilentVoiceCues();
  @override
  Future<void> say(String text) async {}
}

/// Voz del dispositivo (offline) vía flutter_tts, en español.
class TtsVoiceCues implements VoiceCues {
  TtsVoiceCues() {
    _tts.setLanguage('es-ES');
    _tts.setSpeechRate(0.5);
  }
  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> say(String text) => _tts.speak(text);
}
