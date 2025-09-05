from sqlalchemy import Column, String
from sqlmodel import Field, SQLModel

class Employee(SQLModel,table=True):

    employee_id:str = Field(
        sa_column=Column(String, nullable=False,unique=True,primary_key=True)
    )

    status:str = Field(
        sa_column=Column(String, nullable=True,default='active')
    )
