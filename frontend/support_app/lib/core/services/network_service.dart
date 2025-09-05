import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/production_config.dart';
import 'simple_error_handler.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  late final Dio _dio;
  final ProductionConfig _config = productionConfig;
  final SimpleErrorHandler _errorHandler = errorHandler;

  // Request tracking
  final Map<String, int> _requestCounts = {};
  final Map<String, List<Duration>> _responseTimes = {};
  final Map<String, int> _errorCounts = {};

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: _config.apiUrl,
      connectTimeout: Duration(seconds: _config.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: _config.apiTimeoutSeconds),
      sendTimeout: Duration(seconds: _config.apiTimeoutSeconds),
    ));

    // Add interceptors
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createRetryInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
    _dio.interceptors.add(_createPerformanceInterceptor());
  }

  Dio get dio => _dio;

  // Create logging interceptor
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_config.enableRequestLogging) {
          _logRequest(options);
        }
        _trackRequest(options.path);
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (_config.enableRequestLogging) {
          _logResponse(response);
        }
        _trackResponse(response.requestOptions.path, response);
        handler.next(response);
      },
      onError: (error, handler) {
        if (_config.enableRequestLogging) {
          _logError(error);
        }
        _trackError(error.requestOptions.path);
        handler.next(error);
      },
    );
  }

  // Create retry interceptor
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          final retryCount = error.requestOptions.extra['retryCount'] ?? 0;

          if (retryCount < _config.maxRetries) {
            error.requestOptions.extra['retryCount'] = retryCount + 1;

            if (kDebugMode) {
              print(
                  'Retrying request (${retryCount + 1}/${_config.maxRetries}): ${error.requestOptions.path}');
            }

            // Exponential backoff
            final delay = Duration(milliseconds: (100 * (2 ^ retryCount)));
            await Future.delayed(delay);

            try {
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (retryError) {
              // Continue to next interceptor if retry fails
            }
          }
        }
        handler.next(error);
      },
    );
  }

  // Create error interceptor
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
  if (error.response?.statusCode == 401) {
    // Token expired or invalid
    _handleAuthError();
  }
  _handleNetworkError(error);
  handler.next(error);
},
    );
  }

  void _handleAuthError() async {
    // Clear invalid token and navigate to login
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('token');
    
    // You might want to use a global navigator key or event bus
    // to notify the app to navigate to login
    print('🔐 Authentication failed, redirecting to login');
  }

  // Create performance interceptor
  Interceptor _createPerformanceInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['startTime'] = DateTime.now();
        handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime =
            response.requestOptions.extra['startTime'] as DateTime?;
        if (startTime != null) {
          final duration = DateTime.now().difference(startTime);
          _recordResponseTime(response.requestOptions.path, duration);
        }
        handler.next(response);
      },
    );
  }

  // Check if request should be retried
  bool _shouldRetry(DioException error) {
    // Retry on network errors and 5xx server errors
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  // Handle network errors
  void _handleNetworkError(DioException error) {
    String errorType = 'unknown';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorType = 'connection_timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorType = 'receive_timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorType = 'send_timeout';
        break;
      case DioExceptionType.connectionError:
        errorType = 'connection_error';
        break;
      case DioExceptionType.badResponse:
        errorType = 'bad_response_${error.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        errorType = 'request_cancelled';
        break;
      default:
        errorType = 'unknown_error';
    }

    _errorHandler.handleError('network_$errorType', error.toString());
  }

  // Track request
  void _trackRequest(String path) {
    _requestCounts[path] = (_requestCounts[path] ?? 0) + 1;
  }

  // Track response
  void _trackResponse(String path, Response response) {
    // Response tracking is handled by performance interceptor
  }

  // Track error
  void _trackError(String path) {
    _errorCounts[path] = (_errorCounts[path] ?? 0) + 1;
  }

  // Record response time
  void _recordResponseTime(String path, Duration duration) {
    if (!_responseTimes.containsKey(path)) {
      _responseTimes[path] = [];
    }
    _responseTimes[path]!.add(duration);

    // Keep only last 50 response times per endpoint
    if (_responseTimes[path]!.length > 50) {
      _responseTimes[path]!.removeAt(0);
    }
  }

  // Log request
  void _logRequest(RequestOptions options) {
    if (kDebugMode) {
      print('🌐 REQUEST: ${options.method} ${options.path}');
      if (options.data != null) {
        print('📦 Data: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        print('🔍 Query: ${options.queryParameters}');
      }
    }
  }

  // Log response
  void _logResponse(Response response) {
    if (kDebugMode) {
      print(
          '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
      print(
          '⏱️  Time: ${response.requestOptions.extra['startTime'] != null ? DateTime.now().difference(response.requestOptions.extra['startTime']).inMilliseconds : 'N/A'}ms');
    }
  }

  // Log error
  void _logError(DioException error) {
    if (kDebugMode) {
      print('❌ ERROR: ${error.type} ${error.requestOptions.path}');
      if (error.response != null) {
        print('📊 Status: ${error.response!.statusCode}');
        print('📝 Message: ${error.response!.data}');
      }
      print('💬 Error: ${error.message}');
    }
  }

  // Get network statistics
  Map<String, dynamic> getNetworkStats() {
    final stats = <String, dynamic>{};

    for (final entry in _requestCounts.entries) {
      final path = entry.key;
      final requestCount = entry.value;
      final errorCount = _errorCounts[path] ?? 0;
      final responseTimes = _responseTimes[path] ?? [];

      stats[path] = {
        'total_requests': requestCount,
        'error_count': errorCount,
        'success_rate': requestCount > 0
            ? ((requestCount - errorCount) / requestCount) * 100
            : 0.0,
        'average_response_time_ms': responseTimes.isNotEmpty
            ? responseTimes.fold(
                    0.0, (sum, duration) => sum + duration.inMilliseconds) /
                responseTimes.length
            : 0.0,
        'min_response_time_ms': responseTimes.isNotEmpty
            ? responseTimes
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a < b ? a : b)
            : 0,
        'max_response_time_ms': responseTimes.isNotEmpty
            ? responseTimes
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a > b ? a : b)
            : 0,
      };
    }

    return stats;
  }

  // Check network health
  bool isNetworkHealthy() {
    final stats = getNetworkStats();

    for (final endpointStats in stats.values) {
      final successRate = endpointStats['success_rate'] as double;
      final avgResponseTime =
          endpointStats['average_response_time_ms'] as double;

      // Consider unhealthy if success rate < 90% or avg response time > 2000ms
      if (successRate < 90.0 || avgResponseTime > 2000.0) {
        return false;
      }
    }

    return true;
  }

  // Clear network statistics
  void clearNetworkStats() {
    _requestCounts.clear();
    _responseTimes.clear();
    _errorCounts.clear();
  }

  // Test network connectivity
  Future<bool> testConnectivity() async {
    try {
      final response = await _dio.get('/health',
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get current configuration
  Map<String, dynamic> getCurrentConfig() {
    return {
      'base_url': _config.apiUrl,
      'timeout_seconds': _config.apiTimeoutSeconds,
      'max_retries': _config.maxRetries,
      'enable_logging': _config.enableRequestLogging,
      'request_count':
          _requestCounts.values.fold(0, (sum, count) => sum + count),
      'error_count': _errorCounts.values.fold(0, (sum, count) => sum + count),
    };
  }
}

// Global instance
final networkService = NetworkService();
