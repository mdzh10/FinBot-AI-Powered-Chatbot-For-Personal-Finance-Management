from dotenv import load_dotenv
import os

# Load .env only for local development
load_dotenv(dotenv_path="./config/.env", verbose=True)


class Settings:
    if os.path.exists("/var/secrets/DB/DATABASE_URL"):
        DATABASE_URL: str = open("/var/secrets/DB/DATABASE_URL").read().strip()
        print("got db url from volume")
    else:
        DATABASE_URL: str = os.getenv("DATABASE_URL")

    if os.path.exists("/var/secrets/GPT/GPT4_API_KEY"):
        GPT4_API_KEY: str = open("/var/secrets/GPT/GPT4_API_KEY").read().strip()
        print("got gpt key from volume")

    else:
        GPT4_API_KEY: str = os.getenv("GPT4_API_KEY")


settings = Settings()
