from pydantic import BaseModel
from typing import List
from typing import Optional
from datetime import datetime
from schemas.transaction_schema import TransactionCreate
from models.transaction import PaymentTypeEnum


class ReceiptTransactionCreate(BaseModel):
    user_id: int
    account_id: int

class ItemDetails(BaseModel):
    item_name: str
    price: float

class ReceiptResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Receipt info extracted successfully"
    transactions: List[TransactionCreate]

    class Config:
        arbitrary_types_allowed = True  # Allow datetime
        from_attributes = True  # Allows instantiation from ORM objects
