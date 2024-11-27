from dotenv import load_dotenv
import os

print(os.getcwd())

# Load .env only for local development
load_dotenv(dotenv_path="./config/.env", override=True, verbose=True)

# class Settings:
#     if os.path.exists("./config/secrets/DATABASE_URL"):
#         DATABASE_URL: str = (
#         open("./config/secrets/DATABASE_URL").read().strip()
#     )
#         print("got db url from docker")
#     else:
#         DATABASE_URL: str = (os.getenv("DATABASE_URL"))

#     if os.path.exists("./config/secrets/GPT4_API_KEY"):
#         GPT4_API_KEY: str = (
#             open("./config/secrets/GPT4_API_KEY").read().strip()
#         )
#         print("got gpt key from docker")

#     else:
#         GPT4_API_KEY: str = (
#             os.getenv("GPT4_API_KEY")
#         )


class Settings:
    DATABASE_URL = os.getenv("DATABASE_URL")
    GPT4_API_KEY = os.getenv("GPT4_API_KEY")


settings = Settings()
