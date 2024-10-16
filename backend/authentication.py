from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import null
from sqlalchemy.orm import Session
from database import get_db
from models import User

# Add your generated SECRET_KEY here
SECRET_KEY = "d9b1f8e0e2a3a9b2a45a0d5fb53d6ea6a1cdbb627ff5aa3a7091f5c8dfc8c3d3"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# Create a router instead of an app
router = APIRouter()

# Pydantic models for input validation
class UserCreate(BaseModel):
    email: str
    password: str
    username: str  # New field
    phone_number: str  # New field

class UserLogin(BaseModel):
    email: str
    password: str

# API to register a new user
@router.post("/signup")
async def sign_up(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        return {
            "isSuccess": False,
            "msg": "Email already registered",
            "user_id": null,
            "email": null,
            "username": null,
            "phone_number": null
        }
    
    hashed_password = get_password_hash(user.password)
    new_user = User(
        email=user.email,
        password_hash=hashed_password,
        username=user.username,  # Set the username
        phone_number=user.phone_number  # Set the phone number
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {
        "isSuccess": True,
        "msg": "User registered successfully!",
        "user_id": new_user.user_id,
        "email": new_user.email,
        "username": new_user.username,
        "phone_number": new_user.phone_number
    }


# API to log in an existing user
@router.post("/login")
async def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user:
        return {
            "isSuccess": False,
            "msg": "Email not found",
            "access_token": null,
            "token_type": null,
            "user_id": null,
            "email": null,
            "username": null,  # Include username in response
            "phone_number": null
        }
    
    if not verify_password(user.password, db_user.password_hash):
        return {
            "isSuccess": False,
            "msg": "Invalid credentials",
            "access_token": null,
            "token_type": null,
            "user_id": null,
            "email": null,
            "username": null,  # Include username in response
            "phone_number": null
        }
    
    access_token = create_access_token(data={"sub": db_user.email})
    return {
        "isSuccess": True,
        "msg": "Login successful",
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": db_user.user_id,
        "email": db_user.email,
        "username": db_user.username,  # Include username in response
        "phone_number": db_user.phone_number  # Include phone number in response
    }
