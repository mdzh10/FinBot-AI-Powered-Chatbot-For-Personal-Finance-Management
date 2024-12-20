import base64
from datetime import datetime
import requests
from PIL import Image
import io
import re
import os
from fastapi import UploadFile
from models.transaction import PaymentTypeEnum
from schemas.transaction_schema import TransactionCreate
from config.config import settings
from schemas.receipt_schema import ItemDetails, ReceiptResponse
from typing import List

# Replace 'your_gpt4_api_key' with your actual GPT-4 API key
GPT4_API_URL = "https://api.openai.com/v1/chat/completions"
MODEL = "gpt-4o"

if settings is not None and settings.GPT4_API_KEY is not None:
    GPT4_API_KEY = settings.GPT4_API_KEY
else:
    GPT4_API_KEY = os.getenv("GPT4_API_KEY")


def encode_image(image: Image.Image) -> str:
    """Encodes the image to a base64 string."""
    buffered = io.BytesIO()
    image.save(buffered, format="PNG")
    return base64.b64encode(buffered.getvalue()).decode("utf-8")


def clean_item_and_price(item, price):
    # Remove non-alphabetic characters from the item name
    clean_item = re.sub(r"[^a-zA-Z\s]", "", item).strip()
    # Remove non-numeric characters from the price
    clean_price = re.sub(r"[^0-9.]", "", price).strip()
    # Convert price to float
    try:
        clean_price = float(clean_price)
    except ValueError:
        clean_price = 0.0  # Default to 0.0 if conversion fails
    return clean_item, clean_price


def extract_items_from_image(base64_image: str) -> List[ItemDetails]:
    """Sends the base64-encoded image to GPT-4 and extracts items."""
    # Create the payload for GPT-4
    headers = {
        "Authorization": f"Bearer {GPT4_API_KEY}",
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
                        # "text": "Extract the purchased items, their category, and price of each items from this receipt image",
                        "text": "Extract the purchased items and price of each items from this receipt image in item-price pair such that all responses are in same format. Do not add any explanation with your response",
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

    # Split the extracted text into lines
    lines = extracted_text.splitlines()
    print(lines)
    # Process each line to find matches
    for line in lines:
        # Regex to split the line into item and price
        match = re.match(r"(.*?)(\d+(\.\d+)?$)", line.strip())
        if match:
            raw_item = match.group(1)
            raw_price = match.group(2)
            # Clean the extracted item and price
            item_name, price = clean_item_and_price(raw_item, raw_price)
            items.append(ItemDetails(item_name=item_name, price=price))

    return items


async def process_receipt(user_id, file: UploadFile) -> ReceiptResponse:
    """Processes the receipt image and extracts items, saving them to the database."""
    image = Image.open(io.BytesIO(await file.read()))
    base64_image = encode_image(image)

    extracted_items = extract_items_from_image(base64_image)
    transactions = []

    # Prepare response without saving to the database
    for transaction in extracted_items:
        transactions.append(
            TransactionCreate(
                user_id=user_id,
                account_id=0,
                category_id=None,
                title=transaction.item_name,
                description="",
                amount=transaction.price,
                type=PaymentTypeEnum.debit,
                datetime=datetime.now(),
            )
        )

    # Return the list of items as the response
    return ReceiptResponse(transactions=transactions)
