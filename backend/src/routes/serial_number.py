from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from typing import List

from ..model.models import MachineModel, Employee
from .utils.database import get_session
from .utils.auth import get_current_active_admin
router = APIRouter(
    prefix="/serial-number",
    tags=["Machine Serial number"]
)

# ------------------- MachineModel CRUD -------------------

@router.post("/", response_model=MachineModel, status_code=status.HTTP_201_CREATED)
def create_machine_model(
    serial_number: str,
    owned:bool=False,
    type:str=None,
    model:str=None,
    admin=Depends(get_current_active_admin),
    session: Session = Depends(get_session)
):
    exist = session.exec(select(MachineModel).where(MachineModel.serial_number == serial_number)).first()
    if exist:
        raise HTTPException(
            status_code=404,
            detail={
                "message": "Serial number already registered"
            }
        )
    machine=MachineModel(serial_number=serial_number,owned=owned,type=type,model=model)
    session.add(machine)
    session.commit()
    session.refresh(machine)
    return machine

@router.get("/", response_model=List[MachineModel])
def list_machine_models(
    admin=Depends(get_current_active_admin),
    session: Session = Depends(get_session)):
    return session.exec(select(MachineModel)).all()

@router.get("/not-owned", response_model=List[MachineModel])
def get_not_owned( admin=Depends(get_current_active_admin),
                  session: Session = Depends(get_session)):
    machines = session.exec(select(MachineModel).where(MachineModel.owned == False)).all()
    return machines

@router.get("/owned", response_model=List[MachineModel])
def get_owned( admin=Depends(get_current_active_admin),
              session: Session = Depends(get_session)):
    machines = session.exec(select(MachineModel).where(MachineModel.owned == True)).all()
    return machines

@router.delete("/{serial_number}", status_code=status.HTTP_204_NO_CONTENT)
def delete_machine_model(
    serial_number: str, session: Session = Depends(get_session)
    ,admin=Depends(get_current_active_admin),):
    
    machine = session.exec(select(MachineModel).where(MachineModel.serial_number == serial_number)).first()
    if not machine:
        raise HTTPException(status_code=404, detail="MachineModel not found")
    session.delete(machine)
    session.commit()
    return None

