from fastapi import APIRouter, Depends, Header
from sqlalchemy.orm import Session
from schemas.authentication_schema import UserCreate, UserLogin, ErrorResponse
from services.authentication_service import handle_sign_up, handle_login, handle_logout
from config.db.database import get_db

router = APIRouter()


@router.post("/signup")
async def sign_up(user: UserCreate, db: Session = Depends(get_db)):
    return await handle_sign_up(user, db)


@router.post("/login")
async def login(user: UserLogin, db: Session = Depends(get_db)):
    return await handle_login(user, db)


@router.post("/logout")
async def logout(authorization: str = Header(...)):
    # Pass the token to the handle_logout function after extracting it from the header
    try:
        token = authorization.split(" ")[1]  # Assumes "Bearer <token>" format
    except IndexError:
        return ErrorResponse(isSuccess=False, msg="Authorization header is malformed")

    return await handle_logout(token)