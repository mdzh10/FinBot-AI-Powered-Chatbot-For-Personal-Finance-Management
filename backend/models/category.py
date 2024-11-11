from sqlalchemy import Column, Integer, String, Float
from config.db.database import Base


class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)
    budget = Column(Float, nullable=True, default=0)
    expense = Column(Float, nullable=True, default=0)

    def __repr__(self):
        return f"<Category(category_id={self.id}, category_name={self.name}, budget={self.budget}, expense={self.expense})>"
