from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.category_service import (
    create_category,
    get_all_categories,
    get_category_by_id,
    modify_category,
    delete_category,
)
from schemas.category_schema import (
    CategoryCreate,
    CategoryDetails,
    CategoryResponse,
)

router = APIRouter()


# Create Category
@router.post("/create", response_model=CategoryResponse, operation_id="create_category")
async def add_category(category: CategoryCreate, db: Session = Depends(get_db)):
    try:
        return await create_category(db, category)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# Get Category or All Categories
@router.get("/{user_id}", response_model=CategoryResponse, operation_id="get_category_or_all")
async def get_categories(
    user_id: int, category_id: Optional[int] = None, db: Session = Depends(get_db)
):
    try:
        if category_id is not None:
            return await get_category_by_id(db, category_id, user_id)
        elif category_id is None:
            return await get_all_categories(db, user_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# Modify Category
@router.put(
    "/update", response_model=CategoryResponse, operation_id="update_category_details"
)
async def update_category(category: CategoryDetails, db: Session = Depends(get_db)):
    try:
        return await modify_category(db, category)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# Delete Category
@router.delete(
    "/delete/{category_id}", operation_id="delete_category"
)
async def remove_category(category_id: int, db: Session = Depends(get_db)):
    success = await delete_category(db, category_id)
    if not success:
        raise HTTPException(status_code=404, detail="Category not found")
    return {"isSuccess": True, "msg": "Category deleted successfully"}
