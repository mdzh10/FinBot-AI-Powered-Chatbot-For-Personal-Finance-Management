import requests
from datetime import datetime, timedelta


def test_get_dashboard_data():
    """
    Test fetching dashboard data for a user within a given date range.
    Verifies total balance, debit, and credit calculations.
    """
    # Define the base URL for the deployed service
    base_url = "http://localhost:8000"

    # Test data
    user_id = 1
    start_date = (datetime.now() - timedelta(days=30)).isoformat()
    end_date = datetime.now().isoformat()

    # Act: Call the dashboard endpoint
    response = requests.get(
        f"{base_url}/dashboard/{user_id}",
        params={
            "start_date": start_date,
            "end_date": end_date,
        },
    )

    # Assert: Validate the response
    assert response.status_code == 200
    response_data = response.json()

    # Example assertions (update these based on your expected data)
    assert "total_balance" in response_data
    assert "debits" in response_data
    assert "credits" in response_data

    # Print the results for debugging purposes
    print("Response Data:", response_data)
