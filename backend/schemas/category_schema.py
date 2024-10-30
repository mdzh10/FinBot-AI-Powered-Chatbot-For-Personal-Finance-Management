from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class CategoryCreate(BaseModel):
    """Schema for creating a new category."""
    category_name: str

class CategoryResponse(BaseModel):
    """Schema for category response with auto-assigned values included."""
    category_id: int
    category_name: str
    created_at: datetime
    updated_at: Optional[datetime]  # Will be None if not updated yet

    class Config:
        orm_mode = True  # Enables compatibility with ORM objects
