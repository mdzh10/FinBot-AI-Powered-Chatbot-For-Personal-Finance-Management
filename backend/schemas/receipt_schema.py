from pydantic import BaseModel
from typing import List
from typing import Optional


class ItemDetails(BaseModel):
    id: Optional[int] = None
    item_name: str
    category: str
    price: float
    quantity: Optional[int] = 1


class ReceiptResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Receipt processed successfully"
    items: List[ItemDetails]
