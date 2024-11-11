from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.orm import relationship
from config.db.database import Base

class Category(Base):
    __tablename__ = "categories"

    # Primary key for Category
    id = Column(Integer, primary_key=True, autoincrement=True)
    
    # Category details
    name = Column(String, nullable=False)
    budget = Column(Float, nullable=True, default=0)
    expense = Column(Float, nullable=True, default=0)

    # Relationship to Transaction (one-to-many)
    transactions = relationship(
        "Transaction", back_populates="category", cascade="all, delete-orphan"
    )

    def __repr__(self):
        return f"<Category(id={self.id}, name={self.name}, budget={self.budget}, expense={self.expense})>"
