import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
from PIL import Image
import io
from main import app  # Assuming your FastAPI app is in main.py
from services.receipt_service import encode_image, extract_items_from_image
from schemas.receipt_schema import ItemDetails

# Create test client
client = TestClient(app)

# Sample test data
SAMPLE_BASE64_IMAGE = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="

SAMPLE_EXTRACTED_ITEMS = [
    {"item_name": "Coffee", "price": 4.99},
    {"item_name": "Sandwich", "price": 8.99}
]

SAMPLE_GPT4_RESPONSE = {
    "choices": [
        {
            "message": {
                "content": """
                - Coffee: $4.99
                - Sandwich: $8.99
                """
            }
        }
    ]
}

class TestReceiptService:
    """Test suite for the receipt processing service"""

    @pytest.fixture
    def mock_image(self):
        """Fixture for mocking PIL Image"""
        mock_img = MagicMock(spec=Image.Image)
        mock_img.save = MagicMock()
        return mock_img

    @pytest.fixture
    def mock_upload_file(self):
        """Fixture for mocking FastAPI UploadFile"""
        mock_file = MagicMock()
        mock_file.read = MagicMock(return_value=b"fake_image_bytes")
        return mock_file

    @pytest.fixture
    def mock_requests_post(self):
        """Fixture for mocking requests.post"""
        with patch('requests.post') as mock:
            mock.return_value.json.return_value = SAMPLE_GPT4_RESPONSE
            yield mock

    def test_encode_image(self, mock_image):
        """Test image encoding functionality"""
        mock_buffer = io.BytesIO(b"test_image_data")
        with patch('io.BytesIO', return_value=mock_buffer):
            result = encode_image(mock_image)
            
            assert isinstance(result, str)
            assert mock_image.save.called
            mock_image.save.assert_called_with(mock_buffer, format="PNG")

    

    def test_extract_items_from_image(self, mock_requests_post):
        """Test extraction of items from image"""
        # Mocking the response from GPT-4 API
        mock_requests_post.return_value.json.return_value = SAMPLE_GPT4_RESPONSE

        # Call the extraction function
        extracted_items = extract_items_from_image(SAMPLE_BASE64_IMAGE)
        
        # Validate that two items were extracted
        assert len(extracted_items) == 2
        assert all(isinstance(item, ItemDetails) for item in extracted_items)
        assert extracted_items[0].item_name == "Coffee"
        assert extracted_items[0].price == 4.99
        assert extracted_items[1].item_name == "Sandwich"
        assert extracted_items[1].price == 8.99

    def test_extract_items_gpt4_error(self, mock_requests_post):
        """Test handling of GPT-4 API errors"""
        # Simulating an API error
        mock_requests_post.return_value.json.side_effect = Exception("API Error")
        
        with pytest.raises(Exception):
            extract_items_from_image(SAMPLE_BASE64_IMAGE)