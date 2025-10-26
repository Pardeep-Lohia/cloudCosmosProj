import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Change for production
  
  // Upload PDF notes
  static Future<Map<String, dynamic>> uploadNotes({
    required File file,
    String userId = 'default',
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/upload_notes');
      var request = http.MultipartRequest('POST', uri);
      
      request.fields['user_id'] = userId;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to upload notes: $responseData');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }
  
  // Ask a question
  static Future<Map<String, dynamic>> askQuestion({
    required String question,
    String userId = 'default',
  }) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/ask'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'question': question,
          'user_id': userId,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get answer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Question error: $e');
    }
  }
  
  // Generate quiz
  static Future<Map<String, dynamic>> generateQuiz({
    String topic = '',
    String userId = 'default',
    int numQuestions = 2,
  }) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/generate_quiz'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'topic': topic,
          'user_id': userId,
          'num_questions': numQuestions,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate quiz: ${response.body}');
      }
    } catch (e) {
      throw Exception('Quiz generation error: $e');
    }
  }
  
  // Health check
  static Future<bool> checkConnection() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
