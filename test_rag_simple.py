#!/usr/bin/env python3
"""
Simple RAG System Test
Tests the RAG system through API endpoints without requiring Pinecone setup
"""

import requests
import json
import time

# Configuration
BASE_URL = "http://localhost:8000"
TEST_EMAIL = "kiyabest38@gmail.com"
TEST_PASSWORD = "admin123"

def login():
    """Login and get authentication token"""
    print("🔐 Logging in...")
    login_data = {
        "username": TEST_EMAIL,  # OAuth2PasswordRequestForm uses 'username' field
        "password": TEST_PASSWORD
    }
    
    try:
        response = requests.post(f"{BASE_URL}/login", data=login_data)  # Use data instead of json
        if response.status_code == 200:
            data = response.json()
            token = data["access_token"]
            print(f"✅ Login successful - User: {data['user']['full_name']}")
            return token
        else:
            print(f"❌ Login failed: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Login error: {str(e)}")
        return None

def test_knowledge_base_stats(token):
    """Test knowledge base statistics"""
    print("\n📊 Getting knowledge base stats...")
    
    try:
        response = requests.get(
            f"{BASE_URL}/knowledge-base/stats/summary",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if response.status_code == 200:
            stats = response.json()
            print(f"✅ Knowledge Base Stats:")
            for key, value in stats.items():
                print(f"   {key}: {value}")
            return True
        else:
            print(f"❌ Knowledge base stats failed: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Knowledge base stats error: {str(e)}")
        return False

def upload_text_document(token):
    """Upload a text document to test RAG processing"""
    print("\n📄 Uploading text document for RAG testing...")
    
    # Create test content
    test_content = {
        "title": "CNC Machine Safety Guide - RAG Test",
        "content_type": "faq",  # Use FAQ type since we don't have a file
        "content_text": """
# CNC Machine Safety Guide

## Critical Safety Rules
1. Always wear safety glasses and protective equipment
2. Ensure the work area is clean and well-lit
3. Never operate the machine while under the influence
4. Keep emergency stop button accessible at all times

## Machine Startup Procedure
1. Check that all safety guards are properly positioned
2. Verify the emergency stop button is not engaged
3. Turn on the main power switch
4. Wait for the system to complete initialization
5. Perform a test run with no material

## Tool Change Process
1. Stop the spindle completely
2. Press the tool change button
3. Remove the current tool carefully
4. Insert the new tool with proper alignment
5. Tighten the collet securely
6. Test the tool before starting production

## Troubleshooting Common Issues
- **Spindle won't start**: Check emergency stop, verify power supply, check safety interlocks
- **Tool slipping**: Check collet tightness, inspect tool condition, verify proper tool size
- **Poor surface finish**: Check tool sharpness, adjust cutting speed, verify feed rate settings
- **Machine vibration**: Check tool balance, verify work piece clamping, inspect machine leveling

## Maintenance Schedule
- **Daily**: Clean machine surfaces, check coolant levels, inspect safety guards
- **Weekly**: Lubricate moving parts, check belt tension, inspect electrical connections
- **Monthly**: Calibrate sensors, inspect spindle bearings, check hydraulic systems
        """,
        "tags": ["cnc", "safety", "manual", "rag-test"],
        "applies_to_models": ["CNC-3000", "CNC-5000", "CNC-7000"],
        "uploader_id": 12
    }
    
    try:
        # Use form data as expected by the endpoint
        form_data = {
            'content': json.dumps(test_content)
        }
        
        response = requests.post(
            f"{BASE_URL}/knowledge-base/",
            data=form_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if response.status_code == 201:
            kb_data = response.json()
            print(f"✅ Text document uploaded successfully!")
            print(f"   KB ID: {kb_data.get('kb_id')}")
            print(f"   Title: {kb_data.get('title')}")
            print(f"   Content Type: {kb_data.get('content_type')}")
            return kb_data.get('kb_id')
        else:
            print(f"❌ Text document upload failed: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Text document upload error: {str(e)}")
        return None

def test_knowledge_base_query(token):
    """Test knowledge base query functionality"""
    print("\n🔍 Testing knowledge base query...")
    
    try:
        # Test searching the knowledge base
        response = requests.get(
            f"{BASE_URL}/knowledge-base/?search=CNC&limit=5",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if response.status_code == 200:
            results = response.json()
            print(f"✅ Knowledge base query successful")
            print(f"   Results: {len(results)} documents found")
            
            for i, result in enumerate(results[:2]):
                print(f"     {i+1}. Title: {result.get('title', 'N/A')}")
                print(f"        Content Type: {result.get('content_type', 'N/A')}")
                print(f"        Content: {result.get('content_text', 'N/A')[:100]}...")
        else:
            print(f"   ❌ Query failed: {response.status_code} - {response.text}")
            
    except Exception as e:
        print(f"   ❌ Query error: {str(e)}")

def test_chat_with_rag(token):
    """Test chat functionality with RAG"""
    print("\n💬 Testing chat with RAG...")
    
    try:
        # Create a chat session
        session_data = {"title": "RAG Test Session"}
        response = requests.post(
            f"{BASE_URL}/chat/sessions/",
            json=session_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if response.status_code != 201:
            print(f"❌ Failed to create chat session: {response.status_code} - {response.text}")
            return False
        
        session_id = response.json()["session_id"]
        print(f"✅ Chat session created: {session_id}")
        
        # Test AI chat with RAG
        chat_data = {
            "message": "What are the safety rules for operating a CNC machine?",
            "session_id": session_id
        }
        
        response = requests.post(
            f"{BASE_URL}/chat/ai/chat",
            json=chat_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if response.status_code == 200:
            chat_response = response.json()
            print(f"✅ Chat with RAG successful")
            print(f"   AI Response: {chat_response.get('ai_message', 'N/A')[:300]}...")
            return True
        else:
            print(f"❌ Chat with RAG failed: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Chat with RAG error: {str(e)}")
        return False

def main():
    """Run the RAG test"""
    print("🚀 Starting Knowledge Base and RAG System Test")
    print("=" * 50)
    
    # Step 1: Login
    token = login()
    if not token:
        print("❌ Cannot proceed without authentication")
        return
    
    # Step 2: Get initial stats
    test_knowledge_base_stats(token)
    
    # Step 3: Upload test document
    kb_id = upload_text_document(token)
    if not kb_id:
        print("❌ Cannot proceed without test document")
        return
    
    # Step 4: Wait for processing
    print("\n⏳ Waiting 10 seconds for background processing...")
    time.sleep(10)
    
    # Step 5: Check stats after upload
    print("\n📊 Checking stats after document upload...")
    test_knowledge_base_stats(token)
    
    # Step 6: Test knowledge base query
    test_knowledge_base_query(token)
    
    # Step 7: Test chat with RAG
    test_chat_with_rag(token)
    
    print("\n" + "=" * 50)
    print("🎉 Knowledge Base and RAG System Test Complete!")
    print("\nTo verify RAG functionality:")
    print("1. Check if the document was uploaded successfully")
    print("2. Verify the chat system can access the knowledge base")
    print("3. Test with different queries to see if RAG is working")
    print("\nNote: RAG endpoints may not be fully configured yet.")
    print("The system is testing knowledge base upload and chat integration.")

if __name__ == "__main__":
    main()
