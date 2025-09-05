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
  static const Duration _cacheValidity = Duration(minutes: 5);

  ChatRepositoryImpl(this._dio, this._sharedPreferences);

  /// Validate that we have a valid token
  String _validateToken() {
    print('🔍 Chat - _validateToken called');
    final token = _sharedPreferences.getString('token');
    print(
        '🔍 Chat - Raw token from SharedPreferences: ${token?.substring(0, (token?.length ?? 0) > 20 ? 20 : (token?.length ?? 0)) ?? 'NULL'}...');
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

  @override
  Future<List<ChatSession>> getUserSessions() async {
    try {
      // Wait a bit to ensure token is stored after login
      await Future.delayed(const Duration(milliseconds: 100));

      final token = _validateToken();
      print(
          '🔍 Chat API - Retrieved token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('🔍 Chat API - Token length: ${token.length}');

      final response = await _dio.get(
        '/chat/sessions/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
      final token = _sharedPreferences.getString('token');
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
      final token = _sharedPreferences.getString('token');
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
      final token = _sharedPreferences.getString('token');
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
      final token = _sharedPreferences.getString('token');
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
  bool _isCacheValid(int sessionId) {
    if (!_messageCache.containsKey(sessionId)) return false;

    final timestamp = _cacheTimestamps[sessionId];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheValidity;
  }

  void _updateCache(int sessionId, List<ChatMessage> messages) {
    _messageCache[sessionId] = messages;
    _cacheTimestamps[sessionId] = DateTime.now();
    print(
        'Cache updated for session $sessionId with ${messages.length} messages');
  }

  void _addMessageToCache(
      int sessionId, String userMessage, AIChatResponse aiResponse) {
    if (!_messageCache.containsKey(sessionId)) {
      _messageCache[sessionId] = [];
    }

    // Add user message
    final userMsg = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch,
      sessionId: sessionId,
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now(),
    );

    // Add AI response
    final aiMsg = ChatMessage(
      messageId: aiResponse.messageId,
      sessionId: sessionId,
      role: 'assistant',
      content: aiResponse.response,
      timestamp: DateTime.now(),
      metadata: {
        'ai_response': true,
        'confidence': aiResponse.confidence,
        'model': aiResponse.model,
        'usage': aiResponse.usage,
      },
    );

    _messageCache[sessionId]!.addAll([userMsg, aiMsg]);
    _cacheTimestamps[sessionId] = DateTime.now();

    print('Cache updated for session $sessionId with new messages');
  }

  void _removeFromCache(int sessionId) {
    _messageCache.remove(sessionId);
    _cacheTimestamps.remove(sessionId);
    print('Cache cleared for session $sessionId');
  }

  // Public method to clear all cache (useful for logout)
  void clearCache() {
    _messageCache.clear();
    _cacheTimestamps.clear();
    print('All chat cache cleared');
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
