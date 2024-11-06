from sqlalchemy import Column, Integer, String, Float
from config.db.database import Base


class ReceiptItem(Base):
    __tablename__ = "receipts"

    id = Column(Integer, primary_key=True, index=True)
    item_name = Column(String, nullable=False)
    category = Column(String, nullable=False)
    price = Column(Float, nullable=False)
    quantity = Column(Integer, nullable=False)

    def __repr__(self):
        return f"<ReceiptItem(id={self.id}, name={self.item_name}, price={self.price}, category={self.category})>"
