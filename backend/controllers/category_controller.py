from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.category_service import ( create_category,get_all_categories,modify_category,delete_category)
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
 
# Modify Category
@router.put("/categories/{category_id}", response_model=CategoryResponse)
async def update_category(category_id: int, category: CategoryCreate, db: Session = Depends(get_db)):
    updated_category = await modify_category(db, category_id, category)
    if not updated_category:
        raise HTTPException(status_code=404, detail="Category not found")
    return updated_category
 
# Delete Category
@router.delete("/categories/{category_id}", response_model=dict)
async def remove_category(category_id: int, db: Session = Depends(get_db)):
    success = await delete_category(db, category_id)
    if not success:
        raise HTTPException(status_code=404, detail="Category not found")
    return {"detail": "Category deleted successfully"}
