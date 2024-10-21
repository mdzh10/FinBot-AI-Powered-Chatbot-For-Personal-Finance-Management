from fastapi import APIRouter, UploadFile, File, Depends
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.receipt_service import process_receipt
from schemas.receipt_schema import ItemDetails
from typing import List

router = APIRouter()

@router.post("/extract-items/", response_model=List[ItemDetails])
async def extract_items(file: UploadFile = File(...), db: Session = Depends(get_db)):
    # Process the receipt and save items to the database
    items = await process_receipt(file, db)
    return items