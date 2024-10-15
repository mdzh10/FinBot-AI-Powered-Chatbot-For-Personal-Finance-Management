from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from database import get_db  # Now importing from database.py
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
            "msg": "Email already registered"
        }
    
    hashed_password = get_password_hash(user.password)
    new_user = User(email=user.email, password_hash=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {
        "isSuccess": True,
        "msg": "User registered successfully!"
    }


# API to log in an existing user
@router.post("/login")
async def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user:
        return {
            "isSuccess": False,
            "msg": "Email not found"
        }
    
    if not verify_password(user.password, db_user.password_hash):
        return {
            "isSuccess": False,
            "msg": "Invalid credentials"
        }
    
    access_token = create_access_token(data={"sub": db_user.email})
    return {
        "isSuccess": True,
        "msg": "Login successful",
        "access_token": access_token,
        "token_type": "bearer"
    }

