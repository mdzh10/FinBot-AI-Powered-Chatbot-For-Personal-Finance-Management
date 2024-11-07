from sqlalchemy import Column, Integer, String, Float, Enum, DateTime
from config.db.database import Base
from datetime import datetime, timezone
import enum


class GoalPeriodEnum(enum.Enum):
    monthly = "monthly"
    yearly = "yearly"
    weekly = "weekly"
    custom = "custom"


class Goal(Base):
    __tablename__ = "goals"

    id = Column(Integer, primary_key=True, index=True)  # Unique ID for each goal
    user_id = Column(Integer, nullable=False)  # ID of the user who owns the goal
    goal_period = Column(
        Enum(GoalPeriodEnum), nullable=False
    )  # Frequency of the goal (monthly, yearly, etc.)
    spending_limit = Column(Float, nullable=False)  # Max allowed spending for the goal
    created_at = Column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )  # Updated to use timezone-aware datetime
    updated_at = Column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )  # Updated for timezone-aware datetime on update

    def __repr__(self):
        return f"<Goal(id={self.id}, user_id={self.user_id}, goal_period={self.goal_period}, spending_limit={self.spending_limit})>"
