from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from app.core.database import Base
from datetime import datetime

class QRSession(Base):
    __tablename__ = "qr_sessions"

    id = Column(Integer, primary_key=True, index=True)
    subject_id = Column(Integer, ForeignKey("subjects.id"), nullable=False)
    qr_code = Column(String, unique=True, index=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    expires_at = Column(DateTime, nullable=False)
    is_used = Column(Integer, default=0)  # 0 = unused, 1 = used