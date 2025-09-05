from typing import Generator
from sqlmodel import SQLModel, Session, create_engine
from dotenv import load_dotenv
import os

# Import all models to ensure they are registered with SQLModel metadata
from src.model.models import (
    User, Machine, ErrorCode, KnowledgeBaseContent, 
    AnomalyReport, Ticket, ChatConversation,
    ChatSession, ChatMessage
)

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL is not set.")

if DATABASE_URL.startswith("postgresql://"):
    DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+psycopg://", 1)

# Updated connection with psycopg3 compatibility
engine = create_engine(
    DATABASE_URL, 
    echo=True, 
    connect_args={
        "sslmode": "require",
        # Additional connection options for better reliability
        "keepalives": 1,
        "keepalives_idle": 30,
        "keepalives_interval": 10,
        "keepalives_count": 5
    },
    pool_pre_ping=True,  # Check connection health before using
    pool_recycle=3600    # Recycle connections after 1 hour
)

def get_session() -> Generator[Session, None, None]:
    with Session(engine) as session:
        yield session

# Alembic can access this
def get_sqlmodel_metadata():
    return SQLModel.metadata

# Function to create all tables (useful for testing)
def create_db_and_tables():
    SQLModel.metadata.create_all(engine)
