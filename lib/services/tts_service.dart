import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsPlaybackState { stopped, playing, paused }

/// Service managing Text-to-Speech playback for the archival ledger.
/// Automatically chunks long narratives and Q&A dialogues so Android/Windows
/// TTS engines process text sequentially without clipping.
class TtsService extends ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  TtsPlaybackState _playbackState = TtsPlaybackState.stopped;
  TtsPlaybackState get playbackState => _playbackState;

  bool get isPlaying => _playbackState == TtsPlaybackState.playing;
  bool get isPaused => _playbackState == TtsPlaybackState.paused;
  bool get isStopped => _playbackState == TtsPlaybackState.stopped;

  List<String> _chunks = [];
  int _currentChunkIndex = 0;
  String _currentTitle = '';
  String _currentEntityId = '';

  int get currentChunkIndex => _currentChunkIndex;
  int get totalChunks => _chunks.length;
  String get currentTitle => _currentTitle;
  String get currentEntityId => _currentEntityId;
  String get currentChunkText =>
      (_chunks.isNotEmpty && _currentChunkIndex < _chunks.length)
          ? _chunks[_currentChunkIndex]
          : '';

  double _speechRate = 0.48; // Natural, deliberate archival reading pace
  double get speechRate => _speechRate;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(0.95); // Slightly deeper tone for archival feel

      _flutterTts.setCompletionHandler(() {
        _onChunkComplete();
      });

      _flutterTts.setErrorHandler((dynamic msg) {
        debugPrint('TTS Error: $msg');
        _playbackState = TtsPlaybackState.stopped;
        notifyListeners();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization warning: $e');
    }
  }

  /// Sets the reading material and begins speaking from the start or a chosen chunk.
  Future<void> startReading({
    required String entityId,
    required String title,
    required String fullText,
    int initialChunk = 0,
  }) async {
    await init();
    await stop();

    _currentEntityId = entityId;
    _currentTitle = title;
    _chunks = _splitIntoReadableChunks(fullText);
    _currentChunkIndex = initialChunk.clamp(0, _chunks.isEmpty ? 0 : _chunks.length - 1);

    if (_chunks.isNotEmpty) {
      _speakCurrentChunk();
    }
  }

  void _onChunkComplete() {
    if (_playbackState != TtsPlaybackState.playing) return;

    if (_currentChunkIndex + 1 < _chunks.length) {
      _currentChunkIndex++;
      notifyListeners();
      _speakCurrentChunk();
    } else {
      _playbackState = TtsPlaybackState.stopped;
      _currentChunkIndex = 0;
      notifyListeners();
    }
  }

  Future<void> _speakCurrentChunk() async {
    if (_chunks.isEmpty || _currentChunkIndex >= _chunks.length) return;

    final textToSpeak = _chunks[_currentChunkIndex];
    if (textToSpeak.trim().isEmpty) {
      _onChunkComplete();
      return;
    }

    _playbackState = TtsPlaybackState.playing;
    notifyListeners();

    try {
      await _flutterTts.speak(textToSpeak);
    } catch (e) {
      debugPrint('Error speaking chunk: $e');
      _playbackState = TtsPlaybackState.stopped;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      // In case pause is not supported on some engines, stop keeps position
      await _flutterTts.stop();
    }
    _playbackState = TtsPlaybackState.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_chunks.isEmpty) return;
    _speakCurrentChunk();
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
    _playbackState = TtsPlaybackState.stopped;
    notifyListeners();
  }

  Future<void> nextChunk() async {
    if (_currentChunkIndex + 1 < _chunks.length) {
      await _flutterTts.stop();
      _currentChunkIndex++;
      notifyListeners();
      if (_playbackState == TtsPlaybackState.playing) {
        _speakCurrentChunk();
      }
    }
  }

  Future<void> previousChunk() async {
    if (_currentChunkIndex > 0) {
      await _flutterTts.stop();
      _currentChunkIndex--;
      notifyListeners();
      if (_playbackState == TtsPlaybackState.playing) {
        _speakCurrentChunk();
      }
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  List<String> _splitIntoReadableChunks(String text) {
    // Clean markdown hashes and asterisks for natural speech
    final cleaned = text
        .replaceAll(RegExp(r'#{1,6}\s*'), '')
        .replaceAll(RegExp(r'\*\*Q:\*\*\s*'), 'Question: ')
        .replaceAll(RegExp(r'\*\*A:\*\*\s*'), 'Answer: ')
        .replaceAll(RegExp(r'\*{1,2}'), '')
        .replaceAll('── ❖ ──', '')
        .replaceAll('── ❦ ──', '')
        .replaceAll('---', '');

    final rawParagraphs = cleaned.split(RegExp(r'\n{2,}'));
    final List<String> result = [];

    for (final p in rawParagraphs) {
      final trimmed = p.trim();
      if (trimmed.isEmpty) continue;

      // Keep chunks under ~500 characters for optimal TTS cadence
      if (trimmed.length > 600) {
        final sentences = trimmed.split(RegExp(r'(?<=[.?!])\s+'));
        String currentBuffer = '';
        for (final s in sentences) {
          if ((currentBuffer + s).length > 500 && currentBuffer.isNotEmpty) {
            result.add(currentBuffer.trim());
            currentBuffer = '$s ';
          } else {
            currentBuffer += '$s ';
          }
        }
        if (currentBuffer.trim().isNotEmpty) {
          result.add(currentBuffer.trim());
        }
      } else {
        result.add(trimmed);
      }
    }

    return result;
  }
}
