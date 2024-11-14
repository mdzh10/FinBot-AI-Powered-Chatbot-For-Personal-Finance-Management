from pydantic import BaseModel
from typing import List, Optional


class CategoryCreate(BaseModel):
    user_id: int
    name: str
    budget: Optional[float] = None


class CategoryDetails(BaseModel):
    id: int
    user_id: Optional[int] = None
    name: Optional[str] = None
    budget: Optional[float] = None
    expense: Optional[float] = None

    class Config:
        from_attributes = True  # Allows instantiation from ORM objects


class CategoryResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Operation successful"
    data: Optional[List[CategoryDetails]] = None

    class Config:
        from_attributes = True  # Allows instantiation from ORM objects
