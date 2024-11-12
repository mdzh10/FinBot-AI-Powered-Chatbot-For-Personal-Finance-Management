from fastapi import HTTPException
from sqlalchemy.orm import Session
from models.category import Category
from schemas.category_schema import CategoryCreate, CategoryDetails, CategoryResponse


# Create Category
async def create_category(db: Session, category: CategoryCreate) -> CategoryResponse:
    # Check if a category with the same name for the user already exists
    existing_category = (
        db.query(Category)
        .filter(Category.name == category.name, Category.user_id == category.user_id)
        .first()
    )
    if existing_category:
        raise HTTPException(
            status_code=400,
            detail="Category with this name already exists for the user",
        )

    # Create and add the new category to the database
    new_category = Category(
        user_id=category.user_id,
        name=category.name,
        budget=category.budget,
        expense=0.0,  # Initialize expense to 0 if not provided
    )
    db.add(new_category)
    db.commit()
    db.refresh(new_category)

    # Prepare the response
    return CategoryResponse(
        isSuccess=True,
        msg="Category created successfully",
        user_id=category.user_id,
        data=[
            CategoryDetails(
                id=new_category.id,
                name=new_category.name,
                budget=new_category.budget,
                expense=new_category.expense,
            )
        ],
    )


# Get All Categories for a User
async def get_all_categories(db: Session, user_id: int) -> CategoryResponse:
    # Fetch all categories for a specific user
    categories = db.query(Category).filter(Category.user_id == user_id).all()

    # Prepare the list of categories
    category_list = [
        CategoryDetails(
            id=cat.id,
            name=cat.name,
            budget=cat.budget,
            expense=cat.expense,
        )
        for cat in categories
    ]

    return CategoryResponse(
        isSuccess=True,
        msg="Categories fetched successfully",
        user_id=user_id,
        data=category_list,
    )


# Get Category by ID for a User
async def get_category_by_id(
    db: Session, category_id: int, user_id: int
) -> CategoryResponse:
    # Fetch the specific category by ID and user ID
    category = (
        db.query(Category)
        .filter(Category.id == category_id, Category.user_id == user_id)
        .first()
    )
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    # Prepare the response with a single category
    return CategoryResponse(
        isSuccess=True,
        msg="Category fetched successfully",
        user_id=user_id,
        data=[
            CategoryDetails(
                id=category.id,
                name=category.name,
                budget=category.budget,
                expense=category.expense,
            )
        ],
    )


# Modify Category
async def modify_category(db: Session, category: CategoryDetails) -> CategoryResponse:
    # Find the existing category by ID and user ID
    existing_category = db.query(Category).filter(Category.id == category.id).first()
    if not existing_category:
        raise HTTPException(status_code=404, detail="Category not found")

    # Update the category fields
    if category.name is not None:
        existing_category.name = category.name
    if category.budget is not None:
        existing_category.budget = category.budget
    if category.expense is not None:
        existing_category.expense = category.expense

    db.commit()
    db.refresh(existing_category)

    # Prepare the response
    return CategoryResponse(
        isSuccess=True,
        msg="Category updated successfully",
        user_id=existing_category.user_id,
        data=[
            CategoryDetails(
                id=existing_category.id,
                name=existing_category.name,
                budget=existing_category.budget,
                expense=existing_category.expense,
            )
        ],
    )


# Delete Category
async def delete_category(db: Session, category_id: int) -> CategoryResponse:
    # Find the category by ID and user ID
    existing_category = db.query(Category).filter(Category.id == category_id).first()
    if not existing_category:
        raise HTTPException(status_code=404, detail="Category not found")

    # Delete the category
    db.delete(existing_category)
    db.commit()

    return True
