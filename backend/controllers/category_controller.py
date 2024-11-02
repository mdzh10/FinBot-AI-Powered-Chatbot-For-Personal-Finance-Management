from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.category_service import create_category, get_all_categories
from schemas.category_schema import CategoryCreate, CategoryResponse

router = APIRouter()

# Create Category
@router.post("/categories", response_model=CategoryResponse)
async def add_category(category: CategoryCreate, db: Session = Depends(get_db)):
    new_category = await create_category(db, category)
    return new_category

# Get All Categories
@router.get("/categories", response_model=List[CategoryResponse])
async def get_categories(db: Session = Depends(get_db)):
    categories = await get_all_categories(db)
    if not categories:
        raise HTTPException(status_code=404, detail="No categories found")
    return categories
