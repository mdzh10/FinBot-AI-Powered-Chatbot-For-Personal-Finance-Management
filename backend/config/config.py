import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


class Settings:
    DATABASE_URL: str = os.getenv("DATABASE_URL")
    GPT4_API_KEY: str = os.getenv("GPT4_API_KEY")


settings = Settings()
