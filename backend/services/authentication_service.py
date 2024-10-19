from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from models.user import User
from schemas.authentication_schema import UserResponse, LoginResponse, ErrorResponse

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

async def handle_sign_up(user, db: Session):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        return ErrorResponse(msg="Email already registered")
    
    hashed_password = get_password_hash(user.password)
    new_user = User(
        email=user.email,
        password_hash=hashed_password,
        username=user.username,
        phone_number=user.phone_number
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return UserResponse(
        user_id=new_user.user_id,
        email=new_user.email,
        username=new_user.username,
        phone_number=new_user.phone_number,
        msg="User registered successfully!"
    )

async def handle_login(user, db: Session):
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user:
        return ErrorResponse(msg="Email not found")
    
    if not verify_password(user.password, db_user.password_hash):
        return ErrorResponse(msg="Invalid credentials")
    
    access_token = create_access_token(data={"sub": db_user.email})
    return LoginResponse(
        access_token=access_token,
        user_id=db_user.user_id,
        email=db_user.email,
        username=db_user.username,
        phone_number=db_user.phone_number
    )
