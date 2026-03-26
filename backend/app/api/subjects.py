from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.subject import Subject
from app.models.user import UserRole
from app.schemas.subject import SubjectOut, SubjectCreate
from app.api.auth import oauth2_scheme
from app.core.security import decode_token
from app.models.student import Student
from app.models.professor import Professor
from app.utils.exceptions import raise_http_exception
from typing import List

router = APIRouter()

@router.get("/semester/{semester}/student/{student_id}", response_model=List[SubjectOut])
def get_subjects_by_semester_for_student(semester: int, student_id: int, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    # Verify token
    payload = decode_token(token)
    if not payload or payload.get("role") != UserRole.STUDENT:
        raise_http_exception(403, "Not authorized")
    # Ensure student_id matches logged in user
    # In real app, you'd get user_id from token and map to student
    # For simplicity, we allow any student to see subjects for their semester (could be restricted)
    subjects = db.query(Subject).filter(Subject.semester == semester).all()
    return subjects

@router.get("/professor/{professor_id}", response_model=List[SubjectOut])
def get_subjects_by_professor(professor_id: int, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_token(token)
    if not payload or payload.get("role") != UserRole.PROFESSOR:
        raise_http_exception(403, "Not authorized")
    subjects = db.query(Subject).filter(Subject.professor_id == professor_id).all()
    return subjects

# For professor: create subject (optional)
@router.post("/", response_model=SubjectOut)
def create_subject(subject: SubjectCreate, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_token(token)
    if not payload or payload.get("role") != UserRole.PROFESSOR:
        raise_http_exception(403, "Not authorized")
    # Optional: check if professor exists
    professor = db.query(Professor).filter(Professor.id == subject.professor_id).first()
    if not professor:
        raise_http_exception(404, "Professor not found")
    db_subject = Subject(**subject.dict())
    db.add(db_subject)
    db.commit()
    db.refresh(db_subject)
    return db_subject