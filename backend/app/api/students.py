from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.student import Student
from app.models.user import UserRole, User
from app.schemas.student import StudentOut, StudentCreate
from app.api.auth import oauth2_scheme
from app.core.security import decode_token
from app.utils.exceptions import raise_http_exception
from typing import List

router = APIRouter()

@router.get("/subject/{subject_id}", response_model=List[StudentOut])
def get_students_by_subject(subject_id: int, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_token(token)
    if not payload or payload.get("role") != UserRole.PROFESSOR:
        raise_http_exception(403, "Not authorized")
    # Assuming we have a many-to-many student-subject enrollment; for simplicity, we'll return all students
    # In real app, you'd have an enrollment table. Here we'll just return all students.
    students = db.query(Student).all()
    # We'll also fetch user name for each
    result = []
    for s in students:
        user = db.query(User).filter(User.id == s.user_id).first()
        result.append({
            "id": s.id,
            "user_id": s.user_id,
            "enrollment_number": s.enrollment_number,
            "bound_device_id": s.bound_device_id,
            "name": user.name if user else ""
        })
    return result

@router.post("/change-device")
def change_device(data: dict, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_token(token)
    if not payload or payload.get("role") != UserRole.PROFESSOR:
        raise_http_exception(403, "Not authorized")
    student_id = data.get("studentId")
    new_device_id = data.get("newDeviceId")
    if not student_id:
        raise_http_exception(400, "studentId required")
    student = db.query(Student).filter(Student.id == student_id).first()
    if not student:
        raise_http_exception(404, "Student not found")
    student.bound_device_id = new_device_id  # null means unbind
    db.commit()
    return {"message": "Device updated successfully"}