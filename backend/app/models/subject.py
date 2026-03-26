from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base

class Subject(Base):
    __tablename__ = "subjects"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    semester = Column(Integer, nullable=False)
    professor_id = Column(Integer, ForeignKey("professors.id"), nullable=False)

    professor = relationship("Professor", back_populates="subjects")
    attendances = relationship("Attendance", back_populates="subject")