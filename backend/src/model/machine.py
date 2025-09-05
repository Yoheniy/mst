from typing import Optional, List
from datetime import datetime, date
from sqlalchemy import Column, String, DateTime, Date, Boolean
from sqlmodel import Field, SQLModel, Relationship

# --- 2. Machine Model ---
class Machine(SQLModel, table=True):
    __tablename__ = "machines" # type: ignore

    machine_id: Optional[int] = Field(default=None, primary_key=True)
    serial_number: str = Field(sa_column=Column(String(100), nullable=False, unique=True, index=True))
    model: str = Field(sa_column=Column(String(100), nullable=False))
    brand: str = Field(sa_column=Column(String(100), nullable=False))
    type: str = Field(sa_column=Column(String(100), nullable=False))
    purchase_date: Optional[date] = Field(sa_column=Column(Date, nullable=True))
    warranty_end_date: Optional[date] = Field(sa_column=Column(Date, nullable=True))
    location: Optional[str] = Field(sa_column=Column(String(255), nullable=True))
    owner_id: int = Field(foreign_key="users.user_id", nullable=False)
    created_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow)
    )
    updated_at: datetime = Field(
        sa_column=Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    )

    # Relationships
    owner: "User" = Relationship(back_populates="machines")
    tickets: List["Ticket"] = Relationship(back_populates="machine")
    anomaly_reports: List["AnomalyReport"] = Relationship(back_populates="machine")

class MachineCreate(SQLModel):
    owner_id:int
    serial_number: str
    model: str
    brand: str
    type: str
    purchase_date: Optional[date] = None
    warranty_end_date: Optional[date] = None
    location: Optional[str] = None

# MachineRead class removed - using Machine directly instead

class MachineUpdate(SQLModel):
    serial_number: Optional[str] = None
    model: Optional[str] = None
    brand: Optional[str] = None
    type: Optional[str] = None
    purchase_date: Optional[date] = None
    warranty_end_date: Optional[date] = None
    location: Optional[str] = None
