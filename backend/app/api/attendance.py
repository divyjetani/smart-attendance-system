from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.attendance import Attendance
from app.models.subject import Subject
from app.models.student import Student
from app.models.user import UserRole
from app.schemas.attendance import AttendanceOut, AttendanceCreate
from app.api.auth import oauth2_scheme
from app.core.security import decode_token
from app.utils.exceptions import raise_http_exception
from typing import List
from datetime import date

router = APIRouter()

@router.get("/{student_id}/{subject_id}", response_model=List[AttendanceOut])
def get_attendance(student_id: int, subject_id: int, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_token(token)
    if not payload:
        raise_http_exception(401, "Invalid token")
    # Check role: student can only see own, professor can see any
    user_role = payload.get("role")
    user_id = payload.get("sub")
    if user_role == UserRole.STUDENT:
        # Verify that student_id matches the logged-in student
        student = db.query(Student).filter(Student.user_id == user_id).first()
        if not student or student.id != student_id:
            raise_http_exception(403, "Not authorized")
    # else professor allowed
    attendances = db.query(Attendance).filter(
        Attendance.student_id == student_id,
        Attendance.subject_id == subject_id
    ).order_by(Attendance.date).all()
    return attendances

@router.post("/mark", response_model=dict)
def mark_attendance(data: dict, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    # Expected: student_id, subject_id, qr_code
    payload = decode_token(token)
    if not payload or payload.get("role") != UserRole.STUDENT:
        raise_http_exception(403, "Not authorized")
    student_id = data.get("student_id")
    subject_id = data.get("subject_id")
    qr_code = data.get("qr_code")
    if not all([student_id, subject_id, qr_code]):
        raise_http_exception(400, "Missing fields")
    # Validate qr_code exists and is not expired
    # (QR sessions are created by professor and stored in DB)
    from app.models.qr_session import QRSession
    qr_session = db.query(QRSession).filter(QRSession.qr_code == qr_code).first()
    if not qr_session:
        raise_http_exception(400, "Invalid QR code")
    if qr_session.expires_at < datetime.utcnow():
        raise_http_exception(400, "QR code expired")
    if qr_session.is_used:
        raise_http_exception(400, "QR code already used")
    # Mark attendance
    today = date.today()
    existing = db.query(Attendance).filter(
        Attendance.student_id == student_id,
        Attendance.subject_id == subject_id,
        Attendance.date == today
    ).first()
    if existing:
        raise_http_exception(400, "Attendance already marked for today")
    attendance = Attendance(
        student_id=student_id,
        subject_id=subject_id,
        date=today,
        status="present"
    )
    db.add(attendance)
    qr_session.is_used = 1
    db.commit()
    return {"message": "Attendance marked successfully"}

# For professor: add attendance for a student on a specific date (optional, but used by upload)
@router.post("/", response_model=AttendanceOut)
def add_attendance(att: AttendanceCreate, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_token(token)
    if not payload or payload.get("role") != UserRole.PROFESSOR:
        raise_http_exception(403, "Not authorized")
    # Check if already exists
    existing = db.query(Attendance).filter(
        Attendance.student_id == att.student_id,
        Attendance.subject_id == att.subject_id,
        Attendance.date == att.date
    ).first()
    if existing:
        raise_http_exception(400, "Attendance already exists for this student, subject, date")
    db_att = Attendance(**att.dict())
    db.add(db_att)
    db.commit()
    db.refresh(db_att)
    return db_att