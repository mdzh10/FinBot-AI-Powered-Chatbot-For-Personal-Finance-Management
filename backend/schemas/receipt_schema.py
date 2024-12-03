from pydantic import BaseModel
from typing import List
from schemas.transaction_schema import TransactionCreate


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
