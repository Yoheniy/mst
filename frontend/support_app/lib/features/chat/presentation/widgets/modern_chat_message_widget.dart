import 'package:flutter/material.dart';
import '../../domain/entities/chat_entities.dart';

class ModernChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final bool showAvatar;
  final VoidCallback? onTap;

  const ModernChatMessageWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.showAvatar = true,
    this.onTap,
  });

  @override
  State<ModernChatMessageWidget> createState() =>
      _ModernChatMessageWidgetState();
}

class _ModernChatMessageWidgetState extends State<ModernChatMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: widget.isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.isCurrentUser && widget.showAvatar) ...[
                _buildAvatar(colorScheme),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: _buildMessageBubble(theme, colorScheme),
              ),
              if (widget.isCurrentUser && widget.showAvatar) ...[
                const SizedBox(width: 8),
                _buildAvatar(colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            widget.isCurrentUser ? colorScheme.primary : colorScheme.secondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        widget.isCurrentUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildMessageBubble(ThemeData theme, ColorScheme colorScheme) {
    final isSystemMessage = widget.message.role == 'system';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: widget.isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getMessageColor(colorScheme, isSystemMessage),
                borderRadius: _getBorderRadius(),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSystemMessage) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'System',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    widget.message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _getTextColor(colorScheme, isSystemMessage),
                      height: 1.4,
                    ),
                  ),
                  if (!widget.isCurrentUser &&
                      widget.message.metadata != null) ...[
                    const SizedBox(height: 8),
                    _buildMetadata(theme, colorScheme),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            _buildTimestamp(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Color _getMessageColor(ColorScheme colorScheme, bool isSystemMessage) {
    if (isSystemMessage) {
      return colorScheme.primaryContainer.withValues(alpha: 0.3);
    }

    if (widget.isCurrentUser) {
      return colorScheme.primary;
    } else {
      return colorScheme.surfaceContainerHighest;
    }
  }

  Color _getTextColor(ColorScheme colorScheme, bool isSystemMessage) {
    if (isSystemMessage) {
      return colorScheme.onPrimaryContainer;
    }

    if (widget.isCurrentUser) {
      return colorScheme.onPrimary;
    } else {
      return colorScheme.onSurface;
    }
  }

  BorderRadius _getBorderRadius() {
    if (widget.isCurrentUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(4),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(20),
      );
    }
  }

  Widget _buildMetadata(ThemeData theme, ColorScheme colorScheme) {
    final metadata = widget.message.metadata;
    if (metadata == null) return const SizedBox.shrink();

    final isAIResponse = metadata['ai_response'] == true;
    final confidence = metadata['confidence'] as double?;
    final model = metadata['model'] as String?;

    if (!isAIResponse) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.psychology,
            size: 12,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          if (model != null) ...[
            Text(
              model,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (confidence != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getConfidenceColor(confidence).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(confidence * 100).toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getConfidenceColor(confidence),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildTimestamp(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        _formatTime(widget.message.timestamp),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
