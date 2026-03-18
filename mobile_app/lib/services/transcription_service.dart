import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/transcription/transcript_display_formatter.dart';
import 'sarvam_streaming_service.dart';

class TranscriptionService {
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  static Future<String> transcribeAudioFile(String audioFilePath) async {
    if (audioFilePath.isEmpty) {
      throw ArgumentError('Audio file path cannot be empty');
    }

    print('Starting transcription for file: $audioFilePath');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final result = await _performTranscription(audioFilePath);
        print('Transcription completed on attempt $attempt');
        return result;
      } catch (e) {
        print('Transcription attempt $attempt failed: $e');
        
        if (attempt == _maxRetries) {
          rethrow;
        }
        
        // Wait before retry
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw Exception('Transcription failed after $_maxRetries attempts');
  }

  static Stream<String> startLiveTranscription(String authToken) async* {
    print('Starting live transcription');

    try {
      final stream = SarvamStreamingService.startTranscription(authToken);
      
      await for (final transcriptChunk in stream) {
        // Process and format the chunk
        final formattedChunk = TranscriptDisplayFormatter.formatForDisplay(transcriptChunk);
        yield formattedChunk;
      }
    } catch (e) {
      print('Live transcription error: $e');
      rethrow;
    }
  }

  static Future<void> stopLiveTranscription() async {
    print('Stopping live transcription');
    await SarvamStreamingService.stopTranscription();
  }

  static Future<String> _performTranscription(String audioFilePath) async {
    // This would integrate with Sarvam's file transcription API
    // For now, return a mock implementation
    await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
    
    return 'Mock transcription for audio file: $audioFilePath';
  }

  static Future<Map<String, dynamic>> getTranscriptionMetadata(String audioFilePath) async {
    try {
      final file = File(audioFilePath);
      final stat = await file.stat();
      
      return {
        'filePath': audioFilePath,
        'fileSize': stat.size,
        'lastModified': stat.modified.toIso8601String(),
        'estimatedDuration': _estimateAudioDuration(stat.size),
        'format': _getAudioFormat(audioFilePath),
      };
    } catch (e) {
      print('Error getting transcription metadata: $e');
      return {
        'filePath': audioFilePath,
        'error': e.toString(),
      };
    }
  }

  static Duration _estimateAudioDuration(int fileSize) {
    // Rough estimate: 16-bit PCM, 16kHz, mono
    // 1 second = 16,000 samples * 2 bytes = 32,000 bytes
    final bytesPerSecond = 32000;
    final estimatedSeconds = fileSize / bytesPerSecond;
    return Duration(seconds: estimatedSeconds.round());
  }

  static String _getAudioFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'wav':
        return 'WAV';
      case 'mp3':
        return 'MP3';
      case 'm4a':
        return 'M4A';
      default:
        return 'Unknown';
    }
  }

  static bool validateAudioFile(String audioFilePath) {
    if (audioFilePath.isEmpty) return false;
    
    final file = File(audioFilePath);
    if (!file.existsSync()) return false;
    
    final extension = audioFilePath.toLowerCase().split('.').last;
    return ['wav', 'mp3', 'm4a'].contains(extension);
  }

  static Future<List<String>> getSupportedFormats() async {
    return ['WAV', 'MP3', 'M4A'];
  }

  static Map<String, dynamic> getTranscriptionStats() {
    return {
      'service': 'Sarvam AI',
      'version': '1.0',
      'supportedLanguages': ['en', 'hi', 'bn', 'gu', 'mr', 'ta', 'te'],
      'features': [
        'real_time_streaming',
        'punctuation',
        'timestamps',
        'confidence_scores',
        'speaker_diarization',
      ],
      'maxDuration': '2 hours',
      'maxFileSize': '100MB',
    };
  }
}
