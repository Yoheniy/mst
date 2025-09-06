from typing import Optional, List, Dict, Any
from datetime import datetime
from sqlalchemy import Column, String, DateTime, JSON
from sqlmodel import Field, SQLModel, Relationship
from pydantic import validator
from .enums import MessageRole

# --- Chat Models ---
class ChatSession(SQLModel, table=True):
    __tablename__ = "chat_sessions"

    session_id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.user_id", nullable=False)
    machine_id: Optional[int] = Field(foreign_key="machines.machine_id", nullable=True)
    title: Optional[str] = Field(
        sa_column=Column(String, nullable=True)
    )
    created_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )
    updated_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    )
    is_active: bool = Field(default=True)

    # Relationships
    messages: List["ChatMessage"] = Relationship(back_populates="session")

class ChatMessage(SQLModel, table=True):
    __tablename__ = "chat_messages"

    message_id: Optional[int] = Field(default=None, primary_key=True)
    session_id: int = Field(foreign_key="chat_sessions.session_id", nullable=False)
    role: MessageRole = Field(
        sa_column=Column(String, nullable=False)
    )
    content: str = Field(nullable=False)
    timestamp: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )
    # This should be message_metadata (not metadata)
    message_metadata: Optional[Dict[str, Any]] = Field(
        default=None, sa_column=Column(JSON, nullable=True)
    )

    # Relationship
    session: Optional["ChatSession"] = Relationship(back_populates="messages")

# --- Chat Pydantic Models for API ---
class MessageCreate(SQLModel):
    content: str
    role: MessageRole = MessageRole.USER

class MessageResponse(SQLModel):
    message_id: int
    session_id: int
    role: MessageRole
    content: str
    timestamp: datetime
    message_metadata: Optional[Dict[str, Any]] = None  # ← Renamed to match ChatMessage
    
    @validator('role', pre=True)
    def normalize_role(cls, v):
        if isinstance(v, str):
            # Convert uppercase to lowercase to match enum values
            v = v.lower()
        return v

class ChatSessionCreate(SQLModel):
    machine_id: Optional[int] = None
    title: Optional[str] = None

class ChatSessionResponse(SQLModel):
    session_id: int
    user_id: int
    machine_id: Optional[int] = None
    title: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    is_active: bool
    messages: List[MessageResponse] = Field(default_factory=list)

class AIChatRequest(SQLModel):
    message: str
    session_id: Optional[int] = None
    context: Optional[str] = None

class AdvancedChatRequest(SQLModel):
    """Advanced chat request with enhanced RAG features."""
    query: str = Field(description="User query for the AI assistant")
    session_id: int = Field(description="Chat session ID")
    machine_type: Optional[str] = Field(default=None, description="Filter by machine type")
    chunk_type_filter: Optional[str] = Field(
        default=None,
        description="Filter by chunk type: procedure, safety, maintenance, specification, overview"
    )
    context_limit: Optional[int] = Field(default=3, description="Maximum context chunks to use")

class AIChatResponse(SQLModel):
    response: str
    session_id: int
    message_id: int
    confidence: float
    usage: Dict[str, int]
    model: str
