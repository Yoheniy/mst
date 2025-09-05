class ChatMessage {
  final int? messageId;
  final int sessionId;
  final String role;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    this.messageId,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });
}

class ChatSession {
  final int? sessionId;
  final int userId;
  final int? machineId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<ChatMessage> messages;

  ChatSession({
    this.sessionId,
    required this.userId,
    this.machineId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.messages = const [],
  });
}

class AIChatResponse {
  final String response;
  final int sessionId;
  final int messageId;
  final double confidence;
  final Map<String, dynamic> usage;
  final String model;

  AIChatResponse({
    required this.response,
    required this.sessionId,
    required this.messageId,
    required this.confidence,
    required this.usage,
    required this.model,
  });
}
