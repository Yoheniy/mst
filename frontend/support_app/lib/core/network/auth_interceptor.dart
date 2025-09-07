import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SharedPreferences _prefs;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor(this._dio, this._prefs);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = _prefs.getString('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final newToken = await _refreshToken();
          if (newToken != null) {
            // Retry the original request with new token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            // Retry the request
            final response = await _dio.fetch(options);
            handler.resolve(response);
            return;
          }
        } catch (e) {
          // Refresh failed, clear tokens and redirect to login
          await _clearTokens();
          _redirectToLogin();
        } finally {
          _isRefreshing = false;
        }
      } else {
        // Already refreshing, queue the request
        _pendingRequests.add(err.requestOptions);
        return;
      }
    }

    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = _prefs.getString('refresh_token');
      if (refreshToken == null) return null;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        await _prefs.setString('access_token', newAccessToken);
        if (newRefreshToken != null) {
          await _prefs.setString('refresh_token', newRefreshToken);
        }

        // Process pending requests
        _processPendingRequests(newAccessToken);

        return newAccessToken;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    return null;
  }

  void _processPendingRequests(String newToken) {
    for (final options in _pendingRequests) {
      options.headers['Authorization'] = 'Bearer $newToken';
      _dio.fetch(options).catchError((e) {
        print('Failed to retry pending request: $e');
      });
    }
    _pendingRequests.clear();
  }

  Future<void> _clearTokens() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
    await _prefs.remove('token_timestamp');
  }

  void _redirectToLogin() {
    // This would typically use a navigation service or state management
    // to redirect to login screen
    print('Redirecting to login...');
  }
}
