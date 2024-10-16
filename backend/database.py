from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import create_engine
from databases import Database

# Supabase connection URL
DATABASE_URL = "postgresql://postgres.mfivqyuherbwkffunohv:aminiTheGreat123@aws-0-us-east-1.pooler.supabase.com:6543/postgres"

database = Database(DATABASE_URL)
engine = create_engine(DATABASE_URL)
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
    Base.metadata.create_all(bind=engine)  # This should create all tables based on models
    print("Tables created successfully.")  # Add this for debugging

