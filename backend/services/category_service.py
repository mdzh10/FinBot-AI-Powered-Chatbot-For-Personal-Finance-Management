from sqlalchemy.orm import Session
from models.category import Category
from schemas.category_schema import CategoryCreate, CategoryResponse
from datetime import datetime, timezone
from typing import List, Optional

# Create Category
async def create_category(db: Session, category: CategoryCreate) -> CategoryResponse:
    new_category = Category(
        category_name=category.category_name,
        created_at=datetime.now(timezone.utc),  
        updated_at=datetime.now(timezone.utc)   
    )
    db.add(new_category)
    db.commit()
    db.refresh(new_category)
    return CategoryResponse(
        category_id=new_category.category_id,
        category_name=new_category.category_name,
        created_at=new_category.created_at,
        updated_at=new_category.updated_at
    )

# Get All Categories
async def get_all_categories(db: Session) -> List[CategoryResponse]:
    categories = db.query(Category).all()
    return [
        CategoryResponse(
            category_id=cat.category_id,
            category_name=cat.category_name,
            created_at=cat.created_at,
            updated_at=cat.updated_at
        ) 
        for cat in categories
    ]
