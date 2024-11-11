from sqlalchemy import Column, Integer, String, Float, Enum, ForeignKey
from sqlalchemy.orm import relationship
from config.db.database import Base
import enum


class AccountType(enum.Enum):
    cash = "cash"
    bank = "bank"


class Account(Base):
    __tablename__ = "accounts"

    # Primary key for Account
    id = Column(Integer, primary_key=True, index=True)
    # Foreign key relationship with User (assuming there's a User table)
    user_id = Column(
        Integer, ForeignKey("users.user_id"), nullable=False
    )  # Foreign key to User

    # Other fields
    account_type = Column(Enum(AccountType), nullable=False)  # cash or bank
    bank_name = Column(String, nullable=True)  # Only applicable for bank accounts
    account_name = Column(String, nullable=False)  # e.g., 'John Doe Checking'
    account_number = Column(Integer, nullable=True)  # Bank account number
    credit = Column(Float, default=0.0)
    debit = Column(Float, default=0.0)
    balance = Column(Float, default=0.0)  # Current balance of the account

    # Relationship to User
    user = relationship("User", back_populates="accounts")

    # Relationship to Transaction (one-to-many)
    transactions = relationship(
        "Transaction", back_populates="account", cascade="all, delete-orphan"
    )

    def __repr__(self):
        return f"<Account(id={self.id}, account_name={self.account_name}, balance={self.balance})>"
