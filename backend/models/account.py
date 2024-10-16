from sqlalchemy import Column, Integer, String, Float, Enum
from db.database import Base
import enum

class AccountType(enum.Enum):
    cash = "cash"
    bank = "bank"

class Account(Base):
    __tablename__ = "accounts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    account_type = Column(Enum(AccountType), nullable=False)  # cash or bank
    bank_name = Column(String, nullable=True)  # Only applicable for bank accounts
    account_name = Column(String, nullable=False)  # e.g., 'John Doe Checking'
    account_number = Column(String, nullable=True)  # Bank account number
    routing_number = Column(String, nullable=True)  # Routing number for bank accounts
    balance = Column(Float, default=0.0)  # Current balance of the account

    def __repr__(self):
        return f"<Account(id={self.id}, account_name={self.account_name}, balance={self.balance})>"
