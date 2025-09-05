import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/production_config.dart';

class BasicNetworkService {
  static final BasicNetworkService _instance = BasicNetworkService._internal();
  factory BasicNetworkService() => _instance;
  BasicNetworkService._internal();

  late final Dio _dio;
  final ProductionConfig _config = productionConfig;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: _config.apiUrl,
      connectTimeout: Duration(seconds: _config.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: _config.apiTimeoutSeconds),
    ));

    // Add basic interceptors
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createRetryInterceptor());
  }

  Dio get dio => _dio;

  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_config.enableRequestLogging) {
          print('🌐 REQUEST: ${options.method} ${options.path}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (_config.enableRequestLogging) {
          print(
              '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (_config.enableRequestLogging) {
          print('❌ ERROR: ${error.type} ${error.requestOptions.path}');
        }
        handler.next(error);
      },
    );
  }

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

            // Simple delay
            await Future.delayed(
                Duration(milliseconds: (500 * (retryCount + 1)).toInt()));

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

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

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
}

final basicNetworkService = BasicNetworkService();
