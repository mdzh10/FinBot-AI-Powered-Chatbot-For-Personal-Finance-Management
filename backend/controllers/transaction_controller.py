from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.transaction_service import get_all_transactions
from services.transaction_service import add_transaction
from schemas.transaction_schema import TransactionResponse
from schemas.transaction_schema import TransactionCreate
from typing import List

router = APIRouter()

@router.get("/{user_id}", response_model=List[TransactionResponse])
async def get_transactions(user_id: int, db: Session = Depends(get_db)):
    # Fetch transactions using the service layer
    transactions = await get_all_transactions(db, user_id)

    if not transactions:
        return {"message": "User not found", "error_code": 404}

    return transactions

@router.post("/addtransaction")
async def create_transaction(transaction: TransactionCreate, db: Session= Depends(get_db)):

    try:
        new_transaction=add_transaction(db, transaction)
        return await new_transaction
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))