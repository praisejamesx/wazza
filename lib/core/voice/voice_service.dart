import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' show SpeechListenOptions;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechInitialized = false;
  bool _isListening = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  Future<bool> initSpeech() async {
    if (_speechInitialized) return true;
    try {
      _speechInitialized = await _speech.initialize(
        onStatus: (status) {
          dev.log('[VoiceService] Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        onError: (error) {
          dev.log('[VoiceService] Speech error: $error');
          _isListening = false;
        },
      );
      return _speechInitialized;
    } catch (e) {
      dev.log('[VoiceService] Init speech error: $e');
      return false;
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'en_US',
  }) async {
    final ready = await initSpeech();
    if (!ready || _speech.isListening) return;

    _isListening = true;
    _lastWords = '';

    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onResult(_lastWords);
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    _isListening = false;
    _lastWords = '';
  }

  Future<void> initTts() async {
    try {
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      await _tts.setLanguage('en-US');
    } catch (e) {
      dev.log('[VoiceService] Init TTS error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await initTts();
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<void> pauseSpeaking() async {
    await _tts.pause();
  }

  Future<void> setLanguage(String languageCode) async {
    await _tts.setLanguage(languageCode);
  }

  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  void dispose() {
    _speech.cancel();
    _tts.stop();
  }
}

final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = VoiceService();
  ref.onDispose(() => service.dispose());
  return service;
});
