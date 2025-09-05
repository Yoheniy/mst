from typing import Optional, List, Dict, Any
from datetime import datetime
from sqlalchemy import Column, DateTime, JSON, Text, Boolean
from sqlmodel import Field, SQLModel, Relationship

# --- 7. ChatConversation Model ---
class ChatConversation(SQLModel, table=True):
    __tablename__ = "chat_conversations" # type: ignore

    chat_id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.user_id", nullable=False)
    ticket_id: Optional[int] = Field(default=None, foreign_key="tickets.ticket_id")
    start_time: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )
    end_time: Optional[datetime] = Field(sa_column=Column(DateTime, nullable=True))
    transcript: List[Dict[str, Any]] = Field(
        default_factory=list, sa_column=Column(JSON, nullable=True)
    )
    final_resolution: Optional[str] = Field(sa_column=Column(Text, nullable=True))
    was_escalated: bool = Field(
        sa_column=Column(Boolean, nullable=False, default=False)
    )
    created_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )

    # Relationships
    user: "User" = Relationship(back_populates="chat_conversations")
    ticket: Optional["Ticket"] = Relationship(back_populates="chat_conversations")

class ChatConversationCreate(SQLModel):
    user_id: int
    ticket_id: Optional[int] = None
    start_time: Optional[datetime] = None
    transcript: Optional[List[Dict[str, Any]]] = None
    final_resolution: Optional[str] = None
    was_escalated: bool = False

class ChatConversationRead(SQLModel):
    chat_id: int
    user_id: int
    ticket_id: Optional[int] = None
    start_time: datetime
    end_time: Optional[datetime] = None
    transcript: Optional[List[Dict[str, Any]]] = None
    final_resolution: Optional[str] = None
    was_escalated: bool
    created_at: datetime

class ChatConversationUpdate(SQLModel):
    end_time: Optional[datetime] = None
    transcript: Optional[List[Dict[str, Any]]] = None
    final_resolution: Optional[str] = None
    was_escalated: Optional[bool] = None
