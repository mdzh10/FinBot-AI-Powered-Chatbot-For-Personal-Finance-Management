import pytest
from datetime import datetime
from unittest.mock import MagicMock
from sqlalchemy.orm import Session
from fastapi import HTTPException

from models.transaction import Transaction, PaymentTypeEnum
from models.account import Account
from models.category import Category
from schemas.transaction_schema import (
    TransactionCreate,
    TransactionUpdate,
    TransactionDetails,
)
from services.transaction_service import (
    get_all_transactions,
    add_transaction,
    update_transaction,
    delete_transaction_by_id,
)


@pytest.fixture
def db_session():
    """Fixture to create a mocked SQLAlchemy session."""
    return MagicMock(spec=Session)


@pytest.fixture
def sample_transaction():
    """Fixture to create a sample transaction."""
    return Transaction(
        id=1,
        user_id=1,
        account_id=1,
        category_id=1,
        title="coke",
        description="",
        amount=100,
        type="debit",
        datetime=datetime.now(),
    )


@pytest.fixture
def sample_account():
    """Fixture to create a sample account."""
    return Account(
        id=8,
        user_id=1,
        balance=710,
        credit=200,
        debit=90,
    )


@pytest.fixture
def sample_category():
    """Fixture to create a sample category."""
    return Category(
        id=1,
        user_id=1,
        name="string",
        expense=10,
    )


### Test: Get All Transactions
@pytest.mark.asyncio
async def test_get_all_transactions(db_session, sample_transaction, sample_account, sample_category):
    db_session.query.return_value.filter.return_value.all.return_value = [sample_transaction]
    db_session.query.return_value.filter.return_value.all.side_effect = [
        [sample_transaction],  # Transactions
        [sample_account],      # Accounts
        [sample_category],     # Categories
    ]

    response = await get_all_transactions(db_session, user_id=1)
    print(response)


### Test: Add Transaction
@pytest.mark.asyncio
async def test_add_transaction(db_session, sample_account, sample_category):
    transaction_data = TransactionCreate(
        user_id=1,
        account_id=8,
        category_id=1,
        title="New Transaction",
        description="Adding a test transaction",
        amount=100,
        type="debit",
        datetime=datetime.now(),
    )
    
    db_session.add.return_value = None
    db_session.refresh.side_effect = lambda obj: setattr(obj, "id", 1)  

    db_session.query.return_value.filter.return_value.first.side_effect = [
        sample_account,  
        sample_category, 
    ]

    response = await add_transaction(db_session, transaction_data)

    assert response.msg == "Transaction created successfully"
    assert response.transactions[0].id == 1

@pytest.mark.asyncio
async def test_update_transaction(db_session, sample_transaction, sample_account, sample_category):
    transaction = TransactionUpdate(
        id=1,
        user_id=1,
        account_id=8,
        category_id=1,
        title="Updated Transaction",
        description="Updated description",
        amount=150,
        type=PaymentTypeEnum.debit,
        datetime=datetime.now(),
    )

    # Mock responses for queries
    db_session.query.return_value.filter.return_value.first.side_effect = [
        sample_transaction, 
        sample_account,     
        sample_category,     
        sample_category,    
    ]

    # Mock `type` attribute
    if isinstance(transaction.type, PaymentTypeEnum):
        sample_transaction.type = transaction.type
    else:
        sample_transaction.type = PaymentTypeEnum[transaction.type]

    # Call the service function
    response = await update_transaction(db_session, transaction)

    # Assertions
    assert response.msg == "Transaction updated successfully"
    assert response.transactions[0].title == "Updated Transaction"
    assert response.transactions[0].amount == 150


### Test: Delete Transaction
@pytest.mark.asyncio
async def test_delete_transaction_by_id(db_session, sample_transaction, sample_account, sample_category):
    db_session.query.return_value.filter.return_value.first.side_effect = [
        sample_transaction, 
        sample_account,     
        sample_category,    
    ]

    response = await delete_transaction_by_id(db_session, transaction_id=1)

    assert response is True
    db_session.delete.assert_called_once_with(sample_transaction)
