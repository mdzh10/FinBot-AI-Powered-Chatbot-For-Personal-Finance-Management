from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional

class TransactionCreate(BaseModel):
    user_id: int
    account_id: int
    category_id: int
    title: str
    description: Optional[str] = ""
    amount: float
    type: str  # Expected values: "debit" or "credit"
    datetime: datetime


class TransactionDetails(BaseModel):
    id: int
    account_id: int
    category_id: Optional[int] = None
    title: Optional[str] = None
    description: Optional[str] = None
    amount: Optional[float] = None
    type: Optional[str] = None  # "debit" or "credit"
    datetime: datetime

    class Config:
        arbitrary_types_allowed = True


class TransactionListResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Transaction fetched successfully"
    user_id: int
    transactions: List[TransactionDetails]

    class Config:
        arbitrary_types_allowed = True  # Allow datetime
