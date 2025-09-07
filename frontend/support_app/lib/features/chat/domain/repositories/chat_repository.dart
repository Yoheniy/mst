import '../entities/chat_entities.dart';

abstract class ChatRepository {
  Future<List<ChatSession>> getUserSessions();
  Future<ChatSession> createChatSession(String title, {int? machineId});
  Future<List<ChatMessage>> getSessionMessages(int sessionId);
  Future<AIChatResponse> sendMessage(
    String message, {
    int? sessionId,
    String? context,
    String? machineType,
    String? chunkTypeFilter,
  });
  Future<void> deleteSession(int sessionId);
  void clearCache();
}
