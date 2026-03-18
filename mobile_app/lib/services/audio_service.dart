import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  static AudioRecorder? _audioRecorder;
  static String? _recordingPath;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _audioRecorder = AudioRecorder();
      _isInitialized = true;
      print('Audio service initialized');
    } catch (e) {
      print('Failed to initialize audio service: $e');
      rethrow;
    }
  }

  static Future<void> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_audioRecorder == null) {
      throw Exception('Audio recorder not initialized');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      _recordingPath = '${directory.path}/consultation_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _audioRecorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
      );

      print('Recording started: $_recordingPath');
    } catch (e) {
      print('Failed to start recording: $e');
      rethrow;
    }
  }

  static Future<String?> stopRecording() async {
    if (_audioRecorder == null) return null;

    try {
      final path = await _audioRecorder!.stop();
      print('Recording stopped: $path');
      return path;
    } catch (e) {
      print('Failed to stop recording: $e');
      return null;
    }
  }

  static Future<void> dispose() async {
    try {
      await _audioRecorder?.stop();
      _audioRecorder = null;
      _isInitialized = false;
      print('Audio service disposed');
    } catch (e) {
      print('Error disposing audio service: $e');
    }
  }

  static bool get isRecording {
    try {
      final recorder = _audioRecorder;
      if (recorder == null) return false;
      return recorder.isRecording as bool;
    } catch (e) {
      return false;
    }
  }

  static String? get recordingPath => _recordingPath;

  static Future<bool> requestPermissions() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Failed to request microphone permission: $e');
      return false;
    }
  }

  static Future<bool> checkPermissions() async {
    try {
      final status = await Permission.microphone.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Failed to check microphone permission: $e');
      return false;
    }
  }
}
