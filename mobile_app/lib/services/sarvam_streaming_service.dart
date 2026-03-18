import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';

class SarvamStreamingService {
  static WebSocketChannel? _channel;
  static StreamSubscription<String>? _subscription;
  static bool _isConnected = false;
  static bool _isTranscribing = false;

  static Future<void> initialize() async {
    if (_isConnected) return;
    print('Initializing Sarvam streaming service');
  }

  static Stream<String> startTranscription(String authToken) async* {
    if (_isTranscribing) {
      throw Exception('Transcription already in progress');
    }

    _isTranscribing = true;
    print('Starting Sarvam transcription');

    try {
      // Connect to Sarvam WebSocket endpoint
      final uri = Uri.parse('wss://api.sarvam.ai/v1/speech-to-text/stream');
      _channel = WebSocketChannel.connect(uri);

      await for (final message in _channel!.stream) {
        if (message is String) {
          final data = json.decode(message);
          
          if (data['type'] == 'transcript') {
            yield data['text'] as String;
          } else if (data['type'] == 'error') {
            print('Sarvam error: ${data['message']}');
            break;
          } else if (data['type'] == 'connected') {
            _isConnected = true;
            print('Connected to Sarvam streaming service');
          }
        }
      }
    } catch (e) {
      print('Sarvam streaming error: $e');
      rethrow;
    } finally {
      _isTranscribing = false;
      await _disconnect();
    }
  }

  static Future<void> stopTranscription() async {
    if (!_isTranscribing) return;

    print('Stopping Sarvam transcription');
    _isTranscribing = false;
    await _disconnect();
  }

  static Future<void> _disconnect() async {
    try {
      await _channel?.sink.close();
      _channel = null;
      _isConnected = false;
      print('Disconnected from Sarvam streaming service');
    } catch (e) {
      print('Error disconnecting from Sarvam: $e');
    }
  }

  static bool get isConnected => _isConnected;
  static bool get isTranscribing => _isTranscribing;

  static Map<String, dynamic> _buildAuthPayload(String authToken) {
    return {
      'type': 'auth',
      'token': authToken,
      'config': {
        'language': 'en',
        'model': 'sarvam-v2',
        'sample_rate': 16000,
        'encoding': 'pcm16',
      },
    };
  }

  static Map<String, dynamic> _buildStartPayload() {
    return {
      'type': 'start',
      'config': {
        'continuous': true,
        'interim_results': true,
        'punctuation': true,
        'timestamps': true,
      },
    };
  }
}
