from fastapi import APIRouter, UploadFile, File
from services.receipt_service import process_receipt
from schemas.receipt_schema import ItemDetails
from typing import List

router = APIRouter()

@router.post("/extract-items/", response_model=List[ItemDetails])
async def extract_items(file: UploadFile = File(...)):
    items = await process_receipt(file)
    return items