import pytest 
from fastapi.testclient import TestClient
from main import app
from datetime import datetime
from unittest.mock import MagicMock
from models.transaction import PaymentTypeEnum
from services.transaction_service import (
    add_transaction,  # Update the function names if they are different in your code
    get_all_transactions,
    update_transaction,
    delete_transaction_by_id,
)
from schemas.transaction_schema import (
    TransactionListResponse,
    TransactionCreate,
    TransactionUpdate,
    TransactionDetails
)

client = TestClient(app)

# Mock data for transactions
mock_user_id = 1
mock_start_date = datetime(2024, 1, 1)
mock_end_date = datetime(2024, 12, 31)
mock_transaction = {
    "id": 1,
    "user_id": 1,
    "account": {"id": 8, "balance": 500.0},
    "category": {"id": 1, "expense": 0.0},
    "title": "Test Transaction",
    "amount": 100.0,
    "type": "debit",
    "datetime": "2024-11-01T10:00:00"
}
mock_transactions_list = [mock_transaction]
mock_create_response = {
    "msg": "Transaction created successfully",
    "transactions": [mock_transaction]
}
mock_update_response = {
    "msg": "Transaction updated successfully",
    "transactions": [mock_transaction]
}
mock_delete_response = {"isSuccess": True, "msg": "Transaction deleted successfully"}


@pytest.fixture(autouse=True)
def mock_db_services(mocker):
    """Fixture to mock database services"""
    # Mock the database calls for create, get, update, and delete transactions
    mocker.patch("services.transaction_service.add_transaction", return_value=mock_create_response)
    mocker.patch("services.transaction_service.get_all_transactions", return_value=mock_transactions_list)
    mocker.patch("services.transaction_service.update_transaction", return_value=mock_update_response)
    mocker.patch("services.transaction_service.delete_transaction_by_id", return_value=mock_delete_response)

    print("Mocking applied for add, get, update, and delete transaction services")


def test_create_transaction():
    # Mocked data for creating a transaction
    transaction_data = {
        "user_id": 1,
        "account_id": 8,
        "category_id": 1,
        "title": "Test Transaction",
        "description": "A test transaction",
        "amount": 100.0,
        "type": "debit",
        "datetime": "2024-11-01T10:00:00"
    }
    # Call the API to create a transaction
    response = client.post("/transactions/add", json=transaction_data)
    print("Create Transaction Response:", response.json())  # For debugging


def test_get_transactions():
    # Call the API to get transactions for the user
    response = client.get(
        f"/transactions/{mock_user_id}",
        params={"start_date": mock_start_date.isoformat(), "end_date": mock_end_date.isoformat()}
    )
    print("Get Transactions Response:", response.json())  # For debugging


def test_update_transaction():
    # Prepare updated transaction data
    updated_data = {
        "id": 1,
        "user_id": 1,
        "account_id": 8,
        "category_id": 2,
        "title": "Updated Transaction",
        "description": "Updated description",
        "amount": 200.0,
        "type": "credit",
        "datetime": "2024-11-02T12:00:00"
    }
    # Call the API to update the transaction
    response = client.put("/transactions/modify", json=updated_data)
    print("Update Transaction Response:", response.json())  # For debugging


def test_delete_transaction():
    # Call the API to delete the transaction
    response = client.delete("/transactions/delete/1")
    print("Delete Transaction Response:", response.json())  # For debugging
