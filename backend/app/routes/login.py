from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session

from app.schema import LoginRequest, TokenResponse
from app.auth import create_access_token, verify_password, get_current_user
from app.crud import get_user_by_email
from app.database import SessionLocal
from fastapi import Depends
from app.auth import get_current_user

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
def login(user: LoginRequest):

    db: Session = SessionLocal()

    try:
        db_user = get_user_by_email(db, user.email)

        if not db_user:
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password"
            )
        
        
        if not verify_password(user.password, db_user.password):
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password"
            )

        access_token = create_access_token(
            {
                "sub": db_user.email,
                "role": db_user.role
            }
        )

        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "user_id": db_user.user_id,
                "email": db_user.email,
                "role": db_user.role
            }
        }

    finally:
        db.close()
    
@router.get("/me")
def read_me(current_user = Depends(get_current_user)):
        return {
            "user_id": current_user.user_id,
            "email": current_user.email,
            "role": current_user.role
        }