# StudyBuddy AI - Complete Project Structure

## 📁 Project Overview

This repository contains the complete **StudyBuddy AI** application with both backend (FastAPI) and frontend (Flutter) implementations.

## 🚀 Features Implemented

### Backend (FastAPI)
- ✅ **PDF Upload & Processing**: Extract text from PDF files
- ✅ **RAG Pipeline**: ChromaDB + Sentence Transformers for semantic search
- ✅ **AI-Powered Q&A**: Context-aware answers using OpenAI GPT
- ✅ **Quiz Generation**: Automatic MCQ creation from notes
- ✅ **CORS Support**: Ready for Flutter frontend integration

### Frontend (Flutter)
- ✅ **Material Design 3**: Modern, responsive UI
- ✅ **Multi-Screen Navigation**: Home, Upload, Chat, Quiz screens
- ✅ **Local Storage**: Chat history and file tracking
- ✅ **Animations**: Smooth transitions with flutter_animate
- ✅ **Provider Pattern**: State management for chat and data
- ✅ **Error Handling**: Comprehensive error states and loading indicators

## 📂 Directory Structure

```
studybuddy_ai/
├── 📄 main.py                     # FastAPI backend server
├── 📄 requirements.txt            # Python dependencies
├── 📄 test_api.py                 # API testing script
├── 📄 README.md                   # Backend documentation
│
└── flutter_frontend/              # Flutter mobile app
    ├── 📄 pubspec.yaml            # Flutter dependencies
    ├── lib/
    │   ├── 📄 main.dart           # App entry point
    │   ├── screens/               # UI Screens
    │   │   ├── 📄 home_screen.dart
    │   │   ├── 📄 upload_screen.dart
    │   │   ├── 📄 chat_screen.dart
    │   │   └── 📄 quiz_screen.dart
    │   ├── services/              # Business logic
    │   │   ├── 📄 api_service.dart
    │   │   └── 📄 chat_provider.dart
    │   ├── models/                # Data models
    │   │   └── 📄 app_models.dart
    │   └── widgets/               # Reusable UI components
    │       ├── 📄 app_bar_widget.dart
    │       ├── 📄 stats_card.dart
    │       └── 📄 message_bubble.dart
```

## 🛠️ Setup Instructions

### Backend Setup

1. **Install Python Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Set Environment Variables**
   ```bash
   export OPENAI_API_KEY="your_openai_api_key_here"
   ```

3. **Run the Backend Server**
   ```bash
   python main.py
   ```
   Server will start at `http://localhost:8000`

4. **Test API Endpoints**
   ```bash
   python test_api.py
   ```

### Frontend Setup

1. **Navigate to Flutter Directory**
   ```bash
   cd flutter_frontend
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API Base URL** (if needed)
   Edit `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://your-backend-url:8000';
   ```

4. **Run Flutter App**
   ```bash
   flutter run
   ```

## 🔧 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Health check |
| `POST` | `/upload_notes` | Upload PDF notes |
| `POST` | `/ask` | Ask questions about notes |
| `POST` | `/generate_quiz` | Generate quiz from notes |

## 📱 App Screens

1. **🏠 Home Screen**: Dashboard with stats and quick actions
2. **📤 Upload Screen**: PDF file selection and upload
3. **💬 Chat Screen**: Interactive Q&A with AI
4. **🧠 Quiz Screen**: Generated quizzes with scoring

## 🔍 Key Technologies

### Backend
- **FastAPI**: Modern Python web framework
- **ChromaDB**: Vector database for embeddings
- **Sentence Transformers**: Text embedding generation
- **OpenAI GPT**: Language model for Q&A and quiz generation
- **PyPDF2**: PDF text extraction

### Frontend
- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **Shared Preferences**: Local data persistence
- **HTTP**: API communication
- **File Picker**: File selection functionality
- **Flutter Animate**: UI animations
- **Google Fonts**: Typography

## 🎯 Usage Flow

1. **📱 Open App** → Home screen with overview
2. **📄 Upload Notes** → Select and upload PDF files
3. **❓ Ask Questions** → Chat with AI about your notes
4. **🧠 Take Quiz** → Test knowledge with generated questions
5. **📊 View Progress** → Track learning statistics

## ⚙️ Configuration

### Backend Configuration
- **Chunk Size**: 500 characters (adjustable in `main.py`)
- **Retrieval Count**: Top 3 chunks for Q&A
- **Quiz Questions**: 2-5 questions per quiz
- **Embedding Model**: `all-MiniLM-L6-v2`

### Frontend Configuration
- **Theme**: Material Design 3 with custom colors
- **Animations**: Fade and slide transitions
- **Storage**: Local chat history and file tracking
- **Network**: HTTP client with error handling

## 🚀 Next Steps (Phase 3 & 4)

### Phase 3: Integration & Testing
- [ ] End-to-end testing between frontend and backend
- [ ] Performance optimization and caching
- [ ] Enhanced error handling
- [ ] Loading states and user feedback

### Phase 4: Enhancements
- [ ] User authentication and profiles
- [ ] Voice-based Q&A functionality
- [ ] Topic-wise quiz categories
- [ ] Cloud deployment (FastAPI + Flutter Web)
- [ ] Analytics dashboard
- [ ] Multi-language support

## 📋 Development Status

✅ **Phase 1**: Backend Foundation - COMPLETE  
✅ **Phase 2**: Flutter Frontend - COMPLETE  
🔄 **Phase 3**: Integration & Testing - READY TO START  
⏳ **Phase 4**: Enhancements - PLANNED  

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -m 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Open Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

---

**StudyBuddy AI** - Your intelligent study companion! 🎓✨
