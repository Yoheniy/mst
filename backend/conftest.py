"""
Pytest configuration and fixtures for the manufacturing support backend.
"""
import asyncio
import os
import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from src.main import app
from src.model.models import SQLModel
from src.routes.utils.database import get_session

# Test database URL
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

# Create test engine
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="function")
def db_session():
    """Create a fresh database session for each test."""
    # Create tables
    SQLModel.metadata.create_all(bind=engine)
    
    # Create session
    session = TestingSessionLocal()
    
    try:
        yield session
    finally:
        session.close()
        # Drop tables after test
        SQLModel.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(db_session):
    """Create a test client with database dependency override."""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    
    app.dependency_overrides[get_session] = override_get_db
    
    with TestClient(app) as test_client:
        yield test_client
    
    app.dependency_overrides.clear()


@pytest.fixture(scope="function")
def test_user_data():
    """Sample user data for testing."""
    return {
        "email": "test@example.com",
        "password": "testpassword123",
        "first_name": "Test",
        "last_name": "User",
        "role": "customer"
    }


@pytest.fixture(scope="function")
def test_machine_data():
    """Sample machine data for testing."""
    return {
        "model": "Test Machine Model",
        "serial_number": "TEST123456",
        "manufacturer": "Test Manufacturer",
        "purchase_date": "2023-01-01",
        "warranty_expiry": "2024-01-01"
    }


@pytest.fixture(scope="function")
def test_error_code_data():
    """Sample error code data for testing."""
    return {
        "code": "E001",
        "description": "Test error description",
        "severity": "high",
        "manufacturer_origin": "Test Manufacturer",
        "solution": "Test solution"
    }


@pytest.fixture(scope="function")
def test_knowledge_base_data():
    """Sample knowledge base data for testing. this is used to test the knowledge base routes"""


    return {
        "title": "Test Knowledge Base Article",
        "content": "This is test content for knowledge base",
        "content_type": "troubleshooting",
        "tags": ["test", "troubleshooting"],
        "is_public": True
    }


@pytest.fixture(scope="funkction")
def auth_headers(client, test_user_data):
    """Create authentication headers for testing."""
    # Create user
    response = client.post("/auth/register", json=test_user_data)
    assert response.status_code == 201
    
    # Login
    login_data = {
        "username": test_user_data["email"],
        "password": test_user_data["password"]
    }
    response = client.post("/auth/login", data=login_data)
    assert response.status_code == 200
    
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture(autouse=True)
def setup_test_env():
    """Set up test environment variables."""
    os.environ.update({
        "DATABASE_URL": SQLALCHEMY_DATABASE_URL,
        "JWT_SECRET_KEY": "test-secret-key",
        "JWT_ALGORITHM": "HS256",
        "ACCESS_TOKEN_EXPIRE_MINUTES": "30",
        "CLOUDINARY_CLOUD_NAME": "test-cloud",
        "CLOUDINARY_API_KEY": "test-api-key",
        "CLOUDINARY_API_SECRET": "test-api-secret",
        "DEBUG": "True",
        "ENVIRONMENT": "test"
    })
    yield
    # Cleanup after test
    for key in [
        "DATABASE_URL", "JWT_SECRET_KEY", "JWT_ALGORITHM",
        "ACCESS_TOKEN_EXPIRE_MINUTES", "CLOUDINARY_CLOUD_NAME",
        "CLOUDINARY_API_KEY", "CLOUDINARY_API_SECRET",
        "DEBUG", "ENVIRONMENT"
    ]:
        os.environ.pop(key, None)
