import 'package:injectable/injectable.dart';

@LazySingleton()
class AppConfig {
  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Token Configuration
  static const int tokenRefreshThresholdMinutes = 5;
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Error Handling
  static const bool enableErrorLogging = true;
  static const bool enableNetworkLogging = true;

  // Security
  static const bool enableCertificatePinning = false;
  static const bool enableBiometricAuth = false;

  // Performance
  static const int maxCacheSize = 100;
  static const Duration cacheExpiration = Duration(hours: 1);

  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  bool get isProduction => environment == 'production';
  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';
}
