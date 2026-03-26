from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.models.user import User

class Student(Base):
    __tablename__ = "students"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    enrollment_number = Column(String, unique=True, index=True, nullable=False)
    bound_device_id = Column(String, nullable=True)  # null means not bound

    user = relationship("User", back_populates="student")
    attendances = relationship("Attendance", back_populates="student")

User.student = relationship("Student", back_populates="user", uselist=False)