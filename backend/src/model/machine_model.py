from sqlalchemy import Column, String, Boolean
from sqlmodel import Field, SQLModel

class MachineModel(SQLModel,table=True):
    serial_number:str = Field(
        sa_column=Column(String, nullable=False,primary_key=True)
    )
    model:str = Field(
        sa_column=Column(String, nullable=True)
    )
    type:str = Field(
        sa_column=Column(String, nullable=True)
    )
    brand: str = Field(sa_column=Column(String(100), nullable=False))

    owned:bool = Field(
        sa_column=Column(Boolean, nullable=True,default=False)
    )
