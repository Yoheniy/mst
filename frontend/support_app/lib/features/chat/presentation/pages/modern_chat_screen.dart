import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/modern_chat_message_widget.dart';
import '../widgets/modern_message_input.dart';
import '../widgets/modern_welcome_screen.dart';
import '../../domain/entities/chat_entities.dart';
import '../../../machines/domain/entities/machine.dart';
import '../../../machines/presentation/bloc/machine_bloc.dart';

class ModernChatScreen extends StatefulWidget {
  final int? sessionId;
  final String? sessionTitle;
  final int? machineId;

  const ModernChatScreen({
    super.key,
    this.sessionId,
    this.sessionTitle,
    this.machineId,
  });

  @override
  State<ModernChatScreen> createState() => _ModernChatScreenState();
}

class _ModernChatScreenState extends State<ModernChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];

  // Machine context
  Machine? _selectedMachine;
  bool _showMachineSelector = false;

  // File upload
  List<String> _attachedFiles = [];

  // Voice message
  bool _isRecording = false;

  // Quick response templates
  bool _showTemplates = false;

  // Advanced RAG features
  String? _selectedMachineType;
  String? _selectedChunkType;
  bool _showAdvancedOptions = false;

  // Animation controllers
  late AnimationController _fabController;

  // Quick response templates
  final List<Map<String, String>> _quickTemplates = [
    {
      'title': 'Machine Not Starting',
      'message':
          'My machine is not starting. Can you help me troubleshoot this issue?',
    },
    {
      'title': 'Unusual Noise',
      'message':
          'My machine is making unusual noises during operation. What should I check?',
    },
    {
      'title': 'Poor Quality Output',
      'message':
          'The quality of my machine\'s output has decreased. How can I improve it?',
    },
    {
      'title': 'Maintenance Schedule',
      'message': 'What is the recommended maintenance schedule for my machine?',
    },
    {
      'title': 'Safety Check',
      'message': 'Can you guide me through a safety inspection checklist?',
    },
    {
      'title': 'Error Code Help',
      'message':
          'I\'m seeing an error code on my machine. Can you help me understand what it means?',
    },
  ];

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.sessionId != null) {
      context.read<ChatBloc>().add(LoadSessionMessages(widget.sessionId!));
    }

    // Load machines for context
    context.read<MachineBloc>().add(LoadMachines());

    // If machineId is provided, find the machine
    if (widget.machineId != null) {
      _loadMachineContext(widget.machineId!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _loadMachineContext(int machineId) {
    // This would typically load from the machine bloc
    // For now, we'll handle it in the build method
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message to local list
    final userMessage = ChatMessage(
      sessionId: widget.sessionId ?? 0,
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMessage);
    });
    _messageController.clear();
    _scrollToBottom();

    // Send to AI with machine context
    context.read<ChatBloc>().add(SendMessage(
          message,
          sessionId: widget.sessionId,
          machineType: _selectedMachine?.type.name,
          chunkTypeFilter: _selectedChunkType,
        ));
  }

  void _toggleAdvancedOptions() {
    setState(() {
      _showAdvancedOptions = !_showAdvancedOptions;
    });
  }

  void _toggleMachineSelector() {
    setState(() {
      _showMachineSelector = !_showMachineSelector;
    });
  }

  void _selectMachine(Machine machine) {
    setState(() {
      _selectedMachine = machine;
      _showMachineSelector = false;
    });

    // Show machine context message
    final contextMessage = ChatMessage(
      sessionId: widget.sessionId ?? 0,
      role: 'system',
      content:
          'Chat context set to: ${machine.name} (${machine.typeDisplayName}) - Status: ${machine.statusDisplayName}',
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(contextMessage);
    });
    _scrollToBottom();
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
    });

    // TODO: Implement voice recording
    // This would integrate with speech-to-text service

    // Simulate recording for now
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });

        // Simulate transcribed text
        _messageController.text = "Hello, I need help with my machine";
        _sendMessage();
      }
    });
  }

  void _stopVoiceRecording() {
    setState(() {
      _isRecording = false;
    });
    // TODO: Stop recording and process audio
  }

  void _pickFiles() async {
    // TODO: Implement file picker
    // This would integrate with file_picker package

    // Simulate file upload
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _attachedFiles.add('document_${_attachedFiles.length + 1}.pdf');
      });
    }
  }

  void _removeFile(String fileName) {
    setState(() {
      _attachedFiles.remove(fileName);
    });
  }

  void _toggleTemplates() {
    setState(() {
      _showTemplates = !_showTemplates;
    });
  }

  void _selectTemplate(Map<String, String> template) {
    _messageController.text = template['message']!;
    setState(() {
      _showTemplates = false;
    });
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildModernAppBar(theme, colorScheme),
      body: Column(
        children: [
          // Machine Context Banner
          if (_selectedMachine != null)
            _buildMachineContextBanner(theme, colorScheme),

          // Machine Selector Panel
          if (_showMachineSelector)
            _buildMachineSelectorPanel(theme, colorScheme),

          // Quick Templates Panel
          if (_showTemplates) _buildTemplatesPanel(theme, colorScheme),

          // Advanced RAG Options Panel
          if (_showAdvancedOptions)
            _buildAdvancedOptionsPanel(theme, colorScheme),

          // Chat Messages
          Expanded(
            child: BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is SessionMessagesLoaded) {
                  setState(() {
                    _messages = state.messages;
                  });
                  _scrollToBottom();
                } else if (state is MessageSent) {
                  // Add AI response to local list
                  final aiMessage = ChatMessage(
                    sessionId: state.sessionId,
                    role: 'assistant',
                    content: state.response.response,
                    timestamp: DateTime.now(),
                    metadata: {
                      'ai_response': true,
                      'confidence': state.response.confidence,
                      'model': state.response.model,
                      'usage': state.response.usage,
                    },
                  );
                  setState(() {
                    _messages.add(aiMessage);
                  });
                  _scrollToBottom();
                } else if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.message}'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              child: _messages.isEmpty
                  ? ModernWelcomeScreen(
                      selectedMachine: _selectedMachine,
                      onSelectMachine: _toggleMachineSelector,
                      quickTemplates: _quickTemplates,
                      onSelectTemplate: _selectTemplate,
                      showTemplates: _showTemplates,
                    )
                  : _buildChatMessages(theme, colorScheme),
            ),
          ),

          // Modern Message Input
          ModernMessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            onAttachFile: _pickFiles,
            onVoiceMessage:
                _isRecording ? _stopVoiceRecording : _startVoiceRecording,
            isRecording: _isRecording,
            isLoading: false, // You can connect this to your bloc state
            placeholder: _selectedMachine != null
                ? 'Ask about ${_selectedMachine!.name}...'
                : 'Ask me about your machine...',
            attachedFiles: _attachedFiles,
            onRemoveFile: () => _removeFile(_attachedFiles.last),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(
      ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.sessionTitle ?? 'AI Support',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_selectedMachine != null)
            Text(
              _selectedMachine!.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      actions: [
        _buildAppBarAction(
          icon: _selectedMachine != null
              ? Icons.build_rounded
              : Icons.build_outlined,
          onPressed: _toggleMachineSelector,
          tooltip: 'Select Machine Context',
          colorScheme: colorScheme,
        ),
        _buildAppBarAction(
          icon: Icons.attach_file_rounded,
          onPressed: _pickFiles,
          tooltip: 'Attach Files',
          colorScheme: colorScheme,
        ),
        _buildAppBarAction(
          icon: _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
          onPressed: _isRecording ? _stopVoiceRecording : _startVoiceRecording,
          tooltip: _isRecording ? 'Stop Recording' : 'Voice Message',
          colorScheme: colorScheme,
          isActive: _isRecording,
        ),
        _buildAppBarAction(
          icon: _showTemplates
              ? Icons.quickreply_rounded
              : Icons.quickreply_outlined,
          onPressed: _toggleTemplates,
          tooltip: 'Quick Templates',
          colorScheme: colorScheme,
          isActive: _showTemplates,
        ),
        _buildAppBarAction(
          icon: _showAdvancedOptions ? Icons.tune_rounded : Icons.tune_outlined,
          onPressed: _toggleAdvancedOptions,
          tooltip: 'Advanced Options',
          colorScheme: colorScheme,
          isActive: _showAdvancedOptions,
        ),
      ],
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required ColorScheme colorScheme,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isActive
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildMachineContextBanner(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _selectedMachine!.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedMachine!.statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedMachine!.statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.build_rounded,
              color: _selectedMachine!.statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chatting about: ${_selectedMachine!.name}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: _selectedMachine!.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_selectedMachine!.typeDisplayName} • ${_selectedMachine!.statusDisplayName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _selectedMachine!.statusColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () {
              setState(() {
                _selectedMachine = null;
              });
            },
            color: _selectedMachine!.statusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMachineSelectorPanel(ThemeData theme, ColorScheme colorScheme) {
    return BlocBuilder<MachineBloc, MachineState>(
      builder: (context, state) {
        if (state is MachineLoading) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is MachinesLoaded) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Machine Context',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.machines.length,
                    itemBuilder: (context, index) {
                      final machine = state.machines[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          elevation: 0,
                          color: colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _selectMachine(machine),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: machine.statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          machine.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    machine.typeDisplayName,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text(
                                    machine.statusDisplayName,
                                    style: TextStyle(
                                      color: machine.statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTemplatesPanel(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quickreply_rounded,
                  color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick Response Templates',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickTemplates.length,
              itemBuilder: (context, index) {
                final template = _quickTemplates[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _selectTemplate(template),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.quickreply_rounded,
                                  color: colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    template['title']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              template['message']!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsPanel(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Advanced Options',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMachineType,
                  decoration: InputDecoration(
                    labelText: 'Machine Type Filter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...MachineType.values
                        .map((type) => DropdownMenuItem<String>(
                              value: type.name,
                              child: Text(type.name.toUpperCase()),
                            )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMachineType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedChunkType,
                  decoration: InputDecoration(
                    labelText: 'Content Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Content'),
                    ),
                    ...[
                      'procedure',
                      'safety',
                      'maintenance',
                      'specification',
                      'overview',
                      'general'
                    ].map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type.toUpperCase()),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedChunkType = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ModernChatMessageWidget(
          message: message,
          isCurrentUser: message.role == 'user',
          showAvatar: true,
        );
      },
    );
  }
}
