from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum


class GoalPeriodEnum(str, Enum):
    monthly = "monthly"
    yearly = "yearly"
    weekly = "weekly"
    custom = "custom"


class GoalCreate(BaseModel):
    user_id: int
    goal_period: GoalPeriodEnum
    spending_limit: float


class GoalResponse(BaseModel):
    id: int
    user_id: int
    goal_period: GoalPeriodEnum
    spending_limit: float
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True  # this will Allow Pydantic to work with SQLAlchemy ORM objects


class GoalUpdate(BaseModel):
    goal_period: Optional[GoalPeriodEnum] = (
        None  # Optional field for goal period update
    )
    spending_limit: Optional[float] = None  # Optional field for spending limit update
    updated_at: Optional[datetime] = (
        None  # Optional; usually auto-updated but can be overridden
    )
