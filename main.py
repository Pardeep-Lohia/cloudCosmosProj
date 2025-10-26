from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import chromadb
from sentence_transformers import SentenceTransformer
import os
from typing import List, Dict
import PyPDF2
import io
import openai
from dotenv import load_dotenv
import uuid

load_dotenv()

app = FastAPI(title="StudyBuddy AI Backend", version="1.0.0")

# CORS middleware for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize models and database
embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
chroma_client = chromadb.Client()

# OpenAI setup
openai.api_key = os.getenv("OPENAI_API_KEY")

# Pydantic models
class QueryRequest(BaseModel):
    question: str
    user_id: str = "default"

class QuizRequest(BaseModel):
    topic: str = ""
    user_id: str = "default"
    num_questions: int = 2

class QuizResponse(BaseModel):
    questions: List[Dict]

@app.get("/")
async def root():
    return {"message": "StudyBuddy AI Backend is running!"}

@app.post("/upload_notes")
async def upload_notes(file: UploadFile = File(...), user_id: str = "default"):
    """Upload and process PDF notes"""
    try:
        # Validate file type
        if not file.filename.endswith('.pdf'):
            raise HTTPException(status_code=400, detail="Only PDF files are supported")
        
        # Read PDF content
        contents = await file.read()
        pdf_reader = PyPDF2.PdfReader(io.BytesIO(contents))
        
        # Extract text from all pages
        text = ""
        for page in pdf_reader.pages:
            text += page.extract_text()
        
        if not text.strip():
            raise HTTPException(status_code=400, detail="No text found in PDF")
        
        # Split text into chunks (simple implementation)
        chunks = split_text_into_chunks(text, max_length=500)
        
        # Create or get collection for user
        collection_name = f"user_{user_id}_notes"
        try:
            collection = chroma_client.create_collection(name=collection_name)
        except:
            collection = chroma_client.get_collection(name=collection_name)
        
        # Generate embeddings and store
        embeddings = embedding_model.encode(chunks)
        
        # Create unique IDs for chunks
        chunk_ids = [str(uuid.uuid4()) for _ in chunks]
        
        collection.add(
            embeddings=embeddings.tolist(),
            documents=chunks,
            ids=chunk_ids,
            metadatas=[{"filename": file.filename, "chunk_index": i} for i in range(len(chunks))]
        )
        
        return {
            "message": "Notes uploaded successfully",
            "filename": file.filename,
            "chunks_processed": len(chunks)
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing file: {str(e)}")

@app.post("/ask")
async def ask_question(request: QueryRequest):
    """Ask a question based on uploaded notes"""
    try:
        collection_name = f"user_{request.user_id}_notes"
        
        try:
            collection = chroma_client.get_collection(name=collection_name)
        except:
            raise HTTPException(status_code=404, detail="No notes found. Please upload notes first.")
        
        # Generate query embedding
        query_embedding = embedding_model.encode([request.question])
        
        # Retrieve relevant chunks
        results = collection.query(
            query_embeddings=query_embedding.tolist(),
            n_results=3
        )
        
        if not results['documents'][0]:
            return {"answer": "I couldn't find relevant information in your notes to answer this question."}
        
        # Prepare context for LLM
        context = "\n\n".join(results['documents'][0])
        
        # Generate answer using OpenAI
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a helpful study assistant. Answer questions based on the provided context from the user's notes. If the context doesn't contain enough information, say so clearly."},
                {"role": "user", "content": f"Context: {context}\n\nQuestion: {request.question}"}
            ],
            max_tokens=300,
            temperature=0.7
        )
        
        answer = response.choices[0].message.content
        
        return {
            "answer": answer,
            "sources": len(results['documents'][0])
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating answer: {str(e)}")

@app.post("/generate_quiz", response_model=QuizResponse)
async def generate_quiz(request: QuizRequest):
    """Generate a quiz based on uploaded notes"""
    try:
        collection_name = f"user_{request.user_id}_notes"
        
        try:
            collection = chroma_client.get_collection(name=collection_name)
        except:
            raise HTTPException(status_code=404, detail="No notes found. Please upload notes first.")
        
        # Get random chunks for quiz generation
        all_docs = collection.get()
        if not all_docs['documents']:
            raise HTTPException(status_code=404, detail="No content available for quiz generation.")
        
        # Select relevant chunks (simplified - could use topic-based retrieval)
        selected_docs = all_docs['documents'][:5]  # Take first 5 chunks
        context = "\n\n".join(selected_docs)
        
        # Generate quiz using OpenAI
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a quiz generator. Create multiple choice questions based on the provided content. Return ONLY a valid JSON array with questions in this format: [{\"question\": \"Question text?\", \"options\": [\"A\", \"B\", \"C\", \"D\"], \"correct_answer\": \"A\"}]"},
                {"role": "user", "content": f"Generate {request.num_questions} multiple choice questions based on this content:\n\n{context}"}
            ],
            max_tokens=800,
            temperature=0.8
        )
        
        # Parse the response
        quiz_content = response.choices[0].message.content
        
        # Try to extract JSON from the response
        import json
        try:
            questions = json.loads(quiz_content)
        except:
            # Fallback if JSON parsing fails
            questions = [
                {
                    "question": "Sample question based on your notes?",
                    "options": ["Option A", "Option B", "Option C", "Option D"],
                    "correct_answer": "Option A"
                }
            ]
        
        return QuizResponse(questions=questions)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating quiz: {str(e)}")

def split_text_into_chunks(text: str, max_length: int = 500) -> List[str]:
    """Split text into manageable chunks"""
    words = text.split()
    chunks = []
    current_chunk = []
    current_length = 0
    
    for word in words:
        if current_length + len(word) + 1 <= max_length:
            current_chunk.append(word)
            current_length += len(word) + 1
        else:
            if current_chunk:
                chunks.append(" ".join(current_chunk))
            current_chunk = [word]
            current_length = len(word)
    
    if current_chunk:
        chunks.append(" ".join(current_chunk))
    
    return chunks

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
