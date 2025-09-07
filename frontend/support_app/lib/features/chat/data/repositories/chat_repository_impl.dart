import 'package:dio/dio.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/chat_entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio _dio;
  final SharedPreferences _sharedPreferences;

  // Cache for messages to improve performance
  final Map<int, List<ChatMessage>> _messageCache = {};
  final Map<int, DateTime> _cacheTimestamps = {};

  ChatRepositoryImpl(this._dio, this._sharedPreferences);

  /// Validate that we have a valid token
  String _validateToken() {
    print('🔍 Chat - _validateToken called');
    final token = _sharedPreferences.getString('access_token');
    print(
        '🔍 Chat - Raw token from SharedPreferences: ${token?.substring(0, (token.length > 20 ? 20 : token.length)) ?? 'NULL'}...');
    print('🔍 Chat - Token is null: ${token == null}');
    print('🔍 Chat - Token is empty: ${token?.isEmpty ?? true}');
    print('🔍 Chat - Token is dummy: ${token == 'dummy_token'}');
    print('🔍 Chat - Token length: ${token?.length ?? 0}');

    if (token == null || token.isEmpty || token == 'dummy_token') {
      throw Exception(
          'No valid authentication token found. Please login again.');
    }
    return token;
  }

  /// Handle token expiration and provide better error messages
  Future<String> _getValidToken() async {
    try {
      final token = _validateToken();

      // Check if token might be expired by looking at the timestamp
      final tokenTimestamp = _sharedPreferences.getInt('token_timestamp');
      if (tokenTimestamp != null) {
        final tokenAge = DateTime.now().millisecondsSinceEpoch - tokenTimestamp;
        final tokenAgeMinutes = tokenAge / (1000 * 60);

        print('🔍 Token age: ${tokenAgeMinutes.toStringAsFixed(1)} minutes');

        // If token is older than 25 minutes (5 minutes before 30-minute expiry),
        // it's likely expired
        if (tokenAgeMinutes > 25) {
          print('⚠️ Token is likely expired (older than 25 minutes)');
          await _clearExpiredTokens();
          throw Exception('Session expired. Please login again.');
        }
      }

      return token;
    } catch (e) {
      print('❌ Token validation error: $e');
      throw Exception('Authentication failed. Please login again.');
    }
  }

  /// Clear expired tokens
  Future<void> _clearExpiredTokens() async {
    await _sharedPreferences.remove('access_token');
    await _sharedPreferences.remove('token_timestamp');
    print('🧹 Cleared expired tokens');
  }

  @override
  Future<List<ChatSession>> getUserSessions() async {
    try {
      // Wait a bit to ensure token is stored after login
      await Future.delayed(const Duration(milliseconds: 100));

      final token = await _getValidToken();
      print(
          '🔍 Chat API - Retrieved token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('🔍 Chat API - Token length: ${token.length}');

      final response = await _dio.get(
        '/chat/sessions/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final List<dynamic> sessionsJson = response.data;
      return sessionsJson.map((json) => _mapToChatSession(json)).toList();
    } catch (e) {
      print('❌ Chat API Error: $e');
      throw Exception('Failed to get chat sessions: $e');
    }
  }

  @override
  Future<ChatSession> createChatSession(String title, {int? machineId}) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.post(
        '/chat/sessions/',
        data: {
          'title': title,
          if (machineId != null) 'machine_id': machineId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _mapToChatSession(response.data);
    } catch (e) {
      throw Exception('Failed to create chat session: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getSessionMessages(int sessionId) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.get(
        '/chat/sessions/$sessionId/messages/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> messagesJson = response.data;
      return messagesJson.map((json) => _mapToChatMessage(json)).toList();
    } catch (e) {
      throw Exception('Failed to get session messages: $e');
    }
  }

  @override
  Future<AIChatResponse> sendMessage(
    String message, {
    int? sessionId,
    String? context,
    String? machineType,
    String? chunkTypeFilter,
  }) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.post(
        '/chat/ai/chat',
        data: {
          'message': message,
          if (sessionId != null) 'session_id': sessionId,
          if (context != null) 'context': context,
          if (machineType != null) 'machine_type': machineType,
          if (chunkTypeFilter != null) 'chunk_type_filter': chunkTypeFilter,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _mapToAIChatResponse(response.data);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    try {
      final token = await _getValidToken();
      await _dio.delete(
        '/chat/sessions/$sessionId/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  ChatSession _mapToChatSession(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['session_id'],
      userId: json['user_id'],
      machineId: json['machine_id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((msg) => _mapToChatMessage(msg))
              .toList() ??
          [],
    );
  }

  ChatMessage _mapToChatMessage(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['message_id'],
      sessionId: json['session_id'],
      role: json['role'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['message_metadata'],
    );
  }

  AIChatResponse _mapToAIChatResponse(Map<String, dynamic> json) {
    return AIChatResponse(
      response: json['response'],
      sessionId: json['session_id'],
      messageId: json['message_id'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
      usage: json['usage'] ?? {},
      model: json['model'] ?? 'unknown',
    );
  }

  // Cache management methods

  // Public method to clear all cache (useful for logout)
  @override
  void clearCache() {
    _messageCache.clear();
    _cacheTimestamps.clear();
    print('All chat cache cleared');
  }

  // Clear all authentication data and cache
  Future<void> clearAllData() async {
    try {
      // Clear cache
      clearCache();

      // Clear all stored tokens and user data
      await _sharedPreferences.remove('access_token');
      await _sharedPreferences.remove('refresh_token');
      await _sharedPreferences.remove('token');
      await _sharedPreferences.remove('token_timestamp');
      await _sharedPreferences.remove('user_email');
      await _sharedPreferences.remove('user_name');

      print('All authentication data cleared');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // Public method to get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cached_sessions': _messageCache.length,
      'total_cached_messages': _messageCache.values
          .fold(0, (sum, messages) => sum + messages.length),
      'cache_timestamps': _cacheTimestamps.map(
          (key, value) => MapEntry(key.toString(), value.toIso8601String())),
    };
  }
}
