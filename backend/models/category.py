from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from config.db.database import Base

class Category(Base):
    __tablename__ = "categories"

    category_id = Column(Integer, primary_key=True, index=True)
    category_name = Column(String, nullable=False, unique=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    def __repr__(self):
        return f"<Category(category_id={self.category_id}, category_name={self.category_name})>"
