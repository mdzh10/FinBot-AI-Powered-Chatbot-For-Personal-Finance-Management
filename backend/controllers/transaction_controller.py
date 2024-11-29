from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from fastapi.params import Query
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.transaction_service import (
    add_transactions,
    get_all_transactions,
    update_transaction,
    delete_transaction_by_id,
)
from schemas.transaction_schema import (
    TransactionListResponse,
    TransactionCreate,
    TransactionUpdate,
)

router = APIRouter()


@router.get("/{user_id}", response_model=TransactionListResponse)
async def get_transactions(
    user_id: int,
    db: Session = Depends(get_db),
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None)
):
    transactions = await get_all_transactions(db, user_id, start_date, end_date)

    if not transactions:
        raise HTTPException(
            status_code=404, detail="No transactions found for this user"
        )

    return transactions


@router.post("/add", response_model=TransactionListResponse)
async def create_transaction(
    transaction: List[TransactionCreate], db: Session = Depends(get_db)
):
    try:
        new_transaction = await add_transactions(db, transaction)
        return new_transaction
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/modify", response_model=TransactionListResponse)
async def modify_transaction(
    transaction: TransactionUpdate, db: Session = Depends(get_db)
):
    try:
        modified_transaction = await update_transaction(db, transaction)
        return modified_transaction
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/delete/{transaction_id}", response_model=dict)
async def delete_transaction(transaction_id: int, db: Session = Depends(get_db)):
    try:
        deleted_transaction = await delete_transaction_by_id(db, transaction_id)
        if not deleted_transaction:
            raise HTTPException(status_code=404, detail="Transaction not found")
        return {"isSuccess": True, "msg": "Transaction deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
