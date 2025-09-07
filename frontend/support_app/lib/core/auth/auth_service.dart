import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

@LazySingleton()
class AuthService {
  final SharedPreferences _prefs;
  final Dio _dio;

  AuthService(this._prefs, this._dio);

  // Token management
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString('access_token', accessToken);
    await _prefs.setString('refresh_token', refreshToken);
    await _prefs.setInt(
        'token_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearTokens() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
    await _prefs.remove('token_timestamp');
  }

  String? get accessToken => _prefs.getString('access_token');
  String? get refreshToken => _prefs.getString('refresh_token');

  bool get isLoggedIn => accessToken != null && !isTokenExpired;

  bool get isTokenExpired {
    final token = accessToken;
    if (token == null) return true;

    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  bool get isTokenExpiringSoon {
    final token = accessToken;
    if (token == null) return true;

    try {
      final expirationDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final timeUntilExpiry = expirationDate.difference(now);

      // Consider token expiring if it expires within 5 minutes
      return timeUntilExpiry.inMinutes < 5;
    } catch (e) {
      return true;
    }
  }

  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = this.refreshToken;
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

        await storeTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? refreshToken,
        );

        return newAccessToken;
      }
    } catch (e) {
      // Token refresh failed - could log to analytics service
    }
    return null;
  }

  Future<bool> validateToken() async {
    try {
      final token = accessToken;
      if (token == null) return false;

      final response = await _dio.get(
        '/auth/verify-token',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // User info from token
  Map<String, dynamic>? get tokenPayload {
    final token = accessToken;
    if (token == null) return null;

    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  String? get userId => tokenPayload?['sub'];
  String? get userEmail => tokenPayload?['email'];
  String? get userRole => tokenPayload?['role'];
}
