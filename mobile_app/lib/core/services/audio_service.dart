import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  Timer? _timer;
  final StreamController<Uint8List> _audioStreamController = StreamController<Uint8List>.broadcast();

  bool get isRecording => _isRecording;
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> startRecording() async {
    if (_isRecording) {
      throw Exception('Recording already in progress');
    }

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    try {
      _isRecording = true;
      
      // Start recording with configurable settings
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
        ),
        path: 'audio_recording.wav',
      );

      // Simulate audio chunks for now (real implementation would read from file)
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_isRecording) {
          // Generate dummy audio data for testing
          final dummyData = Uint8List.fromList(List.generate(1024, (i) => i % 256));
          _audioStreamController.add(dummyData);
        }
      });
    } catch (e) {
      _isRecording = false;
      rethrow;
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    try {
      _timer?.cancel();
      _timer = null;
      await _recorder.stop();
      _isRecording = false;
    } catch (e) {
      _isRecording = false;
      rethrow;
    }
  }

  void dispose() {
    _timer?.cancel();
    _audioStreamController.close();
    _recorder.dispose();
  }
}