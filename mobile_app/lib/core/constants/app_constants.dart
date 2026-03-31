import 'package:flutter/foundation.dart';

class AppConstants {
  // API Configuration
  static String get apiBaseUrl {
    if (kIsWeb) {
      return const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3001',
      );
    }
    // Android emulator uses 10.0.2.2 to reach host machine
    return 'http://10.0.2.2:3001';
  }
  
  static String get wsUrl {
    if (kIsWeb) {
      return const String.fromEnvironment(
        'WS_BASE_URL',
        defaultValue: 'ws://localhost:3001',
      );
    }
    // Android emulator uses 10.0.2.2 to reach host machine
    return 'ws://10.0.2.2:3001';
  }
  
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userProfileKey = 'user_profile';
  
  // Audio Configuration
  static const int sampleRate = 16000;
  static const int channelCount = 1;
  static const Duration maxRecordingDuration = Duration(hours: 2);
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // App Configuration
  static const String appName = 'Ambient AI Scribe';
  static const String appVersion = '1.0.0';
}