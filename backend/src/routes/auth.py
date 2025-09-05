# src/routes/auth.py
from typing import Dict, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status, Request
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, select
from datetime import timedelta, datetime
from ..model.models import MachineModel, Employee
from ..model.models import User, UserCreate, UserRead, UserRole
from src.routes.utils.database import get_session
from src.routes.utils.auth import (
    get_password_hash, verify_password, create_access_token,
    get_current_user, ACCESS_TOKEN_EXPIRE_MINUTES
)
from .utils.email_service import send_email
from src.routes.utils.helpers import (
    generate_8_digit_password, is_ip_locked, record_failed_login, record_successful_login,
    get_remaining_attempts, get_lockout_time_remaining,
    validate_password_strength, is_password_strong_enough,
    get_password_recommendations, calculate_password_score,generate_4_digit_code
    
)

router = APIRouter(
    prefix="",
    tags=["Authentication"]
)

@router.post("/register/", response_model=UserRead, status_code=status.HTTP_201_CREATED)
async def register_user(user_create: UserCreate, session: Session = Depends(get_session)):
    existing_user = session.exec(select(User).where(User.email == user_create.email)).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    if not is_password_strong_enough(user_create.password):
        validation = validate_password_strength(user_create.password)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "message": "Password does not meet security requirements",
                "requirements": validation,
                "missing": [k for k, v in validation.items() if not v and k != "strong"]
            }
        )

    if user_create.role==UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You can't create admin user type"
        )
    if not user_create.machine_serial_number:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You need to have atleast one machine bought. machine serial number could'nt null"
        )
    
    serial_number = session.exec(select(MachineModel).where(MachineModel.serial_number == user_create.machine_serial_number)).first()
    
    if not serial_number:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid Serial Number - Machine not found"
        )
    
    if serial_number.owned:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid Serial Number - Machine already owned"
        )
    
    if user_create.employee_id and user_create.role==UserRole.TECHNICIAN:
        employee = session.exec(select(Employee).where(Employee.employee_id == user_create.employee_id)).first()
        if not employee:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid employee id id"
            )


    hashed_password = get_password_hash(user_create.password) # type: ignore

    db_user = User(
        email=user_create.email,
        full_name=user_create.full_name,
        phone_number=user_create.phone_number,
        company_name=user_create.company_name,
        role=user_create.role if user_create.role else UserRole.CUSTOMER,
        employee_id=user_create.employee_id,
        password_hash=hashed_password,
        
    ) # type: ignore
    serial_number.owned=True
    session.add(db_user)
    session.commit()
    session.add(serial_number)
    session.commit()
    session.refresh(db_user)
    return db_user

@router.post("/login")
async def login_user(
    request: Request,
    form_data: OAuth2PasswordRequestForm = Depends(),
    session: Session = Depends(get_session)
):
    client_ip = request.client.host # type: ignore
    
    if is_ip_locked(client_ip):
        lockout_remaining = get_lockout_time_remaining(client_ip)
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail={
                "message": "Too many failed login attempts. Account temporarily locked.",
                "lockout_remaining_seconds": lockout_remaining,
                "lockout_remaining_minutes": max(1, lockout_remaining // 60) # type: ignore
            }
        )
    
    if not form_data.username or not form_data.password:
        record_failed_login(client_ip)
        remaining_attempts = get_remaining_attempts(client_ip)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "message": "Email and password are required",
                "remaining_attempts": remaining_attempts
            }
        )
    
    user = session.exec(select(User).where(User.email == form_data.username)).first()
    
    if not user or not verify_password(form_data.password, user.password_hash):
        record_failed_login(client_ip)
        remaining_attempts = get_remaining_attempts(client_ip)
        
        if remaining_attempts == 0:
            lockout_remaining = get_lockout_time_remaining(client_ip)
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail={
                    "message": "Too many failed login attempts. Account temporarily locked.",
                    "lockout_remaining_seconds": lockout_remaining,
                    "lockout_remaining_minutes": max(1, lockout_remaining // 60) # type: ignore
                }
            )
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "message": "Incorrect email or password",
                    "remaining_attempts": remaining_attempts
                },
                headers={"WWW-Authenticate": "Bearer"},
            )
    
    record_successful_login(client_ip)
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.user_id, "role": user.role}, 
        expires_delta=access_token_expires
    )
    
    user.updated_at = datetime.utcnow()
    session.add(user)
    session.commit()
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        "user": {
            "user_id": user.user_id,
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role,
            "company_name": user.company_name
        }
    }

@router.post("/token", response_model=Dict[str, str])
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), 
    session: Session = Depends(get_session)
):
    user = session.exec(select(User).where(User.email == form_data.username)).first()
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.user_id, "role": user.role}, 
        expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/logout")
async def logout_user():
    return {
        "message": "Successfully logged out",
        "note": "Please discard your access token on the client side"
    }

@router.post("/refresh-token", response_model=Dict[str, str])
async def refresh_access_token(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": current_user.user_id, "role": current_user.role}, 
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60
    }

@router.post("/validate-password")
async def validate_password_endpoint(password: str):
    validation = validate_password_strength(password)
    recommendations = get_password_recommendations(password)
    score = calculate_password_score(password)
    
    return {
        "password": password,
        "validation": validation,
        "is_strong": validation["strong"],
        "score": score,
        "recommendations": recommendations
    }

@router.post("/change-password")
async def change_password(
    new_password: str,
    current_password: Optional[str]=None,
    otp: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    if current_password:
        if not verify_password(current_password, current_user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Current password is incorrect"
            )
        
        if not is_password_strong_enough(new_password):
            validation = validate_password_strength(new_password)
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "message": "New password does not meet security requirements",
                    "requirements": validation
                }
            )
    else:
        user_otp = current_user.otp

        if not verify_password(otp,user_otp):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "message": "Invalid OTP"
                }
            )

    
    new_hashed_password = get_password_hash(new_password)
    current_user.password_hash = new_hashed_password
    current_user.updated_at = datetime.utcnow()
    
    session.add(current_user)
    session.commit()
    
    return {"message": "Password changed successfully"}

@router.get("/login-status")
async def get_login_status(request: Request):
    client_ip = request.client.host # type: ignore
    
    if is_ip_locked(client_ip):
        lockout_remaining = get_lockout_time_remaining(client_ip)
        return {
            "ip": client_ip,
            "status": "locked",
            "lockout_remaining_seconds": lockout_remaining,
            "lockout_remaining_minutes": max(1, lockout_remaining // 60) # type: ignore
        }
    
    remaining_attempts = get_remaining_attempts(client_ip)
    return {
        "ip": client_ip,
        "status": "active",
        "remaining_attempts": remaining_attempts
    }



@router.post("/reset-password")
async def forgot_password(
    email: str,
    session: Session = Depends(get_session)
):


    user = session.exec(select(User).where(User.email == email)).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User with this email does not exist"
        )
    otp = generate_4_digit_code()
    user.otp = get_password_hash(otp)
    session.add(user)
    session.commit()

    subject = "Your Password Reset"
    body = f"Your new OTP code is: {otp}"
    email_sent = send_email(user.email, {"subject": subject, "body": body})
    if not email_sent:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to send password reset email"
        )
    return {"message": "Password reset email sent successfully"}

@router.post("/change-password-public")
async def change_password_public(
    email: str,
    otp: str,
    new_password: str,
    session: Session = Depends(get_session)
):

    user = session.exec(select(User).where(User.email == email)).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User with this email does not exist"
        )

    if not user.otp or not verify_password(otp, user.otp):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid OTP"
        )

    if not is_password_strong_enough(new_password):
        validation = validate_password_strength(new_password)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "message": "New password does not meet security requirements",
                "requirements": validation
            }
        )

    new_hashed_password = get_password_hash(new_password)
    user.password_hash = new_hashed_password
    user.otp = None  # Clear the OTP after use
    user.updated_at = datetime.utcnow()
    
    session.add(user)
    session.commit()
    
    return {"message": "Password changed successfully"}

@router.get("/machines/list")
def list_machines(session: Session = Depends(get_session)):
    """List all machines in the database for debugging"""
    machines = session.exec(select(MachineModel)).all()
    return {
        "machines": [
            {
                "serial_number": m.serial_number,
                "owned": m.owned
            } for m in machines
        ]
    }

@router.post("/admin/create")
def create_admin_account(session: Session = Depends(get_session)):
    hashed_password = get_password_hash("admin123") # type: ignore
    admin = User(
        email="kiyabest38@gmail.com",
        full_name="Admin Test",
        role=UserRole.ADMIN,
        password_hash=hashed_password,  
    )
    session.add(admin)
    session.commit()
    session.refresh(admin)
    return admin