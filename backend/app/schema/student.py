from pydantic import BaseModel
from typing import Optional

class StudentBase(BaseModel):
    user_id: int
    enrollment_number: str
    bound_device_id: Optional[str] = None

class StudentCreate(StudentBase):
    pass

class StudentOut(StudentBase):
    id: int
    name: str = None  # we can join

    class Config:
        orm_mode = True