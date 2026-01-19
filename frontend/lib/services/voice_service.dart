import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;

  // Initialize speech to text
  Future<bool> initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    return available;
  }

  // Start listening
  Future<String?> startListening({
    required Function(String) onResult,
    Function()? onListeningStarted,
    Function()? onListeningStopped,
  }) async {
    if (!_isListening) {
      _isListening = true;
      onListeningStarted?.call();

      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            _isListening = false;
            onListeningStopped?.call();
          }
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: 'ml_IN', // Malayalam locale
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
    return null;
  }

  // Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  // Text to Speech
  Future<void> speak(String text) async {
    await _tts.setLanguage("ml-IN"); // Malayalam
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // Check if currently speaking
  Future<bool> isSpeaking() async {
    return await _tts.isSpeaking;
  }

  // Dispose resources
  void dispose() {
    _speech.cancel();
    _tts.stop();
  }
}