class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000';
  static const String wsUrl = 'ws://localhost:3000';
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