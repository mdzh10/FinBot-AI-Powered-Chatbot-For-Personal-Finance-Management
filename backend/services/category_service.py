from fastapi import HTTPException
from sqlalchemy.orm import Session
from models.category import Category
from schemas.category_schema import CategoryCreate, CategoryDetails, CategoryResponse

# Create Category
async def create_category(db: Session, category: CategoryCreate) -> CategoryResponse:
    # Check if a category with the same name already exists
    existing_category = db.query(Category).filter(Category.category_name == category.category_name).first()
    if existing_category:
        raise HTTPException(status_code=400, detail="Category with this name already exists")

    new_category = Category(category_name=category.category_name)
    db.add(new_category)
    db.commit()
    db.refresh(new_category)

    # Wrap the response in CategoryResponse
    return CategoryResponse(
        isSuccess=True,
        msg="Category created successfully",
        data=CategoryDetails(
            category_id=new_category.category_id,
            category_name=new_category.category_name
        )
    )

# Get All Categories
async def get_all_categories(db: Session) -> CategoryResponse:
    categories = db.query(Category).all()
    category_list = [
        CategoryDetails(
            category_id=cat.category_id,
            category_name=cat.category_name
        )
        for cat in categories
    ]
    # Return a CategoryResponse with a list of CategoryDetails in `data`
    return CategoryResponse(
        isSuccess=True,
        msg="Categories fetched successfully",
        data=category_list
    )

# Get Category by ID
async def get_category_by_id(db: Session, category_id: int) -> CategoryResponse:
    category = db.query(Category).filter(Category.category_id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    # Return a CategoryResponse with a single CategoryDetails instance in `data`
    return CategoryResponse(
        isSuccess=True,
        msg="Category fetched successfully",
        data=CategoryDetails(
            category_id=category.category_id,
            category_name=category.category_name
        )
    )

# Modify Category
async def modify_category(db: Session, category: CategoryDetails) -> CategoryResponse:
    existing_category = db.query(Category).filter(Category.category_id == category.category_id).first()
    if not existing_category:
        raise HTTPException(status_code=404, detail="Category not found")

    existing_category.category_name = category.category_name
    db.commit()
    db.refresh(existing_category)
    
    # Return a CategoryResponse with a single updated CategoryDetails instance in `data`
    return CategoryResponse(
        isSuccess=True,
        msg="Category updated successfully",
        data=CategoryDetails(
            category_id=existing_category.category_id,
            category_name=existing_category.category_name
        )
    )

# Delete Category
async def delete_category(db: Session, category_id: int) -> bool:
    existing_category = db.query(Category).filter(Category.category_id == category_id).first()
    if existing_category:
        db.delete(existing_category)
        db.commit()
        return True
    return False