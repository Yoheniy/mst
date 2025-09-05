import 'package:flutter/material.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  String? _selectedFileName;
  final _titleController = TextEditingController();
  String _selectedDocumentType = 'manual';
  String _selectedMachineType = 'General';
  bool _useSmartChunking = true;
  bool _isUploading = false;

  final List<String> _documentTypes = [
    'manual',
    'faq',
    'troubleshooting',
    'training',
    'safety',
    'maintenance',
    'specification'
  ];

  final List<String> _machineTypes = [
    'CNC',
    'Lathe',
    'Mill',
    'Drill',
    'Grinder',
    'Saw',
    'Press',
    'Welder',
    'General'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _pickFile() {
    // Simulate file selection
    setState(() {
      _selectedFileName = 'sample_document.pdf';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File selection simulated'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _uploadDocument() async {
    if (_selectedFileName == null || _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file and enter a title'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate upload

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Document "${_titleController.text}" uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          _selectedFileName = null;
          _titleController.clear();
          _selectedDocumentType = 'manual';
          _selectedMachineType = 'General';
          _useSmartChunking = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Upload'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.upload_file,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Enhanced RAG Document Processing',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload documents with advanced processing including smart chunking, metadata extraction, and technical term identification.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // File Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Select Document',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickFile,
                      icon: const Icon(Icons.file_upload),
                      label: Text(_selectedFileName == null
                          ? 'Choose File'
                          : 'Change File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_selectedFileName != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFileName!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Size: 256.0 KB (simulated)',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Document Configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Configure Processing',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Document Title',
                        hintText: 'Enter a descriptive title',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Document Type and Machine Type
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDocumentType,
                            decoration: const InputDecoration(
                              labelText: 'Document Type',
                              border: OutlineInputBorder(),
                            ),
                            items: _documentTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.replaceFirst(
                                    type[0], type[0].toUpperCase())),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDocumentType = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedMachineType,
                            decoration: const InputDecoration(
                              labelText: 'Machine Type',
                              border: OutlineInputBorder(),
                            ),
                            items: _machineTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMachineType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Smart Chunking Toggle
                    SwitchListTile(
                      title: const Text('Use Smart Chunking'),
                      subtitle: const Text(
                          'Intelligent text splitting with semantic boundaries'),
                      value: _useSmartChunking,
                      onChanged: (value) {
                        setState(() {
                          _useSmartChunking = value;
                        });
                      },
                      secondary: Icon(
                        Icons.psychology,
                        color: _useSmartChunking ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Processing Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3. Processing Features',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.text_fields,
                      title: 'Smart Text Chunking',
                      description:
                          'Semantic boundaries and intelligent splitting',
                      enabled: _useSmartChunking,
                    ),
                    _buildFeatureItem(
                      icon: Icons.tag,
                      title: 'Metadata Extraction',
                      description:
                          'Technical terms and document structure analysis',
                      enabled: true,
                    ),
                    _buildFeatureItem(
                      icon: Icons.search,
                      title: 'Enhanced Search',
                      description:
                          'Intent-based retrieval with chunk type filtering',
                      enabled: true,
                    ),
                    _buildFeatureItem(
                      icon: Icons.analytics,
                      title: 'Vector Storage',
                      description: 'Pinecone integration for semantic search',
                      enabled: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Upload Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedFileName != null &&
                        _titleController.text.trim().isNotEmpty &&
                        !_isUploading
                    ? _uploadDocument
                    : null,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isUploading
                    ? 'Processing...'
                    : 'Upload & Process Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.black87 : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: enabled ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            enabled ? Icons.check_circle : Icons.circle_outlined,
            color: enabled ? Colors.green : Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }
}
