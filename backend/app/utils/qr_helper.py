import secrets

def generate_qr_token(subject_id: int) -> str:
    # Create a token with subject_id and random part
    random_part = secrets.token_hex(8)
    return f"{subject_id}:{random_part}"