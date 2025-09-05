# src/routes/users.py
from typing import Dict, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlmodel import Session, select
from datetime import datetime
from .utils.helpers import generate_8_digit_password
from ..model.models import (
    User, UserCreate, UserRead, UserUpdate, UserReadWithDetails, UserRole
)
from .utils.database import get_session
from .utils.auth import (
    get_password_hash, verify_password,
    get_current_user, get_current_active_admin, get_current_active_employee
)
from .utils.helpers import (
    is_password_strong_enough, validate_password_strength, generate_8_digit_password
)
from .utils.email_service import send_email

router = APIRouter(
    prefix="",
    tags=["Users"]
)

@router.get("/users/me/", response_model=UserReadWithDetails)
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.put("/users/me/", response_model=UserRead)
async def update_users_me(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    update_data = user_update.dict(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(current_user, field, value)
    
    session.add(current_user)
    session.commit()
    session.refresh(current_user)
    return current_user

@router.delete("/users/me/", status_code=status.HTTP_204_NO_CONTENT)
async def delete_users_me(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    session.delete(current_user)
    session.commit()
    return None

@router.post("/admin/users/", response_model=UserRead, status_code=status.HTTP_201_CREATED)
async def create_user_admin(
    user_create: UserCreate,
    current_admin: User = Depends(get_current_active_admin),
    session: Session = Depends(get_session)
):
    if (user_create.role==UserRole.TECHNICIAN and not user_create.employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "message": "Technician must have employee_id"
            }
        )
    
    password = generate_8_digit_password()
    to_send = {
        "subject":"Your Generated Password",
        "body":f"Your new password is: {password}"
    }
    existing_user = session.exec(select(User).where(User.email == user_create.email)).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    if not send_email(user_create.email,to_send):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "message": "Unable to register. Please make sure your email is valid."
            }
        )
    user_create.password=password
    

    hashed_password = get_password_hash(user_create.password)

    db_user = User(
        email=user_create.email,
        full_name=user_create.full_name,
        phone_number=user_create.phone_number,
        company_name=user_create.company_name,
        role=user_create.role if user_create.role else UserRole.CUSTOMER,
        employee_id=user_create.employee_id,
        password_hash=hashed_password,
        
    ) # type: ignore
    
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user

@router.get("/admin/users/", response_model=List[UserRead])
async def list_users_admin(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    role: Optional[UserRole] = Query(None),
    search: Optional[str] = Query(None),
    current_admin: User = Depends(get_current_active_admin),
    session: Session = Depends(get_session)
):
    query = select(User)
    
    if role:
        query = query.where(User.role == role)
    
    if search:
        search_filter = (
            User.email.contains(search) | # type: ignore
            User.full_name.contains(search) | # type: ignore
            User.company_name.contains(search) # type: ignore
        )
        query = query.where(search_filter)
    
    query = query.offset(skip).limit(limit)
    
    users = session.exec(query).all()
    return users

@router.get("/admin/users/{user_id}", response_model=UserRead)
async def get_user_admin(
    user_id: int,
    current_admin: User = Depends(get_current_active_admin),
    session: Session = Depends(get_session)
):
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

@router.put("/admin/users/{user_id}", response_model=UserRead)
async def update_user_admin(
    user_id: int,
    user_update: UserUpdate,
    current_admin: User = Depends(get_current_active_admin),
    session: Session = Depends(get_session)
):
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    update_data = user_update.dict(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(user, field, value)
    
    session.add(user)
    session.commit()
    session.refresh(user)
    return user

@router.delete("/admin/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user_admin(
    user_id: int,
    current_admin: User = Depends(get_current_active_admin),
    session: Session = Depends(get_session)
):
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    if user.user_id == current_admin.user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own account"
        )
    
    session.delete(user)
    session.commit()
    return None


@router.get("/users/count", response_model=Dict[str, int])
async def get_users_count(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    total_count = session.exec(select(User)).all()
    return {"total_users": len(total_count)}

@router.get("/users/roles", response_model=Dict[str, List[str]])
async def get_available_roles():
    return {"roles": [role.value for role in UserRole]}
