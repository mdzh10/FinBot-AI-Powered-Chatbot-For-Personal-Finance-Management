from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import create_engine
from databases import Database
from config.config import settings
import os


if settings is not None and settings.DATABASE_URL is not None:
    database = Database(settings.DATABASE_URL)
    engine = create_engine(settings.DATABASE_URL)
else:
    database = Database(os.getenv("DATABASE_URL"))
    engine = create_engine(os.getenv("DATABASE_URL"))

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# Dependency to get a SQLAlchemy session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Ensure models are created in the database
def create_tables():
    Base.metadata.create_all(
        bind=engine
    )  # This should create all tables based on models
    print("Tables created successfully.")  # Add this for debugging
