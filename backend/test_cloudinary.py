#!/usr/bin/env python3
"""
Test script to verify Cloudinary connection
"""
import os
from dotenv import load_dotenv
import cloudinary
import cloudinary.api

# Load environment variables
load_dotenv()

def test_cloudinary_connection():
    """Test if Cloudinary is properly configured"""
    try:
        # Configure Cloudinary
        cloudinary.config(
            cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
            api_key=os.getenv("CLOUDINARY_API_KEY"),
            api_secret=os.getenv("CLOUDINARY_API_SECRET")
        )
        
        # Test connection by getting account info
        account_info = cloudinary.api.ping()
        
        if account_info.get("status") == "ok":
            print("✅ Cloudinary connection successful!")
            print(f"   Cloud Name: {os.getenv('CLOUDINARY_CLOUD_NAME')}")
            print(f"   API Key: {os.getenv('CLOUDINARY_API_KEY')[:8]}...")
            print(f"   API Secret: {os.getenv('CLOUDINARY_API_SECRET')[:8]}...")
            return True
        else:
            print("❌ Cloudinary connection failed!")
            return False
            
    except Exception as e:
        print(f"❌ Error connecting to Cloudinary: {str(e)}")
        return False

def check_env_variables():
    """Check if all required environment variables are set"""
    required_vars = [
        "CLOUDINARY_CLOUD_NAME",
        "CLOUDINARY_API_KEY", 
        "CLOUDINARY_API_SECRET"
    ]
    
    missing_vars = []
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        print(f"❌ Missing environment variables: {', '.join(missing_vars)}")
        print("   Please create a .env file with your Cloudinary credentials")
        return False
    else:
        print("✅ All required environment variables are set")
        return True

if __name__ == "__main__":
    print("🔍 Testing Cloudinary Connection...")
    print("=" * 40)
    
    # Check environment variables first
    if check_env_variables():
        # Test connection
        test_cloudinary_connection()
    else:
        print("\n📝 To fix this:")
        print("1. Sign up at cloudinary.com")
        print("2. Get your credentials from Dashboard")
        print("3. Create a .env file with:")
        print("   CLOUDINARY_CLOUD_NAME=your_cloud_name")
        print("   CLOUDINARY_API_KEY=your_api_key")
        print("   CLOUDINARY_API_SECRET=your_api_secret")
