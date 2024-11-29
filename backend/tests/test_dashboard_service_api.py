import pytest
from unittest.mock import MagicMock
from datetime import datetime
from services.dashboard_service import calculate_total_balance, get_debits_credits_in_date_range
from models.transaction import PaymentTypeEnum

# Mock data
mock_user_id = 1
mock_start_date = datetime(2024, 1, 1)
mock_end_date = datetime(2024, 12, 31)
mock_total_balance = 4776.0
mock_debits = 110.0
mock_credits = 400.0

# Mocked db session
@pytest.fixture
def mock_db_session():
    # Create a MagicMock for the DB session
    mock_db = MagicMock()
    return mock_db


# Test for calculate_total_balance function
@pytest.mark.asyncio  # Mark this as an asynchronous test
async def test_calculate_total_balance(mock_db_session):
    # Set up mock return value for the query
    mock_db_session.query.return_value.filter.return_value.scalar.return_value = mock_total_balance

    # Call the function
    result = await calculate_total_balance(mock_db_session, mock_user_id)

    # Assert that the result matches the mocked total balance
    assert result == mock_total_balance
    mock_db_session.query.return_value.filter.return_value.scalar.assert_called_once()  # Ensure the query was called


# Test for get_debits_credits_in_date_range function
@pytest.mark.asyncio  # Mark this as an asynchronous test
async def test_get_debits_credits_in_date_range(mock_db_session):
    # Set up mock return values for debits and credits
    mock_db_session.query.return_value.filter.return_value.scalar.side_effect = [mock_debits, mock_credits]

    # Call the function
    debits, credits = await get_debits_credits_in_date_range(mock_db_session, mock_user_id, mock_start_date, mock_end_date)

    # Assert that debits and credits match the mocked values
    assert debits == mock_debits
    assert credits == mock_credits

    # Ensure the correct queries are called for debits and credits
    mock_db_session.query.return_value.filter.return_value.scalar.assert_any_call()
    mock_db_session.query.return_value.filter.return_value.scalar.assert_any_call()


# Test for handling no debits or credits (should return 0.0)
@pytest.mark.asyncio  # Mark this as an asynchronous test
async def test_get_debits_credits_no_data(mock_db_session):
    # Set up mock return values for debits and credits as None (no data)
    mock_db_session.query.return_value.filter.return_value.scalar.side_effect = [None, None]

    # Call the function
    debits, credits = await get_debits_credits_in_date_range(mock_db_session, mock_user_id, mock_start_date, mock_end_date)

    # Assert that debits and credits are returned as 0.0 if no data
    assert debits == 0.0
    assert credits == 0.0
