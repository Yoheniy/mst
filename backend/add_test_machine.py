#!/usr/bin/env python3
"""
Script to add a test machine serial number to the database
"""
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from sqlmodel import Session, select
from src.model.models import MachineModel
from src.routes.utils.database import get_session

def add_test_machine():
    session = next(get_session())
    
    # Check if test machine already exists
    existing = session.exec(select(MachineModel).where(MachineModel.serial_number == "TEST123")).first()
    
    if existing:
        print("Test machine already exists!")
        return
    
    # Create test machine
    test_machine = MachineModel(
        serial_number="TEST123",
        owned=False
    )
    
    session.add(test_machine)
    session.commit()
    print("Test machine 'TEST123' added successfully!")
    print("You can now use 'TEST123' as the machine serial number for registration.")

if __name__ == "__main__":
    add_test_machine()
