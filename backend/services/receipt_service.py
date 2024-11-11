import base64
import requests
from PIL import Image
import io
import re
from fastapi import UploadFile
from config.config import settings
from sqlalchemy.orm import Session
from schemas.receipt_schema import ItemDetails, ReceiptResponse
from typing import List

# Replace 'your_gpt4_api_key' with your actual GPT-4 API key
GPT4_API_URL = "https://api.openai.com/v1/chat/completions"
MODEL = "gpt-4o"


def encode_image(image: Image.Image) -> str:
    """Encodes the image to a base64 string."""
    buffered = io.BytesIO()
    image.save(buffered, format="PNG")
    return base64.b64encode(buffered.getvalue()).decode("utf-8")


def extract_items_from_image(base64_image: str) -> List[ItemDetails]:
    """Sends the base64-encoded image to GPT-4 and extracts items."""
    # Create the payload for GPT-4
    headers = {
        "Authorization": f"Bearer {settings.GPT4_API_KEY}",
        "Content-Type": "application/json",
    }

    data = {
        "model": MODEL,
        "messages": [
            {
                "role": "system",
                "content": "You are a helpful assistant that extracts information from receipt images.",
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Extract the purchased items, their category, and price of each items from this receipt image",
                    },
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/png;base64,{base64_image}"},
                    },
                ],
            },
        ],
        "temperature": 0.0,
    }

    # Send the request to GPT-4
    response = requests.post(GPT4_API_URL, headers=headers, json=data)
    result = response.json()

    # Extract the items from the response
    extracted_text = result["choices"][0]["message"]["content"]

    # Assuming the text is structured as: item, category, price
    items = []

    # Define regex patterns to extract item, category, and price
    item_pattern = r"\*\*(.+?)\*\*"  # Extracts the item name between double asterisks
    category_pattern = (
        r"Category:\s+([A-Za-z\s]+)"  # Extracts the category after "Category:"
    )
    price_pattern = r"Price:\s+\$(\d+\.\d{2})"  # Extracts the price after "Price:"

    # Find all matches for item names, categories, and prices
    item_matches = re.findall(item_pattern, extracted_text)
    category_matches = re.findall(category_pattern, extracted_text)
    price_matches = re.findall(price_pattern, extracted_text)

    # Zip the results together to create structured data
    for item, category, price in zip(item_matches, category_matches, price_matches):
        items.append(
            ItemDetails(
                item_name=item.strip(),
                category=category.strip(),
                price=float(price.strip()),
            )
        )

    return items


async def process_receipt(file: UploadFile) -> ReceiptResponse:
    """Processes the receipt image and extracts items, saving them to the database."""
    image = Image.open(io.BytesIO(await file.read()))
    base64_image = encode_image(image)

    extracted_items = extract_items_from_image(base64_image)
    items = []

    # Prepare response without saving to the database
    for item in extracted_items:
        items.append(
            ItemDetails(
                id=None,  # No ID since we're not saving to the database
                item_name=item.item_name,
                category=item.category,
                price=item.price,
            )
        )

    # Return the list of items as the response
    return ReceiptResponse(items=items)
