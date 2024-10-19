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
    account_number: Optional[str] = None  # Bank account number
    routing_number: Optional[str] = None  # Bank routing number
    balance: Optional[float] = 0.0  # Initial balance

class AccountResponse(BaseModel):
    id: int
    user_id: int
    account_type: AccountTypeEnum
    bank_name: Optional[str]
    account_name: str
    account_number: Optional[str]
    routing_number: Optional[str]
    balance: float
