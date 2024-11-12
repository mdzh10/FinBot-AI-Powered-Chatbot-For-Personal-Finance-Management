from pydantic import BaseModel
from typing import List, Optional


class CategoryCreate(BaseModel):
    user_id: int
    name: str
    budget: Optional[float] = None


class CategoryDetails(BaseModel):
    id: int
    name: Optional[str] = None
    budget: Optional[float] = None
    expense: Optional[float] = None


class CategoryResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Operation successful"
    user_id: int
    data: Optional[List[CategoryDetails]] = None
