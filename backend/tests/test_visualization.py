import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
from io import BytesIO
import base64
import json
from main import app  # Assuming your FastAPI app is in main.py
from services.visualization_service import generate_visualization

# Create test client
client = TestClient(app)

# Sample test data
SAMPLE_VISUALIZATION_REQUEST = {
    "prompt": "generate a bar plot comparing total debit and credit",
    "showPopup": False
}

SAMPLE_SQL_DATA = [
    {"month": "January", "debit": 1000, "credit": 800},
    {"month": "February", "debit": 1200, "credit": 900}
]

SAMPLE_BASE64_IMAGE = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="

# Test cases for the visualization service
class TestVisualizationService:
    @pytest.fixture
    def mock_generate_sql_code(self):
        with patch('services.visualization_service.generate_sql_code') as mock:
            mock.return_value = "SELECT * FROM transactions"
            yield mock

    @pytest.fixture
    def mock_execute_sql_query(self):
        with patch('services.visualization_service.execute_sql_query') as mock:
            mock.return_value = SAMPLE_SQL_DATA
            yield mock

    @pytest.fixture
    def mock_generate_plot_code(self):
        with patch('services.visualization_service.generate_plot_code') as mock:
            # Wrap the generated code in triple backticks with "python" annotation
            mock.return_value = "```python\nimport matplotlib.pyplot as plt\nplt.plot([1, 2, 3])\nplt.show()\n```"
            yield mock

    @pytest.fixture
    def mock_execute_generated_code(self):
        with patch('services.visualization_service.execute_generated_code') as mock:
            mock.return_value = SAMPLE_BASE64_IMAGE
            yield mock

    @pytest.mark.asyncio
    async def test_generate_visualization_success(
        self,
        mock_generate_sql_code,
        mock_execute_sql_query,
        mock_generate_plot_code,
        mock_execute_generated_code
    ):
        """Test successful visualization generation"""
        result = await generate_visualization("test prompt", False)
        
        assert result["isSuccess"] is True
        assert result["msg"] == "Visualization was created successfully."
        assert result["chart"] == SAMPLE_BASE64_IMAGE
        
        mock_generate_sql_code.assert_called_once()
        mock_execute_sql_query.assert_called_once()
        mock_generate_plot_code.assert_called_once()
        mock_execute_generated_code.assert_called_once()

    @pytest.mark.asyncio
    async def test_generate_visualization_with_popup(
        self,
        mock_generate_sql_code,
        mock_execute_sql_query,
        mock_generate_plot_code,
        mock_execute_generated_code
    ):
        """Test visualization generation with popup enabled"""
        result = await generate_visualization("test prompt", True)
        
        assert result["isSuccess"] is True
        assert result["msg"] == "Visualization was displayed successfully."
        assert result["chart"] is None

    @pytest.mark.asyncio
    async def test_generate_visualization_sql_failure(
        self,
        mock_generate_sql_code
    ):
        """Test handling of SQL generation failure"""
        mock_generate_sql_code.return_value = None
        
        result = await generate_visualization("test prompt", False)
        
        assert result["isSuccess"] is False
        assert result["msg"] == "Failed to generate SQL query for data extraction"
        assert result["chart"] is None

    @pytest.mark.asyncio
    async def test_generate_visualization_data_fetch_failure(
        self,
        mock_generate_sql_code,
        mock_execute_sql_query
    ):
        """Test handling of data fetch failure"""
        mock_execute_sql_query.return_value = None
        
        result = await generate_visualization("test prompt", False)
        
        assert result["isSuccess"] is False
        assert result["msg"] == "Failed to fetch data with generated SQL query"
        assert result["chart"] is None
