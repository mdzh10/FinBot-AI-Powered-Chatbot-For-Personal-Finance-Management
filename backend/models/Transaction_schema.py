from pydantic import BaseModel
from datetime import datetime


class TransactionCreate(BaseModel):
    user_id: int
    account_id: int
    category_id: int
    item_name: str
    quantity: int
    amount: float
    transaction_type: str  # debit or credit
    transaction_date: datetime


class TransactionResponse(BaseModel):
    id: int
    user_id: int
    account_id: int
    category_id: int
    item_name: str
    quantity: int
    amount: float
    transaction_type: str
    transaction_date: datetime
