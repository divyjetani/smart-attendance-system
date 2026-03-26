from sqlalchemy import Column, Integer, String, Date, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.core.database import Base

class Attendance(Base):
    __tablename__ = "attendances"
    __table_args__ = (UniqueConstraint('student_id', 'subject_id', 'date', name='unique_attendance'),)

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    subject_id = Column(Integer, ForeignKey("subjects.id"), nullable=False)
    date = Column(Date, nullable=False)
    status = Column(String, nullable=False)  # present, absent, holiday

    student = relationship("Student", back_populates="attendances")
    subject = relationship("Subject", back_populates="attendances")