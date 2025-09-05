from typing import Optional, List
from datetime import datetime
from sqlalchemy import Column, String, Text, Boolean, Float, DateTime
from sqlmodel import Field, SQLModel, Relationship
from .enums import TicketStatus, TicketPriority

# --- 6. Ticket Model ---
class Ticket(SQLModel, table=True):
    __tablename__ = "tickets" # type: ignore

    ticket_id: Optional[int] = Field(default=None, primary_key=True)
    subject: str = Field(sa_column=Column(String(255), nullable=False))
    description: str = Field(sa_column=Column(Text, nullable=False))
    creator_id: int = Field(foreign_key="users.user_id", nullable=False)
    machine_id: Optional[int] = Field(default=None, foreign_key="machines.machine_id")
    status: TicketStatus = Field(
        sa_column=Column(String, nullable=False, default=TicketStatus.OPEN)
    )
    priority: TicketPriority = Field(
        sa_column=Column(String, nullable=False, default=TicketPriority.MEDIUM)
    )
    escalated_to_agent: bool = Field(
        sa_column=Column(Boolean, nullable=False, default=False)
    )
    ai_confidence_score: Optional[float] = Field(sa_column=Column(Float, nullable=True))
    assignee_id: Optional[int] = Field(default=None, foreign_key="users.user_id")
    related_anomaly_report_id: Optional[int] = Field(
        default=None, unique=True, foreign_key="anomaly_reports.report_id"
    )
    created_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )
    updated_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    )
    resolved_at: Optional[datetime] = Field(sa_column=Column(DateTime, nullable=True))

    # Relationships
    creator: "User" = Relationship(
        back_populates="tickets_created",
        sa_relationship_kwargs={"foreign_keys": "Ticket.creator_id"}
    )
    assignee: Optional["User"] = Relationship(
        back_populates="tickets_assigned",
        sa_relationship_kwargs={"foreign_keys": "Ticket.assignee_id"}
    )
    machine: Optional["Machine"] = Relationship(back_populates="tickets")
    related_anomaly_report: Optional["AnomalyReport"] = Relationship(back_populates="ticket")
    chat_conversations: List["ChatConversation"] = Relationship(back_populates="ticket")

class TicketCreate(SQLModel):
    subject: str
    description: str
    creator_id: int
    machine_id: Optional[int] = None
    status: TicketStatus = TicketStatus.OPEN
    priority: TicketPriority = TicketPriority.MEDIUM
    escalated_to_agent: bool = False
    ai_confidence_score: Optional[float] = None
    assignee_id: Optional[int] = None
    related_anomaly_report_id: Optional[int] = None

class TicketRead(SQLModel):
    ticket_id: int
    subject: str
    description: str
    creator_id: int
    machine_id: Optional[int] = None
    status: TicketStatus
    priority: TicketPriority
    escalated_to_agent: bool
    ai_confidence_score: Optional[float] = None
    assignee_id: Optional[int] = None
    related_anomaly_report_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime
    resolved_at: Optional[datetime] = None

class TicketUpdate(SQLModel):
    subject: Optional[str] = None
    description: Optional[str] = None
    machine_id: Optional[int] = None
    status: Optional[TicketStatus] = None
    priority: Optional[TicketPriority] = None
    escalated_to_agent: Optional[bool] = None
    ai_confidence_score: Optional[float] = None
    assignee_id: Optional[int] = None
    resolved_at: Optional[datetime] = None
