import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/chat_provider.dart';
import '../models/app_models.dart';
import '../widgets/app_bar_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  bool _quizCompleted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Quiz Time'),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.uploadedFiles.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  if (_isLoading) {
                    return _buildLoadingState();
                  }
                  
                  if (_questions.isEmpty) {
                    return _buildErrorState();
                  }
                  
                  if (_quizCompleted) {
                    return _buildResultsState();
                  }
                  
                  return _buildQuizState();
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
              Icons.quiz_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Notes Available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload PDF notes first to generate quizzes',
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Generating quiz from your notes...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Quiz Generation Failed',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to generate quiz from your notes. Please try again.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizState() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                'Score: $_score',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              currentQuestion.question,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Options
          Expanded(
            child: ListView.builder(
              itemCount: currentQuestion.options.length,
              itemBuilder: (context, index) {
                final option = currentQuestion.options[index];
                final isSelected = currentQuestion.selectedAnswer == option;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _selectOption(option),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.surfaceVariant,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Next button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: currentQuestion.selectedAnswer != null
                  ? _nextQuestion
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _currentQuestionIndex == _questions.length - 1
                    ? 'Finish Quiz'
                    : 'Next Question',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsState() {
    final percentage = (_score / _questions.length * 100).round();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  percentage >= 70 ? Icons.celebration : Icons.emoji_events_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Quiz Completed!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Score',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '$_score/${_questions.length}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _retakeQuiz,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Take New Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateQuiz() async {
    setState(() {
      _isLoading = true;
      _questions = [];
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
    });

    try {
      final response = await ApiService.generateQuiz(
        topic: '',
        userId: 'default',
        numQuestions: 5,
      );

      final questionsList = response['questions'] as List;
      setState(() {
        _questions = questionsList
            .map((q) => QuizQuestion.fromJson(q))
            .toList();
      });

    } catch (e) {
      // Questions will remain empty, showing error state
      print('Quiz generation error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectOption(String option) {
    setState(() {
      _questions[_currentQuestionIndex].selectedAnswer = option;
    });
  }

  void _nextQuestion() {
    final currentQuestion = _questions[_currentQuestionIndex];
    if (currentQuestion.isCorrect) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _retakeQuiz() {
    _generateQuiz();
  }
}
