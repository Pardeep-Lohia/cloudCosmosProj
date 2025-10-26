import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/chat_provider.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/stats_card.dart';
import 'upload_screen.dart';
import 'chat_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return CustomScrollView(
              slivers: [
                // Custom App Bar
                const SliverToBoxAdapter(
                  child: CustomAppBar(title: 'StudyBuddy AI'),
                ),
                
                // Welcome Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ).animate().fadeIn().slideX(),
                        const SizedBox(height: 8),
                        Text(
                          'Continue your learning journey',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ).animate(delay: 200.ms).fadeIn().slideX(),
                      ],
                    ),
                  ),
                ),
                
                // Stats Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Notes',
                            value: '${chatProvider.uploadedFiles.length}',
                            icon: Icons.description_outlined,
                            color: Colors.blue,
                          ).animate(delay: 400.ms).fadeIn().slideY(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatsCard(
                            title: 'Chats',
                            value: '${chatProvider.messages.where((m) => m.isUser).length}',
                            icon: Icons.chat_bubble_outline,
                            color: Colors.green,
                          ).animate(delay: 600.ms).fadeIn().slideY(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Recent Files Section
                if (chatProvider.uploadedFiles.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Notes',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...chatProvider.uploadedFiles.take(3).map((file) => 
                            Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                title: Text(file.filename),
                                subtitle: Text(
                                  '${file.chunksProcessed} chunks • ${_formatDate(file.uploadTime)}',
                                ),
                                trailing: Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ).animate(delay: (800 + chatProvider.uploadedFiles.indexOf(file) * 100).ms)
                                .fadeIn().slideX(),
                          ).toList(),
                        ],
                      ),
                    ),
                  ),
                
                // Action Buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Upload Notes Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const UploadScreen()),
                              );
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Notes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ).animate(delay: 1000.ms).fadeIn().slideY(),
                        
                        const SizedBox(height: 16),
                        
                        // Action Grid
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                title: 'Ask Questions',
                                subtitle: 'Chat with AI',
                                icon: Icons.chat_outlined,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                                  );
                                },
                              ).animate(delay: 1200.ms).fadeIn().slideX(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionButton(
                                title: 'Take Quiz',
                                subtitle: 'Test knowledge',
                                icon: Icons.quiz_outlined,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const QuizScreen()),
                                  );
                                },
                              ).animate(delay: 1400.ms).fadeIn().slideX(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
