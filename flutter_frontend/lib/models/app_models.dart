class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final int? sources;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.sources,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'sources': sources,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    content: json['content'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
    sources: json['sources'],
  );
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  String? selectedAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.selectedAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    question: json['question'],
    options: List<String>.from(json['options']),
    correctAnswer: json['correct_answer'],
  );

  bool get isCorrect => selectedAnswer == correctAnswer;
}

class UploadedFile {
  final String filename;
  final int chunksProcessed;
  final DateTime uploadTime;

  UploadedFile({
    required this.filename,
    required this.chunksProcessed,
    required this.uploadTime,
  });

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'chunksProcessed': chunksProcessed,
    'uploadTime': uploadTime.toIso8601String(),
  };

  factory UploadedFile.fromJson(Map<String, dynamic> json) => UploadedFile(
    filename: json['filename'],
    chunksProcessed: json['chunksProcessed'],
    uploadTime: DateTime.parse(json['uploadTime']),
  );
}
