from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import engine, Base
from app.api import auth, subjects, attendance, students, qr, upload

app = FastAPI(title="Smart Attendance API", version="1.0.0")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create tables (in production use Alembic)
Base.metadata.create_all(bind=engine)

# Include routers
app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(subjects.router, prefix="/subjects", tags=["subjects"])
app.include_router(attendance.router, prefix="/attendance", tags=["attendance"])
app.include_router(students.router, prefix="/students", tags=["students"])
app.include_router(qr.router, prefix="/qr", tags=["qr"])
app.include_router(upload.router, prefix="/upload", tags=["upload"])

@app.get("/")
def root():
    return {"message": "Smart Attendance API is running"}