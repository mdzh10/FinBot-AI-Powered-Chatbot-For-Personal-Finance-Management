from pydantic import BaseModel
from typing import List
from typing import Optional

class ItemDetails(BaseModel):
    item: str
    category: str
    price: float
    quantity: Optional[int] = 1

class ReceiptDetails(BaseModel):
    receipt_text: str
    items: List[ItemDetails]
