import pytest
from fastapi.testclient import TestClient
from main import app
from datetime import datetime
from services.dashboard_service import calculate_total_balance, get_debits_credits_in_date_range

client = TestClient(app)

# Mock data
mock_user_id = 1
mock_start_date = datetime(2024, 1, 1)
mock_end_date = datetime(2024, 12, 31)
mock_total_balance = 4776.0
mock_debits = 110.0
mock_credits = 400.0


@pytest.fixture(autouse=True)
def mock_dashboard_services(mocker):
    # Mock the calculate_total_balance function (Make sure you're mocking the correct path)
    mocker.patch(
        "services.dashboard_service.calculate_total_balance",
        return_value=mock_total_balance,
    )
    # Mock the get_debits_credits_in_date_range function (Make sure you're mocking the correct path)
    mocker.patch(
        "services.dashboard_service.get_debits_credits_in_date_range",
        return_value=(mock_debits, mock_credits),
    )

    # Log to verify that the mocks are applied correctly
    print("Mocking applied for calculate_total_balance and get_debits_credits_in_date_range")


def test_get_dashboard_data():
    # Call the API to get dashboard data
    response = client.get(
        f"/dashboard/{mock_user_id}",
        params={"start_date": mock_start_date.isoformat(), "end_date": mock_end_date.isoformat()},
    )
    assert response.status_code == 200

    data = response.json()
    print("Response Data:", data)  # Add this to see what you're getting back

    # Assert the mocked data is returned correctly
    assert data["total_balance"] == mock_total_balance  # Checking total balance
    assert data["debits"] == mock_debits  # Checking debits
    assert data["credits"] == mock_credits  # Checking credits


def test_invalid_date_range():
    # Invalid date format
    response = client.get(
        f"/dashboard/{mock_user_id}",
        params={"start_date": "invalid-date", "end_date": mock_end_date.isoformat()},
    )
    assert response.status_code == 422  # Unprocessable Entity
    assert "start_date" in response.json()["detail"][0]["loc"]  # Checking for invalid date error
