from fastapi import HTTPException
from sqlalchemy.orm import Session
from models.category import Category
from schemas.category_schema import CategoryCreate, CategoryDetails, CategoryResponse


# Create Category
async def create_category(db: Session, category: CategoryCreate) -> CategoryResponse:
    # Check if a category with the same name already exists
    existing_category = (
        db.query(Category).filter(Category.name == category.name).first()
    )
    if existing_category:
        raise HTTPException(
            status_code=400, detail="Category with this name already exists"
        )

    new_category = Category(
        name=category.name,
        icon_code_point=category.icon_code_point,
        color_value=category.color_value,
        budget=category.budget,
        expense=category.expense,
    )
    db.add(new_category)
    db.commit()
    db.refresh(new_category)

    return CategoryResponse(
        isSuccess=True,
        msg="Category created successfully",
        data=CategoryDetails(
            id=new_category.id,
            name=new_category.name,
            icon_code_point=new_category.icon_code_point,
            color_value=new_category.color_value,
            budget=new_category.budget,
            expense=new_category.expense,
        ),
    )


# Get All Categories
async def get_all_categories(db: Session) -> CategoryResponse:
    categories = db.query(Category).all()
    category_list = [
        CategoryDetails(
            id=cat.id,
            name=cat.name,
            icon_code_point=cat.icon_code_point,
            color_value=cat.color_value,
            budget=cat.budget,
            expense=cat.expense,
        )
        for cat in categories
    ]
    return CategoryResponse(
        isSuccess=True, msg="Categories fetched successfully", data=category_list
    )


# Get Category by ID
async def get_category_by_id(db: Session, category_id: int) -> CategoryResponse:
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    return CategoryResponse(
        isSuccess=True,
        msg="Category fetched successfully",
        data=CategoryDetails(
            id=category.id,
            name=category.name,
            icon_code_point=category.icon_code_point,
            color_value=category.color_value,
            budget=category.budget,
            expense=category.expense,
        ),
    )


# Modify Category
async def modify_category(db: Session, category: CategoryDetails) -> CategoryResponse:
    existing_category = (
        db.query(Category).filter(Category.id == category.id).first()
    )
    if not existing_category:
        raise HTTPException(status_code=404, detail="Category not found")

    existing_category.name = category.name
    existing_category.icon_code_point = category.icon_code_point
    existing_category.color_value = category.color_value
    existing_category.budget = category.budget
    existing_category.expense = category.expense

    db.commit()
    db.refresh(existing_category)

    return CategoryResponse(
        isSuccess=True,
        msg="Category updated successfully",
        data=CategoryDetails(
            id=existing_category.id,
            name=existing_category.name,
            icon_code_point=existing_category.icon_code_point,
            color_value=existing_category.color_value,
            budget=existing_category.budget,
            expense=existing_category.expense,
        ),
    )


# Delete Category
async def delete_category(db: Session, category_id: int) -> bool:
    existing_category = db.query(Category).filter(Category.id == category_id).first()
    if existing_category:
        db.delete(existing_category)
        db.commit()
        return True
    return False
