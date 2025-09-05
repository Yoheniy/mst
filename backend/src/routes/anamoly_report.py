from typing import List, Optional
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlmodel import Session, select
from pydantic import BaseModel

from .utils.database import get_session
from .utils.auth import get_current_user
from ..model.models import (
    AnomalyReport, AnomalyReportCreate, AnomalyStatus, AnomalyPriority,
    User, UserRole, Machine
)
from .utils.cloudinary_service import cloudinary_service

router = APIRouter(prefix="/anomaly-reports", tags=["Anomaly Reports"])


class AnomalyReportUpdateModel(BaseModel):
    report_text: Optional[str] = None
    audio_transcript: Optional[str] = None
    r_status: Optional[AnomalyStatus] = None
    priority: Optional[AnomalyPriority] = None
    observed_at: Optional[datetime] = None
    machine_id: Optional[int] = None


def _ensure_admin_or_technician(user: User):
    if user.role not in [UserRole.ADMIN, UserRole.TECHNICIAN]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admin or technician can perform this action"
        )


@router.post("/", response_model=AnomalyReport, status_code=status.HTTP_201_CREATED)
async def create_anomaly_report(
    machine_id: int,
    report_text: str,
    audio_transcript: Optional[str] = None,
    r_status: AnomalyStatus = AnomalyStatus.SUBMITTED,
    priority: AnomalyPriority = AnomalyPriority.MEDIUM,
    observed_at: Optional[datetime] = None,
    file: Optional[UploadFile] = File(None),
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Create an anomaly report. Optionally upload a file to Cloudinary and store its URL in media_urls.
    Only users with role admin or technician can create.
    """
    _ensure_admin_or_technician(current_user)

    import json
    

    # Ensure machine exists
    machine = session.get(Machine, machine_id)
    if not machine:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Machine not found"
        )

    media_urls: List[str] = []
    if file:
        file_bytes = await file.read()
        file_name = file.filename
        upload_result = await cloudinary_service.upload_file(
            file_data=file_bytes,
            file_name=file_name,
            folder="anomaly_reports",
            resource_type="auto"
        )
        if upload_result.get("url"):
            media_urls.append(upload_result["url"])
    
    # report_create = AnomalyReportCreate(
    #     machine_id=machine_id,
    #     reporter_id=current_user.user_id,
    #     media_urls=media_urls,
    #     report_text=report_text,
    #     audio_transcript=audio_transcript,
    #     status=r_status,
    #     priority=priority,
    #     observed_at=observed_at
    # )
    db_report = AnomalyReport(
        reporter_id=current_user.user_id,
        machine_id=machine_id,
        report_text=report_text,
        media_urls=media_urls if media_urls else [],
        audio_transcript=audio_transcript,
        status=r_status,
        priority=priority,
        observed_at=observed_at or datetime.utcnow(),
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )

    session.add(db_report)
    session.commit()
    session.refresh(db_report)
    return db_report


@router.get("/", response_model=List[AnomalyReport])
async def list_anomaly_reports(
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[AnomalyStatus] = None,
    priority_filter: Optional[AnomalyPriority] = None,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    query = select(AnomalyReport)
    if status_filter:
        query = query.where(AnomalyReport.status == status_filter)
    if priority_filter:
        query = query.where(AnomalyReport.priority == priority_filter)
    query = query.offset(skip).limit(limit)
    return session.exec(query).all()


@router.get("/{report_id}", response_model=AnomalyReport)
async def get_anomaly_report(
    report_id: int,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    report = session.get(AnomalyReport, report_id)
    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Anomaly report not found"
        )
    return report


@router.put("/{report_id}", response_model=AnomalyReport)
async def update_anomaly_report(
    report_id: int,
    update: AnomalyReportUpdateModel,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Update mutable fields of anomaly report. media_urls cannot be updated here."""
    report = session.get(AnomalyReport, report_id)
    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Anomaly report not found"
        )

    # Optional: Allow admin/technician only to update as well (sensible)
    _ensure_admin_or_technician(current_user)

    update_data = update.dict(exclude_unset=True)
    # Explicitly ensure media_urls is not processed even if provided
    if "media_urls" in update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="media_urls cannot be updated"
        )

    # If machine_id provided, validate it
    if update.machine_id is not None:
        machine = session.get(Machine, update.machine_id)
        if not machine:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Machine not found"
            )
        report.machine_id = update.machine_id

    for field, value in update_data.items():
        if field == "machine_id":
            continue
        setattr(report, field, value)

    report.updated_at = datetime.utcnow()
    session.add(report)
    session.commit()
    session.refresh(report)
    return report


@router.delete("/{report_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_anomaly_report(
    report_id: int,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    report = session.get(AnomalyReport, report_id)
    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Anomaly report not found"
        )

    _ensure_admin_or_technician(current_user)

    session.delete(report)
    session.commit()
    return None

