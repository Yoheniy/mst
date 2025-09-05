# src/routes/machines.py
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlmodel import Session, select
from datetime import datetime

from ..model.models import (
    Machine, MachineCreate, MachineUpdate, User, UserRole, MachineModel
)
from src.routes.utils.database import get_session
from src.routes.utils.auth import (
    get_current_user, get_current_active_admin, get_current_active_employee
)
from src.routes.utils.helpers import sanitize_string

router = APIRouter(
    prefix="/machines",
    tags=["Machines"]
)

# ============================================================================
# PUBLIC ENDPOINTS (for authenticated users)
# ============================================================================

@router.get("/", response_model=List[Machine])
async def list_machines(
    skip: int = Query(0, ge=0, description="Number of machines to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of machines to return"),
    search: Optional[str] = Query(None, description="Search in serial_number, model, or type"),
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    """List machines with pagination and search (authenticated users only)"""
    query = select(Machine)
    
    # Apply search filter
    if search:
        search_term = sanitize_string(search)
        search_filter = (
            Machine.serial_number.contains(search_term) | # type: ignore
            Machine.model.contains(search_term) | # type: ignore
            Machine.type.contains(search_term) # type: ignore
        )
        query = query.where(search_filter)
    
    # Apply pagination
    query = query.offset(skip).limit(limit)
    
    machines = session.exec(query).all()
    return machines

@router.get("/my-machines", response_model=List[Machine])
async def list_my_machines(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    search: Optional[str] = Query(None),
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    """List current user's machines"""
    query = select(Machine).where(Machine.owner_id == current_user.user_id)
    
    if search:
        search_term = sanitize_string(search)
        search_filter = (
            Machine.serial_number.contains(search_term) | # type: ignore
            Machine.model.contains(search_term) | # type: ignore
            Machine.type.contains(search_term) # type: ignore
        )
        query = query.where(search_filter)
    
    query = query.offset(skip).limit(limit)
    
    machines = session.exec(query).all()
    return machines

@router.get("/{machine_id}", response_model=Machine)
async def get_machine(
    machine_id: int,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    """Get a specific machine by ID (owner or admin/employee only)"""
    machine = session.get(Machine, machine_id)
    if not machine:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Machine not found"
        )
    
    # Check if user has access to this machine
    if (current_user.role == UserRole.CUSTOMER and 
        machine.owner_id != current_user.user_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. You can only view your own machines."
        )
    
    return machine

@router.post("/", response_model=Machine, status_code=status.HTTP_201_CREATED)
async def create_machine(
    machine_create: MachineCreate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    # Check if serial number already exists
    existing_machine = session.exec(
        select(Machine).where(Machine.serial_number == machine_create.serial_number)
    ).first()
    if existing_machine:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Machine with this serial number already exists"
        )
    

    # Create machine
    if current_user.user_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current user does not have a valid user_id"
        )
    machine_model = session.exec(select(MachineModel).where(MachineModel.serial_number==machine_create.serial_number)).first()
    if not machine_model or machine_model.owned:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "msg":"Invalid Serial number"
            }
        )
    db_machine = Machine(
        serial_number=machine_create.serial_number,
        model=machine_create.model,
        type=machine_create.type,
        purchase_date=machine_create.purchase_date,
        warranty_end_date=machine_create.warranty_end_date,
        location=machine_create.location,
        owner_id=current_user.user_id,
        created_at= datetime.now(),
        updated_at=datetime.now()
    )
    
    session.add(db_machine)
    machine_model.owned=True
    session.commit()
    session.refresh(db_machine)
    machine_model.owned=True
    session.add(machine_model)
    session.commit()
    return db_machine

@router.put("/{machine_id}", response_model=Machine)
async def update_machine(
    machine_id: int,
    machine_update: MachineUpdate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    """Update a machine (owner or admin/employee only)"""
    machine = session.get(Machine, machine_id)
    if not machine:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Machine not found"
        )
    
    # Check if user has permission to update this machine
    if (current_user.role == UserRole.CUSTOMER and 
        machine.owner_id != current_user.user_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. You can only update your own machines."
        )
    
    # Check if serial number is being changed and if it already exists
    if (machine_update.serial_number and 
        machine_update.serial_number != machine.serial_number):
        existing_machine = session.exec(
            select(Machine).where(Machine.serial_number == machine_update.serial_number)
        ).first()
        if existing_machine:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Machine with this serial number already exists"
            )
    
    # Update only provided fields
    update_data = machine_update.dict(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(machine, field, value)
    
    machine.updated_at = datetime.utcnow()
    session.add(machine)
    session.commit()
    session.refresh(machine)

    return machine

@router.delete("/{machine_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_machine(
    machine_id: int,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    """Delete a machine (owner or admin only)"""
    machine = session.get(Machine, machine_id)
    if not machine:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Machine not found"
        )
    
    # Check if user has permission to delete this machine
    if (current_user.role == UserRole.CUSTOMER and 
        machine.owner_id != current_user.user_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. You can only delete your own machines."
        )
    
    session.delete(machine)
    session.commit()
    return None

# ============================================================================
# ADMIN ENDPOINTS
# ============================================================================

@router.get("/admin/all", response_model=List[Machine])
async def list_all_machines_admin(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    search: Optional[str] = Query(None),
    owner_id: Optional[int] = Query(None, description="Filter by owner ID"),
    current_admin: User = Depends(get_current_active_admin),
    session: Session = Depends(get_session)
):
    """List all machines with advanced filtering (admin only)"""
    query = select(Machine)
    
    # Apply owner filter
    if owner_id:
        query = query.where(Machine.owner_id == owner_id)
    
    # Apply search filter
    if search:
        search_term = sanitize_string(search)
        search_filter = (
            Machine.serial_number.contains(search_term) | # type: ignore
            Machine.model.contains(search_term) | # type: ignore
            Machine.type.contains(search_term) # type: ignore
        )
        query = query.where(search_filter)
    
    # Apply pagination
    query = query.offset(skip).limit(limit)
    
    machines = session.exec(query).all()
    return machines

@router.get("/admin/statistics", response_model=dict)
async def get_machines_statistics(
    current_admin: User = Depends(get_current_active_admin),
    session: Session = Depends(get_session)
):
    """Get machines statistics (admin only)"""
    total_machines = session.exec(select(Machine)).all()
    
    # Count by type
    type_counts = {}
    for machine in total_machines:
        type_counts[machine.type] = type_counts.get(machine.type, 0) + 1
    
    # Count by warranty status
    from datetime import date
    today = date.today()
    under_warranty = 0
    warranty_expired = 0
    no_warranty_info = 0
    
    for machine in total_machines:
        if machine.warranty_end_date:
            if machine.warranty_end_date > today:
                under_warranty += 1
            else:
                warranty_expired += 1
        else:
            no_warranty_info += 1
    
    return {
        "total_machines": len(total_machines),
        "by_type": type_counts,
        "warranty_status": {
            "under_warranty": under_warranty,
            "warranty_expired": warranty_expired,
            "no_warranty_info": no_warranty_info
        }
    }


@router.get("/employee/{machine_id}", response_model=Machine)
async def get_machine_employee(
    machine_id: int,
    current_employee: User = Depends(get_current_active_employee),
    session: Session = Depends(get_session)
):
    """Get machine details (employees only - read-only access)"""
    machine = session.get(Machine, machine_id)
    if not machine:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Machine not found"
        )
    return machine

