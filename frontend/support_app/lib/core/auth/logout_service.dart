import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:support_app/features/chat/domain/repositories/chat_repository.dart';

@LazySingleton()
class LogoutService {
  final SharedPreferences _prefs;
  final ChatRepository _chatRepository;

  LogoutService(this._prefs, this._chatRepository);

  /// Perform complete logout with timeout protection
  Future<void> performLogout() async {
    try {
      // Get token before clearing it for API call
      final token = _prefs.getString('access_token');

      // Clear all authentication data immediately (most important)
      await _clearAllAuthData();

      // Optional: Call logout API with timeout (non-blocking)
      if (token != null) {
        _callLogoutAPI(token).catchError((e) {
          // Ignore logout API errors - local logout is more important
        });
      }
    } catch (e) {
      // Even if logout fails, we still clear local data
      await _clearAllAuthData();
    }
  }

  /// Clear all authentication-related data
  Future<void> _clearAllAuthData() async {
    try {
      // Clear chat cache first
      _chatRepository.clearCache();

      // Clear all token-related data
      await _prefs.remove('access_token');
      await _prefs.remove('refresh_token');
      await _prefs.remove('token'); // Legacy key
      await _prefs.remove('token_timestamp');

      // Clear user data
      await _prefs.remove('user_email');
      await _prefs.remove('user_name');

      // Don't clear ALL preferences, just auth-related ones
      // await _prefs.clear(); // This was clearing everything!
    } catch (e) {
      // Even if clearing fails, continue with logout
    }
  }

  /// Call logout API with short timeout
  Future<void> _callLogoutAPI(String token) async {
    try {
      // Create a new Dio instance with short timeout for logout
      final logoutDio = Dio();
      logoutDio.options.connectTimeout = const Duration(seconds: 3);
      logoutDio.options.receiveTimeout = const Duration(seconds: 3);

      // Try to call logout API with timeout
      await logoutDio
          .post(
            '/auth/logout',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
              validateStatus: (status) => status != null && status < 500,
            ),
          )
          .timeout(const Duration(seconds: 2));

      logoutDio.close();
    } catch (e) {
      // Ignore logout API errors - local logout is more important
    }
  }
}
