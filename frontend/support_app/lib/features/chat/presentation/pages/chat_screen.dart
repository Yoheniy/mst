import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/chat_message_widget.dart';
import '../../domain/entities/chat_entities.dart';
import '../../../machines/domain/entities/machine.dart';
import '../../../machines/presentation/bloc/machine_bloc.dart';

class ChatScreen extends StatefulWidget {
  final int? sessionId;
  final String? sessionTitle;
  final int? machineId; // New: machine context

  const ChatScreen({
    super.key,
    this.sessionId,
    this.sessionTitle,
    this.machineId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];

  // Machine context
  Machine? _selectedMachine;
  bool _showMachineSelector = false;

  // File upload
  bool _isUploading = false;
  List<String> _attachedFiles = [];

  // Voice message
  bool _isRecording = false;

  // Quick response templates
  bool _showTemplates = false;

  // Advanced RAG features
  String? _selectedMachineType;
  String? _selectedChunkType;
  bool _showAdvancedOptions = false;

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

    setState(() {
      _isUploading = true;
    });

    // Simulate file upload
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isUploading = false;
        _attachedFiles.add('document_${_attachedFiles.length + 1}.pdf');
      });
    }
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.sessionTitle ?? 'AI Chat'),
            if (_selectedMachine != null)
              Text(
                _selectedMachine!.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Machine context selector
          IconButton(
            icon: Icon(
                _selectedMachine != null ? Icons.build : Icons.build_outlined),
            onPressed: _toggleMachineSelector,
            tooltip: 'Select Machine Context',
          ),
          // File upload
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickFiles,
            tooltip: 'Attach Files',
          ),
          // Voice message
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            onPressed:
                _isRecording ? _stopVoiceRecording : _startVoiceRecording,
            tooltip: _isRecording ? 'Stop Recording' : 'Voice Message',
            color: _isRecording ? Colors.red : null,
          ),
          // Quick templates
          IconButton(
            icon: Icon(
                _showTemplates ? Icons.quickreply : Icons.quickreply_outlined),
            onPressed: _toggleTemplates,
            tooltip: 'Quick Templates',
          ),
          // Advanced options
          IconButton(
            icon: Icon(_showAdvancedOptions ? Icons.tune : Icons.tune_outlined),
            onPressed: _toggleAdvancedOptions,
            tooltip: 'Advanced Options',
          ),
        ],
      ),
      body: Column(
        children: [
          // Machine Context Banner
          if (_selectedMachine != null) _buildMachineContextBanner(),

          // Machine Selector Panel
          if (_showMachineSelector) _buildMachineSelectorPanel(),

          // Quick Templates Panel
          if (_showTemplates) _buildTemplatesPanel(),

          // Advanced RAG Options Panel
          if (_showAdvancedOptions) _buildAdvancedOptionsPanel(),

          // File Attachments
          if (_attachedFiles.isNotEmpty) _buildFileAttachments(),

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
                    ),
                  );
                }
              },
              child: _messages.isEmpty
                  ? _buildWelcomeMessage()
                  : _buildChatMessages(),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMachineContextBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _selectedMachine!.statusColor.withOpacity(0.1),
        border: Border(
          bottom:
              BorderSide(color: _selectedMachine!.statusColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.build,
            color: _selectedMachine!.statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chatting about: ${_selectedMachine!.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedMachine!.statusColor,
                  ),
                ),
                Text(
                  '${_selectedMachine!.typeDisplayName} • ${_selectedMachine!.statusDisplayName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedMachine!.statusColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              setState(() {
                _selectedMachine = null;
              });
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineSelectorPanel() {
    return BlocBuilder<MachineBloc, MachineState>(
      builder: (context, state) {
        if (state is MachineLoading) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is MachinesLoaded) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Machine Context',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
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
                          child: InkWell(
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
                                            fontWeight: FontWeight.bold,
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
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
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

  Widget _buildTemplatesPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border(
          bottom: BorderSide(color: Colors.green[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quickreply, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick Response Templates',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
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
                    child: InkWell(
                      onTap: () => _selectTemplate(template),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.quickreply,
                                  color: Colors.green[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    template['title']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
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

  Widget _buildFileAttachments() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.blue[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attached Files',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _attachedFiles
                .map((file) => Chip(
                      label: Text(file),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _attachedFiles.remove(file);
                        });
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.blue[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Advanced Options',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
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
                  decoration: const InputDecoration(
                    labelText: 'Machine Type Filter',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  decoration: const InputDecoration(
                    labelText: 'Content Type',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to AI Support Chat',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedMachine != null
                ? 'I\'m here to help with ${_selectedMachine!.name}. What can I assist you with today?'
                : 'I\'m here to help with your machine tools. Select a machine for context or ask me anything!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (_selectedMachine == null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _toggleMachineSelector,
              icon: const Icon(Icons.build),
              label: const Text('Select Machine Context'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ChatMessageWidget(
            message: message,
            isCurrentUser: message.role == 'user',
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          // Voice button
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            onPressed:
                _isRecording ? _stopVoiceRecording : _startVoiceRecording,
            color: _isRecording
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
          ),

          // File attachment button
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickFiles,
            color: Theme.of(context).colorScheme.primary,
          ),

          // Text input
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: _selectedMachine != null
                    ? 'Ask about ${_selectedMachine!.name}...'
                    : 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}



