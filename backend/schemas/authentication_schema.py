from pydantic import BaseModel
from typing import Optional


class UserCreate(BaseModel):
    email: str
    password: str
    username: str  # New field
    phone_number: str  # New field


class UserLogin(BaseModel):
    email: str
    password: str


class UserResponse(BaseModel):
    user_id: Optional[int] = None
    email: Optional[str] = None
    username: Optional[str] = None
    phone_number: Optional[str] = None
    isSuccess: bool = True
    msg: str = "Operation successful"


class LoginResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Login successful"
    access_token: str
    token_type: str = "bearer"
    user_id: int
    email: str
    username: str
    phone_number: str


class ErrorResponse(BaseModel):
    isSuccess: bool = False
    msg: str
