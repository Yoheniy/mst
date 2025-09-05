from typing import Optional, List
from datetime import datetime
from sqlalchemy import Column, String, JSON, Text, DateTime
from sqlmodel import Field, SQLModel, Relationship
from .enums import ErrorSeverity, ManufacturerOrigin

# --- 3. ErrorCode Model ---
class ErrorCode(SQLModel, table=True):
    __tablename__ = "error_codes" # type: ignore

    error_code_id: Optional[int] = Field(default=None, primary_key=True)
    related_machine_model: Optional[List[str]] = Field(sa_column=Column(JSON, nullable=True))
    code: str = Field(sa_column=Column(String(50), nullable=False, unique=True, index=True))
    title: str = Field(sa_column=Column(String(255), nullable=False))
    description: Optional[str] = Field(sa_column=Column(Text, nullable=True))
    manufacturer_origin: Optional[ManufacturerOrigin] = Field(
        sa_column=Column(String, nullable=True)
    )
    severity: Optional[ErrorSeverity] = Field(
        sa_column=Column(String, nullable=True)
    )
    suggested_action: Optional[str] = Field(sa_column=Column(Text, nullable=True))
    created_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )
    updated_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    )

    # Relationships
    kb_content: List["KnowledgeBaseContent"] = Relationship(back_populates="related_error_code")

class ErrorCodeCreate(SQLModel):
    code: str
    title: str
    related_machine_model: Optional[List[str]] = None
    description: Optional[str] = None
    manufacturer_origin: Optional[ManufacturerOrigin] = None
    severity: Optional[ErrorSeverity] = None
    suggested_action: Optional[str] = None

class ErrorCodeUpdate(SQLModel):
    code: Optional[str] = None
    related_machine_model: Optional[List[str]] = None
    title: Optional[str] = None
    description: Optional[str] = None
    manufacturer_origin: Optional[ManufacturerOrigin] = None
    severity: Optional[ErrorSeverity] = None
    suggested_action: Optional[str] = None

class ErrorCodeRead(SQLModel):
    error_code_id: int
    code: str
    title: str
    related_machine_id: Optional[List[str]] = None
    description: Optional[str] = None
    manufacturer_origin: Optional[ManufacturerOrigin] = None
    severity: Optional[ErrorSeverity] = None
    suggested_action: Optional[str] = None
    created_at: datetime
    updated_at: datetime
