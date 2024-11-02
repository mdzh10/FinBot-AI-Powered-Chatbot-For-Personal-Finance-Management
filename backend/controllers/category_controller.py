from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from config.db.database import get_db
from services.category_service import delete_category

router = APIRouter()

# Delete Category
@router.delete("/categories/{category_id}", response_model=dict)
async def remove_category(category_id: int, db: Session = Depends(get_db)):
    success = await delete_category(db, category_id)
    if not success:
        raise HTTPException(status_code=404, detail="Category not found")
    return {"detail": "Category deleted successfully"}
