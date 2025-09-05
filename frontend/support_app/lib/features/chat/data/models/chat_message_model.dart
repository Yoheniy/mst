class ChatMessageModel {
  final int? messageId;
  final int sessionId;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessageModel({
    this.messageId,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['message_id'],
      sessionId: json['session_id'],
      role: json['role'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['message_metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'session_id': sessionId,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'message_metadata': metadata,
    };
  }
}

class ChatSessionModel {
  final int? sessionId;
  final int userId;
  final int? machineId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<ChatMessageModel> messages;

  ChatSessionModel({
    this.sessionId,
    required this.userId,
    this.machineId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.messages = const [],
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      sessionId: json['session_id'],
      userId: json['user_id'],
      machineId: json['machine_id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'],
      messages: (json['messages'] as List<dynamic>?)
          ?.map((msg) => ChatMessageModel.fromJson(msg))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'machine_id': machineId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'messages': messages.map((msg) => msg.toJson()).toList(),
    };
  }
}

class AIChatRequestModel {
  final String message;
  final int? sessionId;
  final String? context;

  AIChatRequestModel({
    required this.message,
    this.sessionId,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'session_id': sessionId,
      'context': context,
    };
  }
}

class AIChatResponseModel {
  final String response;
  final int sessionId;
  final int messageId;
  final double confidence;
  final Map<String, dynamic> usage;
  final String model;

  AIChatResponseModel({
    required this.response,
    required this.sessionId,
    required this.messageId,
    required this.confidence,
    required this.usage,
    required this.model,
  });

  factory AIChatResponseModel.fromJson(Map<String, dynamic> json) {
    return AIChatResponseModel(
      response: json['response'],
      sessionId: json['session_id'],
      messageId: json['message_id'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
      usage: json['usage'] ?? {},
      model: json['model'] ?? 'unknown',
    );
  }
}
