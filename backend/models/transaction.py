from sqlalchemy import Column, Integer, Float, String, Enum, ForeignKey, DateTime
from datetime import datetime
from config.db.database import Base
import enum

class TransactionType(enum.Enum):
    debit = "debit"
    credit = "credit"

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    account_id = Column(Integer, ForeignKey('accounts.id'), nullable=False)  # Reference to the accounts table
    category_id = Column(Integer, nullable=False)  # Category ID for categorizing the transaction
    item_name = Column(String, nullable=False)  # Item name e.g., Groceries
    quantity = Column(Integer, default=1)  # Quantity of items purchased or affected
    amount = Column(Float, nullable=False)  # Transaction amount
    transaction_type = Column(Enum(TransactionType), nullable=False)  # Debit or Credit
    transaction_date = Column(DateTime, default=datetime.utcnow)  # Date of the transaction

    def __repr__(self):
        return f"<Transaction(id={self.id}, amount={self.amount}, type={self.transaction_type}, account_id={self.account_id})>"
