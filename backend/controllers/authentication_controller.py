from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from schemas.authentication_schema import UserCreate, UserLogin
from services.authentication_service import handle_sign_up, handle_login
from config.db.database import get_db

router = APIRouter()


@router.post("/signup")
async def sign_up(user: UserCreate, db: Session = Depends(get_db)):
    return await handle_sign_up(user, db)


@router.post("/login")
async def login(user: UserLogin, db: Session = Depends(get_db)):
    return await handle_login(user, db)
