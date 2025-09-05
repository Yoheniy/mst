from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from typing import List
from datetime import datetime

from .utils.database import get_session
from ..model.models import ErrorCode, ErrorCodeCreate, ErrorCodeRead, ErrorCodeUpdate
from .utils.auth import get_current_user,get_current_active_admin

router = APIRouter(prefix="/error-codes", tags=["Error Codes"])

# Create Error Code
@router.post("/", response_model=ErrorCodeRead, status_code=status.HTTP_201_CREATED)
async def create_error_code(
    error_code: ErrorCodeCreate,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_active_admin)
):

    try:
        # Check if error code already exists
        existing_code = session.exec(
            select(ErrorCode).where(ErrorCode.code == error_code.code)
        ).first()
        
        if existing_code:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Error code '{error_code.code}' already exists"
            )
        
        # Create new error code
        db_error_code = ErrorCode(
            code=error_code.code,
            title=error_code.title,
            description=error_code.description,
            manufacturer_origin=error_code.manufacturer_origin,
            severity=error_code.severity,
            suggested_action=error_code.suggested_action,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        session.add(db_error_code)
        session.commit()
        session.refresh(db_error_code)
        return db_error_code
    except Exception as e:
        session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create error code: {str(e)}"
        )

# Get All Error Codes
@router.get("/", response_model=List[ErrorCodeRead])
async def get_error_codes(
    skip: int = 0,
    limit: int = 100,
    manufacturer_origin: str = None,
    severity: str = None,
    search: str = None,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
    
    try:
        query = select(ErrorCode)
        
        # Apply filters
        if manufacturer_origin:
            query = query.where(ErrorCode.manufacturer_origin == manufacturer_origin)
        
        if severity:
            query = query.where(ErrorCode.severity == severity)
        
        if search:
            search_filter = (
                ErrorCode.code.contains(search) |
                ErrorCode.title.contains(search) |
                ErrorCode.description.contains(search)
            )
            query = query.where(search_filter)
        
        # Apply pagination
        query = query.offset(skip).limit(limit)
        
        # Execute query
        error_codes = session.exec(query).all()
        
        return error_codes
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve error codes: {str(e)}"
        )

# Get Error Code by ID
@router.get("/{error_code_id}", response_model=ErrorCodeRead)
async def get_error_code(
    error_code_id: int,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
    
    try:
        error_code = session.get(ErrorCode, error_code_id)
        
        if not error_code:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Error code with ID {error_code_id} not found"
            )
        
        return error_code
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve error code: {str(e)}"
        )

# Get Error Code by Code
@router.get("/code/{code}", response_model=ErrorCodeRead)
async def get_error_code_by_code(
    code: str,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
    
    try:
        error_code = session.exec(
            select(ErrorCode).where(ErrorCode.code == code)
        ).first()
        
        if not error_code:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Error code '{code}' not found"
            )
        
        return error_code
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve error code: {str(e)}"
        )

# Update Error Code
@router.put("/{error_code_id}", response_model=ErrorCodeRead)
async def update_error_code(
    error_code_id: int,
    error_code_update: ErrorCodeUpdate,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_active_admin)
):
   
    try:
        # Get existing error code
        db_error_code = session.get(ErrorCode, error_code_id)
        
        if not db_error_code:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Error code with ID {error_code_id} not found"
            )
        
        # Check if code is being changed and if new code already exists
        if error_code_update.code and error_code_update.code != db_error_code.code:
            existing_code = session.exec(
                select(ErrorCode).where(ErrorCode.code == error_code_update.code)
            ).first()
            
            if existing_code:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Error code '{error_code_update.code}' already exists"
                )
        
        # Update fields
        update_data = error_code_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_error_code, field, value)
        
        db_error_code.updated_at = datetime.utcnow()
        
        session.add(db_error_code)
        session.commit()
        session.refresh(db_error_code)
        
        return db_error_code
        
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update error code: {str(e)}"
        )

# Delete Error Code
@router.delete("/{error_code_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_error_code(
    error_code_id: int,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
    
    try:
        # Get existing error code
        db_error_code = session.get(ErrorCode, error_code_id)
        
        if not db_error_code:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Error code with ID {error_code_id} not found"
            )
        
        # Check if error code is referenced by knowledge base content
        from ..model.models import KnowledgeBaseContent
        referenced_content = session.exec(
            select(KnowledgeBaseContent).where(
                KnowledgeBaseContent.related_error_code_id == error_code_id
            )
        ).first()
        
        if referenced_content:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot delete error code as it is referenced by knowledge base content"
            )
        
        # Delete error code
        session.delete(db_error_code)
        session.commit()
        
        return None
        
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete error code: {str(e)}"
        )

# Bulk Create Error Codes
@router.post("/bulk", response_model=List[ErrorCodeRead], status_code=status.HTTP_201_CREATED)
async def bulk_create_error_codes(
    error_codes: List[ErrorCodeCreate],
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
    
    try:
        created_codes = []
        
        for error_code_data in error_codes:
            # Check if error code already exists
            existing_code = session.exec(
                select(ErrorCode).where(ErrorCode.code == error_code_data.code)
            ).first()
            
            if existing_code:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Error code '{error_code_data.code}' already exists"
                )
            
            # Create new error code
            db_error_code = ErrorCode(
                code=error_code_data.code,
                title=error_code_data.title,
                description=error_code_data.description,
                manufacturer_origin=error_code_data.manufacturer_origin,
                severity=error_code_data.severity,
                suggested_action=error_code_data.suggested_action,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
            
            session.add(db_error_code)
            created_codes.append(db_error_code)
        
        session.commit()
        
        # Refresh all created codes to get their IDs
        for code in created_codes:
            session.refresh(code)
        
        return created_codes
        
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create error codes in bulk: {str(e)}"
        )

# Get Error Codes by Manufacturer Origin
@router.get("/manufacturer/{manufacturer_origin}", response_model=List[ErrorCodeRead])
async def get_error_codes_by_manufacturer(
    manufacturer_origin: str,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
 
    try:
        error_codes = session.exec(
            select(ErrorCode).where(ErrorCode.manufacturer_origin == manufacturer_origin)
        ).all()
        
        return error_codes
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve error codes by manufacturer: {str(e)}"
        )

# Get Error Codes by Severity
@router.get("/severity/{severity}", response_model=List[ErrorCodeRead])
async def get_error_codes_by_severity(
    severity: str,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
    
    try:
        error_codes = session.exec(
            select(ErrorCode).where(ErrorCode.severity == severity)
        ).all()
        
        return error_codes
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve error codes by severity: {str(e)}"
        )
