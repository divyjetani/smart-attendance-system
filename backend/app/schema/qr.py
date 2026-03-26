from pydantic import BaseModel

class QRGenerateRequest(BaseModel):
    subject_id: int

class QRGenerateResponse(BaseModel):
    qr_code: str