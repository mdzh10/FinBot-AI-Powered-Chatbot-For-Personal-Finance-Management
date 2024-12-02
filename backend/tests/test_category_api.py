import pytest
from unittest.mock import MagicMock
from sqlalchemy.orm import Session
from services.category_service import create_category, get_all_categories, get_category_by_id, modify_category, delete_category
from schemas.category_schema import CategoryCreate, CategoryDetails, CategoryResponse
from models.category import Category
from fastapi import HTTPException

@pytest.mark.asyncio
async def test_create_category_duplicate():
    db_mock = MagicMock(spec=Session)
    category_data = CategoryCreate(user_id=1, name="Duplicate Category", budget=100.0)

    # Simulate an existing category with the same name for the user
    existing_category = Category(
        id=1, 
        user_id=1, 
        name="Duplicate Category", 
        budget=100.0,
        expense=0.0
    )
    db_mock.query.return_value.filter.return_value.first.return_value = existing_category

    # Expect an HTTPException to be raised
    with pytest.raises(HTTPException) as exc_info:
        await create_category(db_mock, category_data)

    # Additional assertions about the exception
    assert exc_info.value.status_code == 400
    assert "Category with this name already exists for the user" in str(exc_info.value.detail)


@pytest.mark.asyncio
async def test_get_all_categories():
    db_mock = MagicMock(spec=Session)
    user_id = 1

    # Simulating categories in the database
    mock_categories = [
        Category(id=1, user_id=user_id, name="Category 1", budget=100.0, expense=50.0),
        Category(id=2, user_id=user_id, name="Category 2", budget=200.0, expense=30.0)
    ]
    db_mock.query.return_value.filter.return_value.all.return_value = mock_categories

    result = await get_all_categories(db_mock, user_id)

    # Asserts for result
    assert result.isSuccess == True
    assert result.msg == "Categories fetched successfully"
    assert len(result.data) == 2
    assert result.data[0].name == "Category 1"
    assert result.data[1].name == "Category 2"


@pytest.mark.asyncio
async def test_get_category_by_id():
    db_mock = MagicMock(spec=Session)
    category_id = 1
    user_id = 1

    # Simulating a category in the database
    mock_category = Category(id=category_id, user_id=user_id, name="Test Category", budget=100.0, expense=50.0)
    db_mock.query.return_value.filter.return_value.first.return_value = mock_category

    result = await get_category_by_id(db_mock, category_id, user_id)

    # Asserts for result
    assert result.isSuccess == True
    assert result.msg == "Category fetched successfully"
    assert result.data[0].name == "Test Category"
    assert result.data[0].budget == 100.0


@pytest.mark.asyncio
async def test_modify_category():
    db_mock = MagicMock(spec=Session)
    category_data = CategoryDetails(id=1, user_id=1, name="Updated Category", budget=150.0, expense=60.0)

    # Simulating an existing category in the database
    mock_category = Category(id=1, user_id=1, name="Old Category", budget=100.0, expense=50.0)
    db_mock.query.return_value.filter.return_value.first.return_value = mock_category

    # Simulate modifying the category with the updated data
    mock_category.name = category_data.name
    mock_category.budget = category_data.budget
    mock_category.expense = category_data.expense

    # Call the modify_category function
    result = await modify_category(db_mock, category_data)

    # Asserts for result
    assert result.isSuccess == True
    assert result.msg == "Category updated successfully"
    assert result.data[0].name == "Updated Category"
    assert result.data[0].budget == 150.0


@pytest.mark.asyncio
async def test_delete_category():
    db_mock = MagicMock(spec=Session)
    category_id = 1

    # Simulating an existing category in the database
    mock_category = Category(id=category_id, user_id=1, name="Test Category", budget=100.0, expense=50.0)
    db_mock.query.return_value.filter.return_value.first.return_value = mock_category
    db_mock.delete.return_value = None
    db_mock.commit.return_value = None

    # Call the delete_category function
    result = await delete_category(db_mock, category_id)

    # Asserts for result
    assert result == True