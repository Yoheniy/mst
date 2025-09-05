import 'package:flutter/foundation.dart';

class ProductionConfig {
  static final ProductionConfig _instance = ProductionConfig._internal();
  factory ProductionConfig() => _instance;
  ProductionConfig._internal();

  // Environment configuration
  static const String _devApiUrl = 'http://localhost:8000';
  static const String _prodApiUrl =
      'https://machine-tool-support-app.onrender.com';

  // Feature flags
  bool _enableAdvancedRAG = true;
  bool _enablePerformanceMonitoring = true;
  bool _enableErrorReporting = true;
  bool _enableAnalytics = false;

  // API configuration
  int _apiTimeoutSeconds = 30;
  int _maxRetries = 3;
  bool _enableRequestLogging = kDebugMode;

  // Cache configuration
  int _maxCacheSize = 100;
  int _cacheExpiryMinutes = 10;

  // UI configuration
  bool _enableAnimations = true;
  bool _enableDebugBanner = kDebugMode;
  bool _enablePerformanceOverlay = false;

  // Getters
  String get apiUrl => kDebugMode ? _devApiUrl : _prodApiUrl;
  bool get enableAdvancedRAG => _enableAdvancedRAG;
  bool get enablePerformanceMonitoring => _enablePerformanceMonitoring;
  bool get enableErrorReporting => _enableErrorReporting;
  bool get enableAnalytics => _enableAnalytics;
  int get apiTimeoutSeconds => _apiTimeoutSeconds;
  int get maxRetries => _maxRetries;
  bool get enableRequestLogging => _enableRequestLogging;
  int get maxCacheSize => _maxCacheSize;
  int get cacheExpiryMinutes => _cacheExpiryMinutes;
  bool get enableAnimations => _enableAnimations;
  bool get enableDebugBanner => _enableDebugBanner;
  bool get enablePerformanceOverlay => _enablePerformanceOverlay;

  // Configuration methods
  void setEnvironment(bool isProduction) {
    if (isProduction) {
      _enableDebugBanner = false;
      _enableRequestLogging = false;
      _enablePerformanceOverlay = false;
      _enableAnalytics = true;
    } else {
      _enableDebugBanner = true;
      _enableRequestLogging = true;
      _enablePerformanceOverlay = false;
      _enableAnalytics = false;
    }
  }

  void setFeatureFlags({
    bool? advancedRAG,
    bool? performanceMonitoring,
    bool? errorReporting,
    bool? analytics,
  }) {
    if (advancedRAG != null) _enableAdvancedRAG = advancedRAG;
    if (performanceMonitoring != null)
      _enablePerformanceMonitoring = performanceMonitoring;
    if (errorReporting != null) _enableErrorReporting = errorReporting;
    if (analytics != null) _enableAnalytics = analytics;
  }

  void setAPIConfig({
    int? timeoutSeconds,
    int? maxRetries,
    bool? enableLogging,
  }) {
    if (timeoutSeconds != null) _apiTimeoutSeconds = timeoutSeconds;
    if (maxRetries != null) _maxRetries = maxRetries;
    if (enableLogging != null) _enableRequestLogging = enableLogging;
  }

  void setCacheConfig({
    int? maxSize,
    int? expiryMinutes,
  }) {
    if (maxSize != null) _maxCacheSize = maxSize;
    if (expiryMinutes != null) _cacheExpiryMinutes = expiryMinutes;
  }

  void setUIConfig({
    bool? enableAnimations,
    bool? enableDebugBanner,
    bool? enablePerformanceOverlay,
  }) {
    if (enableAnimations != null) _enableAnimations = enableAnimations;
    if (enableDebugBanner != null) _enableDebugBanner = enableDebugBanner;
    if (enablePerformanceOverlay != null)
      _enablePerformanceOverlay = enablePerformanceOverlay;
  }

  // Get current configuration
  Map<String, dynamic> getCurrentConfig() {
    return {
      'environment': kDebugMode ? 'development' : 'production',
      'api_url': apiUrl,
      'features': {
        'advanced_rag': _enableAdvancedRAG,
        'performance_monitoring': _enablePerformanceMonitoring,
        'error_reporting': _enableErrorReporting,
        'analytics': _enableAnalytics,
      },
      'api_config': {
        'timeout_seconds': _apiTimeoutSeconds,
        'max_retries': _maxRetries,
        'enable_logging': _enableRequestLogging,
      },
      'cache_config': {
        'max_size': _maxCacheSize,
        'expiry_minutes': _cacheExpiryMinutes,
      },
      'ui_config': {
        'enable_animations': _enableAnimations,
        'enable_debug_banner': _enableDebugBanner,
        'enable_performance_overlay': _enablePerformanceOverlay,
      },
    };
  }

  // Validate configuration
  bool isConfigurationValid() {
    try {
      // Check API timeout
      if (_apiTimeoutSeconds < 5 || _apiTimeoutSeconds > 120) return false;

      // Check retry count
      if (_maxRetries < 0 || _maxRetries > 10) return false;

      // Check cache size
      if (_maxCacheSize < 10 || _maxCacheSize > 1000) return false;

      // Check cache expiry
      if (_cacheExpiryMinutes < 1 || _cacheExpiryMinutes > 60) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  // Reset to default configuration
  void resetToDefaults() {
    _enableAdvancedRAG = true;
    _enablePerformanceMonitoring = true;
    _enableErrorReporting = true;
    _enableAnalytics = false;
    _apiTimeoutSeconds = 30;
    _maxRetries = 3;
    _enableRequestLogging = kDebugMode;
    _maxCacheSize = 100;
    _cacheExpiryMinutes = 10;
    _enableAnimations = true;
    _enableDebugBanner = kDebugMode;
    _enablePerformanceOverlay = false;
  }

  // Get configuration summary for production
  String getProductionSummary() {
    final config = getCurrentConfig();
    return '''
Production Configuration Summary:
- Environment: ${config['environment']}
- API URL: ${config['api_url']}
- Advanced RAG: ${config['features']['advanced_rag']}
- Performance Monitoring: ${config['features']['performance_monitoring']}
- Error Reporting: ${config['features']['error_reporting']}
- Analytics: ${config['features']['analytics']}
- API Timeout: ${config['api_config']['timeout_seconds']}s
- Max Retries: ${config['api_config']['max_retries']}
- Cache Size: ${config['cache_config']['max_size']}
- Cache Expiry: ${config['cache_config']['expiry_minutes']}m
- Valid Configuration: ${isConfigurationValid()}
''';
  }
}

// Global instance
final productionConfig = ProductionConfig();
