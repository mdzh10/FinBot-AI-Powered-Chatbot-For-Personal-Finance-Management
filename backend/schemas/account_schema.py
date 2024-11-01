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
   credit: int
   debit: int
   balance: int

class AccountDetails(BaseModel):
   id: int
   name: str
   holderName: str
   accountNumber: str
   balance: float
   credit: int
   debit: int

class AccountResponse(BaseModel):
   isSuccess: bool = True
   msg: str = "Account fetched successfully"
   account: List[AccountDetails]