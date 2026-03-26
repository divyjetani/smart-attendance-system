import pandas as pd
from io import BytesIO
from datetime import datetime

def parse_attendance_excel(file_bytes: bytes) -> list:
    """
    Expected columns: enrollment_number, date, status
    """
    df = pd.read_excel(BytesIO(file_bytes), engine='openpyxl')
    records = []
    for _, row in df.iterrows():
        enrollment = row.get('enrollment_number')
        date_str = row.get('date')
        status = row.get('status')
        if enrollment and date_str and status:
            # Convert date to datetime object
            try:
                date = pd.to_datetime(date_str).date()
            except:
                continue
            records.append({
                "enrollment_number": str(enrollment),
                "date": date,
                "status": status
            })
    return records