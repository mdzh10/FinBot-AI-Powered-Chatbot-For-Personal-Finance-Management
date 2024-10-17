from pydantic import BaseModel

class UserCreate(BaseModel):
    email: str
    password: str
    username: str  # New field
    phone_number: str  # New field

class UserLogin(BaseModel):
    email: str
    password: str