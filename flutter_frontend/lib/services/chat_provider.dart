import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_models.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  List<UploadedFile> _uploadedFiles = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  List<UploadedFile> get uploadedFiles => _uploadedFiles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatProvider() {
    _loadFromStorage();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    _saveToStorage();
    notifyListeners();
  }

  void addUploadedFile(UploadedFile file) {
    _uploadedFiles.add(file);
    _saveToStorage();
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _saveToStorage();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Local storage methods
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load messages
      final messagesJson = prefs.getString('chat_messages');
      if (messagesJson != null) {
        final messagesList = json.decode(messagesJson) as List;
        _messages = messagesList
            .map((msg) => ChatMessage.fromJson(msg))
            .toList();
      }
      
      // Load uploaded files
      final filesJson = prefs.getString('uploaded_files');
      if (filesJson != null) {
        final filesList = json.decode(filesJson) as List;
        _uploadedFiles = filesList
            .map((file) => UploadedFile.fromJson(file))
            .toList();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading from storage: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save messages
      final messagesJson = json.encode(
        _messages.map((msg) => msg.toJson()).toList(),
      );
      await prefs.setString('chat_messages', messagesJson);
      
      // Save uploaded files
      final filesJson = json.encode(
        _uploadedFiles.map((file) => file.toJson()).toList(),
      );
      await prefs.setString('uploaded_files', filesJson);
      
    } catch (e) {
      print('Error saving to storage: $e');
    }
  }
}
