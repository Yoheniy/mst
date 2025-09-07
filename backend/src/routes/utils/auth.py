# src/routes/utils/auth.py
from datetime import datetime, timedelta
from typing import Optional, Dict, Any

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlmodel import Session, select
from dotenv import load_dotenv
import os

from ...model.models import User, UserRole
from ...routes.utils.database import get_session

# Load environment variables
load_dotenv()

SECRET_KEY = os.getenv("JWT_SECRET_KEY") or os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("JWT_ALGORITHM") or os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))

if not SECRET_KEY:
    raise ValueError("JWT_SECRET_KEY environment variable is not set.")

# Try to use bcrypt, fallback to sha256_crypt if there are compatibility issues
try:
    pwd_context = CryptContext(schemes=["bcrypt", "sha256_crypt"], deprecated="auto")
except Exception:
    # Fallback to sha256_crypt if bcrypt has issues
    pwd_context = CryptContext(schemes=["sha256_crypt"], deprecated="auto")
security = HTTPBearer()

# --- Password Hashing Functions ---
def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# --- JWT Token Functions ---
def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    # Convert user_id to string for JWT compatibility
    if "sub" in to_encode and isinstance(to_encode["sub"], int):
        to_encode["sub"] = str(to_encode["sub"])
    
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM) # type: ignore
    return encoded_jwt

# --- Dependency for Current Authenticated User ---
async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security), 
    session: Session = Depends(get_session)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM]) # type: ignore
        user_id: str = payload.get("sub") # type: ignore # 'sub' is standard for subject (user ID)
        if user_id is None:
            raise credentials_exception
        # Convert back to int for database lookup
        user_id = int(user_id) # type: ignore
    except (JWTError, ValueError):
        raise credentials_exception

    user = session.get(User, user_id)
    if user is None:
        raise credentials_exception
    return user

# --- Dependencies for Role-Based Access Control (RBAC) ---
async def get_current_active_admin(current_user: User = Depends(get_current_user)) -> User:
    # Debug: Print the actual role values for troubleshooting

    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Not enough permissions (admin role required). Your role: '{current_user.role}', Expected: '{UserRole.ADMIN.value}'"
        )
    return current_user

async def get_current_active_employee(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role == UserRole.CUSTOMER:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions (employee role required)"
        )
    return current_user