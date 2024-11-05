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
   credit: float
   debit: float
   balance: float

class AccountDetails(BaseModel):
   id: int
class AccountDetails(BaseModel):
   id: int
   user_id: Optional[int] = None
   account_type: Optional[AccountTypeEnum] = None
   name: Optional[str] = None
   holderName: Optional[str] = None
   accountNumber: Optional[int] = None
   balance: Optional[float] = None
   credit: Optional[float] = None
   debit: Optional[float] = None

class AccountResponse(BaseModel):
   isSuccess: bool = True
   msg: str = "Account fetched successfully"
   account: Optional[List[AccountDetails]] = None  # Make account optional