from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import create_access_token, verify_password, get_password_hash
from app.models.user import User, UserRole
from app.models.student import Student
from app.models.professor import Professor
from app.schemas.user import UserCreate, UserOut, Token
from app.utils.exceptions import raise_http_exception
from datetime import timedelta
from app.core.config import settings
import logging

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

@router.post("/register", response_model=UserOut)
def register(user: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    existing = db.query(User).filter(User.email == user.email).first()
    if existing:
        raise_http_exception(status.HTTP_400_BAD_REQUEST, "Email already registered")
    hashed = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        name=user.name,
        hashed_password=hashed,
        role=user.role
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    # Create role-specific record
    if user.role == UserRole.STUDENT:
        # enrollment number should be provided, but for simplicity we generate a dummy
        # Actually we would expect enrollment number in request; let's add it to schema
        student = Student(user_id=db_user.id, enrollment_number="ENROLL" + str(db_user.id), bound_device_id=None)
        db.add(student)
    else:
        professor = Professor(user_id=db_user.id)
        db.add(professor)
    db.commit()
    return db_user

@router.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), device_id: str = None, db: Session = Depends(get_db)):
    # Find user by email
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise_http_exception(status.HTTP_401_UNAUTHORIZED, "Invalid credentials")

    # Check device binding for student
    if user.role == UserRole.STUDENT:
        student = db.query(Student).filter(Student.user_id == user.id).first()
        if not student:
            raise_http_exception(status.HTTP_400_BAD_REQUEST, "Student profile not found")
        if student.bound_device_id and student.bound_device_id != device_id:
            raise_http_exception(status.HTTP_403_FORBIDDEN, "Device not authorized. Please contact professor to reset device.")
        # If device not bound, bind it now
        if not student.bound_device_id:
            student.bound_device_id = device_id
            db.commit()

    # Create access token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    token_data = {"sub": str(user.id), "role": user.role}
    access_token = create_access_token(data=token_data, expires_delta=access_token_expires)

    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/logout")
def logout():
    # Since token is stateless, just return success
    return {"message": "Logged out"}

@router.get("/me", response_model=UserOut)
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_token(token)
    if not payload:
        raise_http_exception(status.HTTP_401_UNAUTHORIZED, "Invalid token")
    user_id = payload.get("sub")
    if not user_id:
        raise_http_exception(status.HTTP_401_UNAUTHORIZED, "Invalid token")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise_http_exception(status.HTTP_404_NOT_FOUND, "User not found")
    return user