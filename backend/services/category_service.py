from sqlalchemy.orm import Session
from models.category import Category

# Delete Category
async def delete_category(db: Session, category_id: int) -> bool:
    existing_category = db.query(Category).filter(Category.category_id == category_id).first()
    if existing_category:
        db.delete(existing_category)
        db.commit()
        return True
    return False
