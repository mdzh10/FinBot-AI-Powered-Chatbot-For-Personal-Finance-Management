from pydantic import BaseModel
from typing import List, Optional
from enum import Enum


class AccountTypeEnum(str, Enum):
    cash = "cash"
    bank = "bank"


class AccountCreate(BaseModel):
    user_id: int
    account_type: AccountTypeEnum
    bank_name: Optional[str] = None  # Applicable for bank accounts
    account_name: str
    account_number: int
    balance: float


class AccountDetails(BaseModel):
    id: int
    user_id: Optional[int] = None
    account_type: Optional[AccountTypeEnum] = None
    bank_name: Optional[str] = None
    account_name: Optional[str] = None
    account_number: Optional[int] = None
    balance: Optional[float] = None
    credit: Optional[float] = None
    debit: Optional[float] = None

    class Config:
        from_attributes = True  # Allows instantiation from ORM objects


class AccountResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Account fetched successfully"
    account: Optional[List[AccountDetails]] = None  # Make account optional

    class Config:
        from_attributes = True  # Allows instantiation from ORM objects
