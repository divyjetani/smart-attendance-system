from pydantic import BaseModel

class SubjectBase(BaseModel):
    name: str
    semester: int

class SubjectCreate(SubjectBase):
    professor_id: int

class SubjectOut(SubjectBase):
    id: int
    professor_id: int

    class Config:
        orm_mode = True