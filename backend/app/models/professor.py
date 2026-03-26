from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base

class Professor(Base):
    __tablename__ = "professors"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)

    user = relationship("User", back_populates="professor")
    subjects = relationship("Subject", back_populates="professor")

User.professor = relationship("Professor", back_populates="user", uselist=False)