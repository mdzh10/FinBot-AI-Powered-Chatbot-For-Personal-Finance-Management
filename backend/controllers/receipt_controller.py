from fastapi import APIRouter, HTTPException, UploadFile, File, Depends
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.receipt_service import process_receipt
from schemas.receipt_schema import ReceiptResponse

router = APIRouter()


@router.post("/extract-items/", response_model=ReceiptResponse)
async def extract_items(file: UploadFile = File(...), db: Session = Depends(get_db)):
    try:
        return await process_receipt(file, db)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
