import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernMessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttachFile;
  final VoidCallback? onVoiceMessage;
  final bool isRecording;
  final bool isLoading;
  final String? placeholder;
  final List<String> attachedFiles;
  final VoidCallback? onRemoveFile;

  const ModernMessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttachFile,
    this.onVoiceMessage,
    this.isRecording = false,
    this.isLoading = false,
    this.placeholder,
    this.attachedFiles = const [],
    this.onRemoveFile,
  });

  @override
  State<ModernMessageInput> createState() => _ModernMessageInputState();
}

class _ModernMessageInputState extends State<ModernMessageInput>
    with TickerProviderStateMixin {
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);

    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _sendButtonScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.elasticOut,
    ));

    _onTextChanged();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _sendButtonController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });

      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  void _handleSend() {
    if (_hasText && !widget.isLoading) {
      HapticFeedback.lightImpact();
      widget.onSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Attached files
            if (widget.attachedFiles.isNotEmpty)
              _buildAttachedFiles(theme, colorScheme),

            // Input area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Voice message button
                  if (widget.onVoiceMessage != null) ...[
                    _buildVoiceButton(theme, colorScheme),
                    const SizedBox(width: 8),
                  ],

                  // File attachment button
                  if (widget.onAttachFile != null) ...[
                    _buildAttachButton(theme, colorScheme),
                    const SizedBox(width: 8),
                  ],

                  // Text input
                  Expanded(
                    child: _buildTextInput(theme, colorScheme),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  _buildSendButton(theme, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachedFiles(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Attached Files',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.attachedFiles
                .map((file) => _buildFileChip(file, theme, colorScheme))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileChip(
      String fileName, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(fileName),
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            fileName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: widget.onRemoveFile,
            child: Icon(
              Icons.close,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildVoiceButton(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: widget.isRecording
            ? Colors.red.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isRecording
              ? Colors.red.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onVoiceMessage,
          child: Icon(
            widget.isRecording ? Icons.stop : Icons.mic,
            color: widget.isRecording ? Colors.red : colorScheme.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachButton(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onAttachFile,
          child: Icon(
            Icons.attach_file,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 120),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: widget.controller,
        maxLines: null,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _handleSend(),
        decoration: InputDecoration(
          hintText: widget.placeholder ?? 'Ask me about your machine...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _sendButtonScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _sendButtonScale.value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _hasText
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hasText
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _hasText && !widget.isLoading ? _handleSend : null,
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: _hasText
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
