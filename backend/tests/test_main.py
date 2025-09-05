"""
Tests for the main FastAPI application.
"""
import pytest
from fastapi.testclient import TestClient


class TestMainApp:
    """Test cases for the main application endpoints."""
    
    def test_read_root(self, client):
        """Test the root endpoint."""
        response = client.get("/")
        assert response.status_code == 200
        assert response.json() == {
            "message": "AI Machine Tool Support Backend is running!"
        }
    
    def test_health_check(self, client):
        """Test the health check endpoint."""
        response = client.get("/health")
        assert response.status_code == 200
        assert "status" in response.json()
    
    def test_openapi_docs(self, client):
        """Test that OpenAPI documentation is accessible."""
        response = client.get("/docs")
        assert response.status_code == 200
    
    def test_openapi_json(self, client):
        """Test that OpenAPI JSON schema is accessible."""
        response = client.get("/openapi.json")
        assert response.status_code == 200
        assert "openapi" in response.json()
