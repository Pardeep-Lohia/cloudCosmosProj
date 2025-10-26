# StudyBuddy AI Backend

A FastAPI-based backend for the StudyBuddy AI application that provides intelligent Q&A and quiz generation from uploaded PDF notes.

## Features

- **PDF Upload & Processing**: Upload PDF notes and extract text content
- **RAG Pipeline**: Retrieval-Augmented Generation using ChromaDB and sentence transformers
- **AI-Powered Q&A**: Ask questions about your notes and get contextual answers
- **Quiz Generation**: Automatically generate multiple-choice quizzes from your content
- **User Isolation**: Per-user note storage and retrieval

## Tech Stack

- **FastAPI**: Modern, fast web framework for building APIs
- **ChromaDB**: Vector database for storing and retrieving embeddings
- **Sentence Transformers**: For generating text embeddings
- **OpenAI GPT**: For generating answers and quizzes
- **PyPDF2**: For PDF text extraction

## API Endpoints

### `GET /`
Health check endpoint

### `POST /upload_notes`
Upload PDF notes for processing
- **Parameters**: `file` (PDF file), `user_id` (optional)
- **Returns**: Upload confirmation with processing stats

### `POST /ask`
Ask questions about uploaded notes
- **Body**: `{"question": "your question", "user_id": "optional"}`
- **Returns**: AI-generated answer with source count

### `POST /generate_quiz`
Generate quiz from uploaded notes
- **Body**: `{"topic": "optional", "user_id": "optional", "num_questions": 2}`
- **Returns**: Array of multiple-choice questions

## Setup Instructions

1. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Environment Variables**
   Create a `.env` file:
   ```
   OPENAI_API_KEY=your_openai_api_key_here
   ```

3. **Run the Application**
   ```bash
   python main.py
   ```
   The API will be available at `http://localhost:8000`

4. **API Documentation**
   Visit `http://localhost:8000/docs` for interactive API documentation

## Data Flow

1. **Upload**: PDF → Text Extraction → Text Chunking → Embeddings → ChromaDB Storage
2. **Query**: Question → Embedding → Vector Search → Context Retrieval → LLM → Answer
3. **Quiz**: Notes → Context Selection → LLM Prompt → MCQ Generation → JSON Response

## Configuration

- **Chunk Size**: 500 characters (configurable in `split_text_into_chunks()`)
- **Retrieval Count**: Top 3 relevant chunks for Q&A
- **Quiz Questions**: Default 2 questions (configurable via API)
- **Embedding Model**: `all-MiniLM-L6-v2` (lightweight and efficient)

## Error Handling

- File validation (PDF only)
- Empty PDF detection
- Missing notes error handling
- LLM response parsing with fallbacks

## Next Steps

- Add user authentication
- Implement persistent storage
- Add support for more file formats
- Enhanced chunking strategies
- Topic-based quiz generation
- Caching for improved performance
