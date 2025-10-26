import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/chat_provider.dart';
import '../models/app_models.dart';
import '../widgets/app_bar_widget.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  bool _isUploading = false;
  String? _uploadMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Upload Notes'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Your Study Notes',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload PDF files to get AI-powered answers and quizzes',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // File selection area
                    GestureDetector(
                      onTap: _selectFile,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedFile != null 
                                ? Icons.picture_as_pdf 
                                : Icons.cloud_upload_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFile != null 
                                ? _getFileName(_selectedFile!.path)
                                : 'Tap to select PDF file',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFile != null
                                ? 'File selected successfully'
                                : 'Only PDF files are supported',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Upload message
                    if (_uploadMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _uploadMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    
                    const Spacer(),
                    
                    // Upload button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedFile != null && !_isUploading
                            ? _uploadFile
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Upload Notes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _uploadMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadMessage = 'Error selecting file: $e';
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadMessage = null;
    });

    try {
      final result = await ApiService.uploadNotes(
        file: _selectedFile!,
        userId: 'default',
      );

      // Add to chat provider
      if (!mounted) return;
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.addUploadedFile(
        UploadedFile(
          filename: result['filename'],
          chunksProcessed: result['chunks_processed'],
          uploadTime: DateTime.now(),
        ),
      );

      setState(() {
        _uploadMessage = 'Upload successful! ${result['chunks_processed']} chunks processed.';
      });

      // Navigate back after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });

    } catch (e) {
      setState(() {
        _uploadMessage = 'Upload failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }
}
