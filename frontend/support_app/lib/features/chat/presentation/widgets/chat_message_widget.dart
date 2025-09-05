import 'package:flutter/material.dart';
import '../../domain/entities/chat_entities.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),

            // Show RAG metadata for AI responses
            if (!isCurrentUser && message.metadata != null)
              _buildRAGMetadata(context),

            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: isCurrentUser
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRAGMetadata(BuildContext context) {
    final metadata = message.metadata;
    if (metadata == null) return const SizedBox.shrink();

    // Check if this is an AI response with RAG data
    final isAIResponse = metadata['ai_response'] == true;
    final ragParams = metadata['rag_parameters'] as Map<String, dynamic>?;

    if (!isAIResponse || ragParams == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue[700], size: 16),
              const SizedBox(width: 4),
              Text(
                'AI Response with RAG',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (ragParams['machine_type'] != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.build, color: Colors.blue[600], size: 14),
                const SizedBox(width: 4),
                Text(
                  'Machine: ${ragParams['machine_type']}',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
          if (ragParams['chunk_type_filter'] != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.category, color: Colors.blue[600], size: 14),
                const SizedBox(width: 4),
                Text(
                  'Content: ${ragParams['chunk_type_filter']}',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
          if (metadata['confidence'] != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue[600], size: 14),
                const SizedBox(width: 4),
                Text(
                  'Confidence: ${(metadata['confidence'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
