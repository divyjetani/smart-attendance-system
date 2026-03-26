from pydantic import BaseModel
from datetime import date

class AttendanceBase(BaseModel):
    student_id: int
    subject_id: int
    date: date
    status: str

class AttendanceCreate(AttendanceBase):
    pass

class AttendanceOut(AttendanceBase):
    id: int

    class Config:
        orm_mode = True