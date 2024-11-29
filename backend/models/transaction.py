from sqlalchemy import Column, Integer, Float, DateTime, String, Enum, ForeignKey
from sqlalchemy.orm import relationship
from config.db.database import Base
import enum
from datetime import datetime

class PaymentTypeEnum(enum.Enum):
    debit = "debit"
    credit = "credit"

class Transaction(Base):
    __tablename__ = 'transactions'

    # Primary key for Transaction
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)  # Foreign key to User
    
    # Foreign keys to Account and Category tables
    account_id = Column(Integer, ForeignKey('accounts.id'), nullable=False)
    category_id = Column(Integer, ForeignKey('categories.id'), nullable=False)

    # Transaction details
    amount = Column(Float, nullable=False)
    type = Column(Enum(PaymentTypeEnum), nullable=False)
    datetime = Column(DateTime, default=datetime.utcnow)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    isExceed = Column(String, nullable=False, default=False)

    # Relationships to Account and Category
    account = relationship("Account", back_populates="transactions")
    category = relationship("Category", back_populates="transactions")
    user = relationship("User", back_populates="transactions")  # Link to User

    def __repr__(self):
        return f"<Transaction(id={self.id}, title={self.title}, amount={self.amount})>"
