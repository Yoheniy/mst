from typing import Optional, List
from datetime import datetime
from sqlalchemy import Column, String, Text, JSON, DateTime
from sqlmodel import Field, SQLModel, Relationship
from .enums import AnomalyStatus, AnomalyPriority

# --- 5. AnomalyReport Model ---
class AnomalyReport(SQLModel, table=True):
    __tablename__ = "anomaly_reports" # type: ignore

    report_id: Optional[int] = Field(default=None, primary_key=True)
    reporter_id: int = Field(foreign_key="users.user_id", nullable=False)
    machine_id: int = Field(foreign_key="machines.machine_id", nullable=False)
    report_text: str = Field(sa_column=Column(Text, nullable=False))
    media_urls: Optional[List[str]] = Field(
        default_factory=list, sa_column=Column(JSON, nullable=True)
    )
    audio_transcript: Optional[str] = Field(sa_column=Column(Text, nullable=True))
    status: AnomalyStatus = Field(
        sa_column=Column(String, nullable=False, default=AnomalyStatus.SUBMITTED)
    )
    priority: AnomalyPriority = Field(
        sa_column=Column(String, nullable=False, default=AnomalyPriority.MEDIUM)
    )
    observed_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )
    created_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )
    updated_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    )

    # Relationships
    reporter: "User" = Relationship(back_populates="anomaly_reports_submitted")
    machine: "Machine" = Relationship(back_populates="anomaly_reports")
    ticket: Optional["Ticket"] = Relationship(back_populates="related_anomaly_report")

class AnomalyReportCreate(SQLModel):
    reporter_id: int
    machine_id: int
    report_text: str
    media_urls: Optional[List[str]] = None
    report_id:int
    audio_transcript: Optional[str] = None
    status: AnomalyStatus = AnomalyStatus.SUBMITTED
    priority: AnomalyPriority = AnomalyPriority.MEDIUM
    observed_at: Optional[datetime] = None

class AnomalyReportRead(SQLModel):
    report_id: int
    reporter_id: int
    machine_id: int
    report_text: str
    media_urls: Optional[List[str]] = None
    audio_transcript: Optional[str] = None
    status: AnomalyStatus
    priority: AnomalyPriority
    observed_at: datetime
    created_at: datetime
    updated_at: datetime
