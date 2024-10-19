from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from db.database import get_db
from services.transaction_service import get_all_transactions
from schemas.transaction_schema import TransactionResponse
from typing import List

router = APIRouter()

@router.get("/{user_id}", response_model=List[TransactionResponse])
async def get_transactions(user_id: int = Query(...), db: Session = Depends(get_db)):
    # Fetch transactions using the service layer
    transactions = await get_all_transactions(db, user_id)

    if not transactions:
        return {"message": "User not found", "error_code": 404}

    return transactions