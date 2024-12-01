import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from main import app  # Import main.py from the backend directory
from config.db.database import (
    get_db,
)  # Adjust this import path based on your project structure
from config.db.database import Base  # Adjust the import for your declarative base
from config.config import settings

# Configure an in-memory SQLite database for testing
engine = create_engine(
    settings.DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="module")
def test_db():
    # Create tables in the database
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="module")
def client(test_db):
    # Override the get_db dependency
    def override_get_db():
        try:
            yield test_db
        finally:
            test_db.close()

    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
