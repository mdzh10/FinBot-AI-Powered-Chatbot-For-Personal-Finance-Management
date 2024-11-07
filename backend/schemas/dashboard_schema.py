from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class DateRange(BaseModel):
    start_date: datetime
    end_date: datetime


class DashboardResponse(BaseModel):
    total_balance: float  # Sum of all accounts
    debits: Optional[float] = 0.0  # Total debits in the selected date range
    credits: Optional[float] = 0.0  # Total credits in the selected date range
