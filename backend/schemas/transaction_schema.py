from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class TransactionCreate(BaseModel):
    user_id: int
    account_id: int
    category_id: int
    item_name: str
    quantity: Optional[int] = 1
    amount: float
    transaction_type: str  # debit or credit
    transaction_date: datetime


class TransactionResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "transaction created successfully"
    id: int
    user_id: int
    account_id: int
    category_id: int
    item_name: str
    quantity: Optional[int] = 1
    amount: float
    transaction_type: str
    transaction_date: datetime
