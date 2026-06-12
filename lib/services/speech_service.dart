import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  Future<bool> initialize({
    Function(dynamic)? onError,
    Function(String)? onStatus,
  }) async {
    return await _speechToText.initialize(
      onError: onError,
      onStatus: onStatus,
    );
  }

  Future<void> listen({
    required Function(String) onResult,
    required String localeId,
  }) async {
    await _speechToText.listen(
      listenOptions: stt.SpeechListenOptions(localeId: localeId),
      onResult: (result) => onResult(result.recognizedWords),
    );
  }

  Future<void> stop() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
}
