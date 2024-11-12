from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from config.db.database import Base


class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    email = Column(String, unique=True, index=True)
    password_hash = Column(String)
    username = Column(String, nullable=False)  # New field
    phone_number = Column(String, nullable=False)  # New field

    # Relationship to Account
    accounts = relationship(
        "Account", back_populates="user", cascade="all, delete-orphan"
    )

    # Relationship to Transaction (if applicable)
    transactions = relationship(
        "Transaction", back_populates="user", cascade="all, delete-orphan"
    )

    categories = relationship(
        "Category", back_populates="user", cascade="all, delete-orphan"
    )
