from pydantic import BaseModel
from typing import Optional
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
    balance: int

class AccountResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "account created successful"
    id: int
    user_id: int
    account_type: AccountTypeEnum
    bank_name: Optional[str]
    account_name: str
    account_number: int
    balance: float
