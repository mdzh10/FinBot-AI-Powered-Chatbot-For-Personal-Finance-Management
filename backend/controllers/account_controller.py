from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.account_service import get_all_accounts
from schemas.account_schema import AccountResponse
from typing import List

router = APIRouter()

@router.get("/{user_id}", response_model=AccountResponse)
async def get_accounts(user_id: int, db: Session = Depends(get_db)):
    # Fetch accounts using the service layer
    accounts = await get_all_accounts(db, user_id)
    return accounts  # Directly return the response from service layer