from typing import Optional, List
from datetime import datetime
from sqlalchemy import Column, String, DateTime
from sqlmodel import Field, SQLModel, Relationship
from .enums import UserRole

# --- 1. User Model ---
class User(SQLModel, table=True):
    __tablename__ = "users"  # type: ignore

    user_id: Optional[int] = Field(default=None, primary_key=True)
    email: str = Field(sa_column=Column(String(255), nullable=False, unique=True, index=True))
    password_hash: str = Field(sa_column=Column(String(255), nullable=False))
    full_name: str = Field(sa_column=Column(String(255), nullable=False))
    phone_number: Optional[str] = Field(sa_column=Column(String, nullable=True))
    otp: Optional[str] = Field(sa_column=Column(String(255), nullable=True))
    company_name: Optional[str] = Field(sa_column=Column(String(255), nullable=True))
    role: UserRole = Field(
        sa_column=Column(String, nullable=False, default=UserRole.CUSTOMER)
    )
    employee_id: Optional[str] = Field(sa_column=Column(String(50), nullable=True))
    created_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )
    updated_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    )

    # Relationships
    machines: List["Machine"] = Relationship(back_populates="owner")
    tickets_created: List["Ticket"] = Relationship(
        back_populates="creator",
        sa_relationship_kwargs={"foreign_keys": "[Ticket.creator_id]"}
    )
    tickets_assigned: List["Ticket"] = Relationship(
        back_populates="assignee",
        sa_relationship_kwargs={"foreign_keys": "[Ticket.assignee_id]"}
    )
    kb_uploaded: List["KnowledgeBaseContent"] = Relationship(back_populates="uploader")
    anomaly_reports_submitted: List["AnomalyReport"] = Relationship(back_populates="reporter")
    chat_conversations: List["ChatConversation"] = Relationship(back_populates="user")

# Pydantic models for API
class UserCreate(SQLModel):
    machine_serial_number : Optional[str]=None
    email: str
    password: Optional[str]=None
    full_name: str
    phone_number: Optional[str] = None
    company_name: Optional[str] = None
    role: UserRole = UserRole.CUSTOMER
    employee_id: Optional[str] = None

class UserRead(SQLModel):
    user_id: int
    email: str
    full_name: str
    phone_number: Optional[str] = None
    company_name: Optional[str] = None
    role: UserRole
    employee_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime

class UserUpdate(SQLModel):
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    company_name: Optional[str] = None
    role: Optional[UserRole] = None
    employee_id: Optional[str] = None

# UserReadWithDetails will be defined after all models are defined
class UserReadWithDetails(UserRead):
    machines: List["Machine"] = Field(default_factory=list)
    tickets_created: List["Ticket"] = Field(default_factory=list)
