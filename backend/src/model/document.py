from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field

class Document(SQLModel, table=True):
    """Model for storing knowledge base documents"""
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str = Field(index=True)
    content: str
    document_type: str = Field(index=True)  # "manual", "faq", "troubleshooting", "training"
    machine_type: Optional[str] = Field(default=None, index=True)
    file_path: Optional[str] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class DocumentCreate(SQLModel):
    """Schema for creating a new document"""
    title: str
    content: str
    document_type: str
    machine_type: Optional[str] = None
    file_path: Optional[str] = None

class DocumentResponse(SQLModel):
    """Schema for document response"""
    id: int
    title: str
    content: str
    document_type: str
    machine_type: Optional[str] = None
    file_path: Optional[str] = None
    created_at: datetime
    updated_at: datetime

class DocumentUpdate(SQLModel):
    """Schema for updating a document"""
    title: Optional[str] = None
    content: Optional[str] = None
    document_type: Optional[str] = None
    machine_type: Optional[str] = None
    file_path: Optional[str] = None
