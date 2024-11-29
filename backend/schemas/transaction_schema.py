from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional

from schemas.account_schema import AccountDetails
from schemas.category_schema import CategoryDetails
from models.transaction import PaymentTypeEnum


class TransactionCreate(BaseModel):
    user_id: int
    account_id: int
    category_id: Optional[int] = None
    title: str
    description: Optional[str] = ""
    amount: float
    type: PaymentTypeEnum  # Expected values: "debit" or "credit"
    datetime: datetime


class TransactionUpdate(BaseModel):
    id: int
    user_id: int
    account_id: Optional[int] = None
    category_id: Optional[int] = None
    title: Optional[str] = None
    description: Optional[str] = ""
    amount: Optional[float] = None
    type: Optional[PaymentTypeEnum] = None  # Expected values: "debit" or "credit"
    datetime: datetime


class TransactionDetails(BaseModel):
    id: int
    account: AccountDetails
    user_id: Optional[int] = None
    category: Optional[CategoryDetails] = None
    title: Optional[str] = None
    description: Optional[str] = None
    amount: Optional[float] = None
    type: Optional[PaymentTypeEnum] = None  # "debit" or "credit"
    datetime: datetime

    class Config:
        arbitrary_types_allowed = True
        from_attributes = True  # Allows instantiation from ORM objects


class TransactionListResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Transaction fetched successfully"
    transactions: List[TransactionDetails]

    class Config:
        arbitrary_types_allowed = True  # Allow datetime
        from_attributes = True  # Allows instantiation from ORM objects
