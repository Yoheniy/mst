from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from typing import List

from ..model.models import MachineModel, Employee
from .utils.database import get_session
from .utils.auth import get_current_active_admin
router = APIRouter(
    prefix="/employee",
    tags=["Employee id registration"]
)


@router.post("/", response_model=Employee, status_code=status.HTTP_201_CREATED)
def create_employee(
    employee: Employee,
    admin=Depends(get_current_active_admin),
    session: Session = Depends(get_session)
):
    session.add(employee)
    session.commit()
    session.refresh(employee)
    return employee

@router.get("/", response_model=List[Employee])
def list_employees(
    admin=Depends(get_current_active_admin),
    session: Session = Depends(get_session)):
    return session.exec(select(Employee)).all()

@router.delete("/{employee_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_employee(employee_id: str,
    admin=Depends(get_current_active_admin), session: Session = Depends(get_session)):
    employee = session.exec(select(Employee).where(Employee.employee_id == employee_id)).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")
    session.delete(employee)
    session.commit()
    return None