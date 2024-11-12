from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from config.db.database import Base

class Category(Base):
    __tablename__ = "categories"

    # Primary key for Category
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)  # Foreign key to User
    
    # Category details
    name = Column(String, nullable=False)
    budget = Column(Float, nullable=False, default=0.0)
    expense = Column(Float, nullable=False, default=0.0)

    # Relationship to Transaction (one-to-many)
    transactions = relationship(
        "Transaction", back_populates="category", cascade="all, delete-orphan"
    )
    user = relationship("User", back_populates="categories")  # Link to User

    def __repr__(self):
        return f"<Category(id={self.id}, name={self.name}, budget={self.budget}, expense={self.expense})>"
