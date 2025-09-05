from typing import Optional, List
from datetime import datetime
from sqlalchemy import Column, String, Text, JSON, DateTime
from sqlmodel import Field, SQLModel, Relationship
from .enums import ContentType

# --- 4. KnowledgeBaseContent Model ---
class KnowledgeBaseContent(SQLModel, table=True):
    __tablename__ = "knowledge_base_contents" # type: ignore

    kb_id: Optional[int] = Field(default=None, primary_key=True)
    title: str = Field(sa_column=Column(String(255), nullable=False))
    content_type: ContentType = Field(
        sa_column=Column(String, nullable=False)
    )
    content_text: Optional[str] = Field(sa_column=Column(Text, nullable=True))
    external_url: Optional[str] = Field(sa_column=Column(String(500), nullable=True))
    tags: Optional[List[str]] = Field(
        default_factory=list, sa_column=Column(JSON, nullable=True)
    )
    applies_to_models: Optional[List[str]] = Field(
        default_factory=list, sa_column=Column(JSON, nullable=True)
    )
    uploader_id: int = Field(foreign_key="users.user_id", nullable=False)
    related_error_code_id: Optional[int] = Field(
        default=None, foreign_key="error_codes.error_code_id"
    )
    created_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )
    updated_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    )

    # Relationships
    uploader: "User" = Relationship(back_populates="kb_uploaded")
    related_error_code: Optional["ErrorCode"] = Relationship(back_populates="kb_content")

class KnowledgeBaseContentCreate(SQLModel):
    title: str
    content_type: ContentType
    content_text: Optional[str] = None
    external_url: Optional[str] = None
    tags: Optional[List[str]] = None
    applies_to_models: Optional[List[str]] = None
    uploader_id: int
    related_error_code_id: Optional[int] = None

class KnowledgeBaseContentRead(SQLModel):
    kb_id: int
    title: str
    content_type: ContentType
    content_text: Optional[str] = None
    external_url: Optional[str] = None
    tags: Optional[List[str]] = None
    applies_to_models: Optional[List[str]] = None
    uploader_id: int
    related_error_code_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime
