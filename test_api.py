import requests
import json

# Base URL for the API
BASE_URL = "http://localhost:8000"

def test_health_check():
    """Test the root endpoint"""
    response = requests.get(f"{BASE_URL}/")
    print("Health Check:", response.json())

def test_upload_notes():
    """Test uploading a PDF file"""
    # Note: You'll need to have a sample PDF file for this test
    # For now, this is just the structure
    files = {'file': ('sample.pdf', open('sample.pdf', 'rb'), 'application/pdf')}
    data = {'user_id': 'test_user'}
    
    response = requests.post(f"{BASE_URL}/upload_notes", files=files, data=data)
    print("Upload Notes:", response.json())

def test_ask_question():
    """Test asking a question"""
    data = {
        "question": "What are the main topics covered in the uploaded notes?",
        "user_id": "test_user"
    }
    
    response = requests.post(f"{BASE_URL}/ask", json=data)
    print("Ask Question:", response.json())

def test_generate_quiz():
    """Test quiz generation"""
    data = {
        "topic": "general",
        "user_id": "test_user",
        "num_questions": 2
    }
    
    response = requests.post(f"{BASE_URL}/generate_quiz", json=data)
    print("Generate Quiz:", response.json())

if __name__ == "__main__":
    print("Testing StudyBuddy AI API...\n")
    
    # Test health check
    try:
        test_health_check()
    except Exception as e:
        print(f"Health check failed: {e}")
    
    print("\n" + "="*50)
    print("To test upload, ask, and quiz endpoints:")
    print("1. Start the FastAPI server: python main.py")
    print("2. Have a sample PDF file named 'sample.pdf'")
    print("3. Uncomment and run the other test functions")
    print("="*50)
