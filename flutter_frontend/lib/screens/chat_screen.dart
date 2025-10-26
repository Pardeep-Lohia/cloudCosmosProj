import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/chat_provider.dart';
import '../models/app_models.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Ask Questions'),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.uploadedFiles.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return Column(
                    children: [
                      // Messages list
                      Expanded(
                        child: chatProvider.messages.isEmpty
                            ? _buildWelcomeMessage()
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: chatProvider.messages.length,
                                itemBuilder: (context, index) {
                                  final message = chatProvider.messages[index];
                                  return MessageBubble(
                                    message: message,
                                    key: Key(message.id),
                                  );
                                },
                              ),
                      ),
                      
                      // Input area
                      _buildInputArea(chatProvider),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Notes Uploaded',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload PDF notes first to start asking questions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Notes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ask me anything!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'I can help you understand your notes and answer questions based on the content you\'ve uploaded.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSampleQuestions(),
        ],
      ),
    );
  }

  Widget _buildSampleQuestions() {
    final sampleQuestions = [
      'What are the main topics in my notes?',
      'Can you summarize the key concepts?',
      'What should I focus on for the exam?',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try asking:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...sampleQuestions.map((question) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                _messageController.text = question;
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ).toList(),
      ],
    );
  }

  Widget _buildInputArea(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask a question about your notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : () => _sendMessage(chatProvider),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(ChatProvider chatProvider) async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    chatProvider.addMessage(userMessage);
    _messageController.clear();
    _scrollToBottom();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.askQuestion(
        question: message,
        userId: 'default',
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response['answer'],
        isUser: false,
        timestamp: DateTime.now(),
        sources: response['sources'],
      );

      chatProvider.addMessage(aiMessage);
      _scrollToBottom();

    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      chatProvider.addMessage(errorMessage);
      _scrollToBottom();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
