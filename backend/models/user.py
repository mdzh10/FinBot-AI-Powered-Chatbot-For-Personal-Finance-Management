from sqlalchemy import Column, Integer, String
from config.db.database import Base


class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    password_hash = Column(String)
    username = Column(String, nullable=False)  # New field
    phone_number = Column(String, nullable=False)  # New field
