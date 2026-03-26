from fastapi import APIRouter, Depends, File, UploadFile, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.attendance import Attendance
from app.models.student import Student
from app.models.subject import Subject
from app.models.user import UserRole
from app.schemas.upload import UploadResponse
from app.api.auth import oauth2_scheme
from app.core.security import decode_token
from app.utils.excel_parser import parse_attendance_excel
from app.utils.exceptions import raise_http_exception
import logging

router = APIRouter()

@router.post("/attendance", response_model=UploadResponse)
async def upload_attendance(
    file: UploadFile = File(...),
    subject_id: int = None,
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    payload = decode_token(token)
    if not payload or payload.get("role") != UserRole.PROFESSOR:
        raise_http_exception(403, "Not authorized")
    if not subject_id:
        raise_http_exception(400, "subject_id required")
    # Check subject exists
    subject = db.query(Subject).filter(Subject.id == subject_id).first()
    if not subject:
        raise_http_exception(404, "Subject not found")
    # Parse file
    try:
        contents = await file.read()
        records = parse_attendance_excel(contents)
    except Exception as e:
        logging.error(f"Excel parsing error: {e}")
        raise_http_exception(400, "Invalid file format or data")
    # Process records: each record should contain enrollment_number and date and status
    added = 0
    for rec in records:
        enrollment = rec.get("enrollment_number")
        date = rec.get("date")
        status = rec.get("status")
        if not enrollment or not date or not status:
            continue
        # Find student
        student = db.query(Student).filter(Student.enrollment_number == enrollment).first()
        if not student:
            continue
        # Check if attendance already exists
        existing = db.query(Attendance).filter(
            Attendance.student_id == student.id,
            Attendance.subject_id == subject_id,
            Attendance.date == date
        ).first()
        if existing:
            continue
        att = Attendance(
            student_id=student.id,
            subject_id=subject_id,
            date=date,
            status=status
        )
        db.add(att)
        added += 1
    db.commit()
    return {"message": "Upload completed", "records_added": added}