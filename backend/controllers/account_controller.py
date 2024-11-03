from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.account_service import get_all_accounts, add_new_account, update_account, delete_account
from schemas.account_schema import AccountResponse, AccountCreate
from typing import List

router = APIRouter()

@router.get("/{user_id}", response_model=AccountResponse)
async def get_accounts(user_id: int, db: Session = Depends(get_db)):
   # Fetch accounts using the service layer
   accounts = await get_all_accounts(db, user_id)
   return accounts  # Directly return the response from service layer

@router.post("/accounts/")
async def create_account(user_id: int, account_data: AccountCreate, db: Session = Depends(get_db)):
   return await add_new_account(db, user_id, account_data)

@router.put("/accounts/{account_id}", response_model=AccountResponse)
async def update_account_details(account_id: int, account_data: AccountCreate, db: Session = Depends(get_db)):
   updated_account = await update_account(db, account_id, account_data)
   return updated_account

@router.delete("/accounts/{account_id}", response_model=AccountResponse)
async def delete_account_endpoint(account_id: int, db: Session = Depends(get_db)):
   deleted_account = await delete_account(db, account_id)
   return deleted_account