from sqlalchemy import Column, Integer, String, Enum
from app.core.database import Base
import enum

class UserRole(str, enum.Enum):
    STUDENT = "student"
    PROFESSOR = "professor"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(Enum(UserRole), nullable=False)