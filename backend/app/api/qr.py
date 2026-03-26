from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.qr_session import QRSession
from app.models.subject import Subject
from app.models.user import UserRole
from app.schemas.qr import QRGenerateRequest, QRGenerateResponse
from app.api.auth import oauth2_scheme
from app.core.security import decode_token
from app.utils.qr_helper import generate_qr_token
from app.utils.exceptions import raise_http_exception
from datetime import datetime, timedelta
import secrets

router = APIRouter()

@router.post("/generate", response_model=QRGenerateResponse)
def generate_qr(data: QRGenerateRequest, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_token(token)
    if not payload or payload.get("role") != UserRole.PROFESSOR:
        raise_http_exception(403, "Not authorized")
    # Verify subject belongs to professor
    subject = db.query(Subject).filter(Subject.id == data.subject_id).first()
    if not subject:
        raise_http_exception(404, "Subject not found")
    # In real app, you'd also verify professor owns subject
    # Generate unique QR code
    qr_token = generate_qr_token(data.subject_id)  # Or use secrets
    expires_at = datetime.utcnow() + timedelta(seconds=20)
    qr_session = QRSession(
        subject_id=data.subject_id,
        qr_code=qr_token,
        expires_at=expires_at
    )
    db.add(qr_session)
    db.commit()
    return {"qr_code": qr_token}