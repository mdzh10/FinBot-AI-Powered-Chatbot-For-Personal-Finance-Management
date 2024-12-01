import pytest
from fastapi.testclient import TestClient
from main import app
from datetime import datetime
from unittest.mock import MagicMock
from services.account_service import (
    add_new_account,
    get_all_accounts,
    update_account,
    delete_account,
)
from schemas.account_schema import (
    AccountResponse,
    AccountCreate,
    AccountDetails,
)

client = TestClient(app)

# Mock data for accounts
mock_user_id = 1
mock_account = {
    "id": 1,
    "user_id": 1,
    "account_type": "cash",
    "bank_name": None,
    "account_name": "Test Account",
    "account_number": 123456,
    "balance": 1000.0,
    "credit": 200.0,
    "debit": 100.0
}
mock_accounts_list = [mock_account]
mock_create_response = {
    "msg": "Account Created successfully",
    "account": [mock_account]
}
mock_update_response = {
    "msg": "Account Updated successfully",
    "account": [mock_account]
}
mock_delete_response = {"isSuccess": True, "msg": "Account deleted successfully"}


@pytest.fixture(autouse=True)
def mock_db_services(mocker):
    """Fixture to mock database services"""
    # Mock the database calls for create, get, update, and delete accounts
    mocker.patch("services.account_service.add_new_account", return_value=mock_create_response)
    mocker.patch("services.account_service.get_all_accounts", return_value=mock_accounts_list)
    mocker.patch("services.account_service.update_account", return_value=mock_update_response)
    mocker.patch("services.account_service.delete_account", return_value=mock_delete_response)

    print("Mocking applied for add, get, update, and delete account services")


def test_create_account():
    # Mocked data for creating an account
    account_data = {
        "user_id": 1,
        "account_type": "cash",
        "account_name": "Test Account",
        "account_number": 123456,
        "balance": 1000.0
    }
    # Call the API to create an account
    response = client.post("/accounts/create", json=account_data)
    print("Create Account Response:", response.json())  # For debugging


def test_get_accounts():
    # Call the API to get accounts for the user
    response = client.get(f"/accounts/{mock_user_id}")
    print("Get Accounts Response:", response.json())  # For debugging


def test_update_account():
    # Prepare updated account data
    updated_data = {
        "id": 1,
        "user_id": 1,
        "account_type": "bank",
        "account_name": "Updated Account",
        "account_number": 654321,
        "balance": 2000.0
    }
    # Call the API to update the account
    response = client.put("/accounts/update", json=updated_data)
    print("Update Account Response:", response.json())  # For debugging


def test_delete_account():
    # Call the API to delete the account
    response = client.delete("/accounts/delete/1")
    print("Delete Account Response:", response.json())  # For debugging
