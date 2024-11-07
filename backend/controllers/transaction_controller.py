from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.transaction_service import (
    add_transaction,
    get_all_transactions,
    update_transaction,
    delete_transaction_by_id,
)
from schemas.transaction_schema import TransactionResponse, TransactionCreate
from typing import List
from fastapi import HTTPException

router = APIRouter()


@router.get("/{user_id}", response_model=List[TransactionResponse])
async def get_transactions(user_id: int, db: Session = Depends(get_db)):
    # Fetch transactions using the service layer
    transactions = await get_all_transactions(db, user_id)

    if not transactions:
        return {"message": "User not found", "error_code": 404}

    return transactions


@router.post("/add")
async def create_transaction(
    transaction: TransactionCreate, db: Session = Depends(get_db)
):

    try:
        new_transaction = add_transaction(db, transaction)
        return await new_transaction
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/modify/{transaction_id}")
async def modify_transaction(
    transaction_id: int, transaction: TransactionCreate, db: Session = Depends(get_db)
):
    try:
        modified_transaction = await update_transaction(db, transaction_id, transaction)
        return modified_transaction
    except Exception as e:
        raise HTTPException(status_code=400, details=str(e))


@router.delete("/delete/{transaction_id}")
async def delete_transaction(transaction_id: int, db: Session = Depends(get_db)):
    try:
        deleted_transaction = delete_transaction_by_id(db, transaction_id)
        if not deleted_transaction:
            raise HTTPException(status_code=404, detail="Transaction not found")
        return {"message": "Transaction deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
