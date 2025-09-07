# src/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI,Depends
from sqlmodel import Session, select

from fastapi.middleware.cors import CORSMiddleware
from .routes.users import router as users_router
from .routes.auth import router as auth_router
from .routes.machines import router as machine_router
from .routes.employee import router as employee
from .routes.serial_number import router as serial_number
from .routes.error_code import router as error_code
from .routes.knowledge_base import router as know_base
from .routes.anamoly_report import router as anomaly_router
from .routes.utils.auth import get_current_active_admin
from .routes.chat import router as chat_router
from .routes.utils.database import get_session
from .model.models import Machine, User, Ticket, AnomalyReport, KnowledgeBaseContent, ErrorCode

# The lifespan context manager is typically used for startup/shutdown events.
# With Alembic, we do NOT call create_db_and_tables() here.
# Alembic manages the schema, so this block might be simpler or include other init tasks.
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Optional: Any other startup logic not related to DB schema creation
    print("FastAPI app starting up...")
    yield
    print("FastAPI app shutting down...")

app = FastAPI(
    title="AI Machine Tool Support Backend",
    description="API for customer support, ticketing, and AI integration.",
    version="0.1.0",
    lifespan=lifespan
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include your API routers
app.include_router(users_router)
app.include_router(auth_router)
app.include_router(machine_router)
app.include_router(serial_number)
app.include_router(employee)
app.include_router(error_code)
app.include_router(know_base)
app.include_router(chat_router)
# Anomaly reports
app.include_router(anomaly_router)
# app.include_router(chat_router)

# Example root endpoint
@app.get("/")
async def read_root():
    return {"message": "AI Machine Tool Support Backend is running!"}

@app.get('/statistics')
async def get_statistics(
    session: Session = Depends(get_session),
    admin=Depends(get_current_active_admin),
):
   total_machines = session.exec(select(Machine)).all()
   total_users = session.exec(select(User)).all()
   total_tickets = session.exec(select(Ticket)).all()
   total_anomaly_reports = session.exec(select(AnomalyReport)).all()
   total_knowledge_base_content = session.exec(select(KnowledgeBaseContent)).all()
   total_error_codes = session.exec(select(ErrorCode)).all()
   return {
    "total_machines": total_machines,
    "total_users": total_users,
    "total_tickets": total_tickets,
    "total_anomaly_reports": total_anomaly_reports,
    "total_knowledge_base_content": total_knowledge_base_content,
    "total_error_codes": total_error_codes
   }

# Health check endpoint for Render
@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "Service is running"}