from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.account_service import (
    get_all_accounts,
    add_new_account,
    update_account,
    delete_account,
)
from schemas.account_schema import AccountDetails, AccountResponse, AccountCreate

router = APIRouter()


@router.get("/{user_id}", response_model=AccountResponse)
async def get_accounts(user_id: int, db: Session = Depends(get_db)):
    try:
        return await get_all_accounts(db, user_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/create", response_model=AccountResponse)
async def create_account(account_data: AccountCreate, db: Session = Depends(get_db)):
    try:
        return await add_new_account(db, account_data)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/update", response_model=AccountResponse)
async def update_account_details(
    account_data: AccountDetails, db: Session = Depends(get_db)
):
    try:
        return await update_account(db, account_data)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/delete/{account_id}", response_model=AccountResponse)
async def delete_account_endpoint(account_id: int, db: Session = Depends(get_db)):
    try:
        return await delete_account(db, account_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
