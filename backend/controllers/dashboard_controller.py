from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from services.dashboard_service import calculate_total_balance, get_debits_credits_in_date_range
from db.database import get_db
from schemas.dashboard_schema import DashboardResponse
from datetime import datetime

router = APIRouter()

@router.get("/{user_id}", response_model=DashboardResponse)
async def get_dashboard_data(
    user_id: int, 
    start_date: datetime = Query(..., description="Start date for filtering transactions"), 
    end_date: datetime = Query(..., description="End date for filtering transactions"), 
    db: Session = Depends(get_db)
):
    # Calculate total balance for the user
    total_balance = await calculate_total_balance(db, user_id)
    
    # Get debits and credits within the date range
    debits, credits = await get_debits_credits_in_date_range(db, user_id, start_date, end_date)
    
    # Return the dashboard data
    return DashboardResponse(total_balance=total_balance, debits=debits, credits=credits)
