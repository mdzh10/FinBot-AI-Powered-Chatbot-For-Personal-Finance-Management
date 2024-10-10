from fastapi import FastAPI
from authentication import router as auth_router  # Import the router, not the app
from database import database  # Import from the new database.py

app = FastAPI()

# Include authentication router
app.include_router(auth_router, prefix="/auth")

@app.on_event("startup")
async def startup():
    await database.connect()

@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()

@app.get("/")
async def root():
    return {"message": "Successfully connected to Supabase!"}
