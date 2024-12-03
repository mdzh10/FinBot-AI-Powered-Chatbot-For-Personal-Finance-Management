from fastapi import APIRouter, Form, HTTPException, UploadFile, File
from services.receipt_service import process_receipt
from schemas.receipt_schema import ReceiptResponse

router = APIRouter()


@router.post("/extract-items/", response_model=ReceiptResponse)
async def extract_items(
    user_id: int = Form(...),
    file: UploadFile = File(...),
):
    try:
        return await process_receipt(user_id, file)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
