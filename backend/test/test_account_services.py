import pytest
from datetime import datetime
from unittest.mock import MagicMock
from sqlalchemy.orm import Session
from fastapi import HTTPException

from models.account import Account, AccountType
from schemas.account_schema import AccountCreate, AccountDetails, AccountResponse
from services.account_service import get_all_accounts, add_new_account, update_account, delete_account


@pytest.fixture
def db_session():
    """Fixture to create a mocked SQLAlchemy session."""
    return MagicMock(spec=Session)


@pytest.fixture
def sample_account():
    """Fixture to create a sample account."""
    return Account(
        id=1,
        user_id=1,
        account_type=AccountType.cash,
        bank_name=None,
        account_name="John Doe Checking",
        account_number=123456,
        balance=1000.0,
        credit=500.0,
        debit=200.0,
    )


### Test: Get All Accounts
@pytest.mark.asyncio
async def test_get_all_accounts(db_session, sample_account):
    db_session.query.return_value.filter.return_value.all.return_value = [sample_account]

    response = await get_all_accounts(db_session, user_id=1)

    assert response["isSuccess"] is True
    assert len(response["account"]) == 1
    assert response["account"][0]["id"] == 1  # Assuming response["account"][0] is a dict
    assert response["account"][0]["account_name"] == "John Doe Checking"  # Assuming it's a dict


# Test: Add New Account
@pytest.mark.asyncio
async def test_add_new_account(db_session, sample_account):
    account_data = AccountCreate(
        user_id=1,
        account_type=AccountType.cash,
        bank_name=None,
        account_name="John Doe Checking",
        account_number=123456,
        balance=1000.0,
    )

    db_session.query.return_value.filter.return_value.first.return_value = None
    db_session.add.return_value = None
    db_session.refresh.side_effect = lambda obj: setattr(obj, "id", 1)

    response = await add_new_account(db_session, account_data)

    assert response.msg == "Account Created successfully"
    assert response.account[0].id == 1
    assert response.account[0].account_name == "John Doe Checking"


# Test: Update Account
@pytest.mark.asyncio
async def test_update_account(db_session, sample_account):
    account_data = AccountDetails(
        id=1,
        user_id=1,
        account_name="John Doe Savings",
        balance=1500.0,
        credit=600.0,
        debit=300.0,
    )

    db_session.query.return_value.filter.return_value.first.return_value = sample_account

    response = await update_account(db_session, account_data)

    assert response.msg == "Account Updated successfully"
    assert response.account[0].account_name == "John Doe Savings"
    assert response.account[0].balance == 1500.0

### Test: Delete Account
@pytest.mark.asyncio
async def test_delete_account(db_session, sample_account):
    db_session.query.return_value.filter.return_value.first.return_value = sample_account

    response = await delete_account(db_session, account_id=1)

    assert response["isSuccess"] is True
    assert response["msg"] == "Account deleted successfully"
    db_session.delete.assert_called_once_with(sample_account)
    db_session.commit.assert_called_once()
