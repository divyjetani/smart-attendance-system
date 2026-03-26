import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./attendance.db")
    SECRET_KEY: str = os.getenv("SECRET_KEY", "default-secret-key")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))
    ALGORITHM: str = "HS256"

settings = Settings()