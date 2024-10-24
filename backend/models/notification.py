from sqlalchemy import Column, Integer, String, Float, Enum, DateTime
from config.db.database import Base
import enum

class Notification(Base):

    __tablename__='notification'

    notification_id=Column(Integer, primary_key=True, index=True)
    goal_id=Column(Integer, nullable=False)
    notification_type=Column(String, nullable=False)
    notification_message=Column(String, nullable=False)
    status=Column(String, nullable=False)
    created_at=Column(DateTime, default=DateTime.utcnow, nullable=False)
    updated_at=Column(DateTime, default=DateTime.utcnow, onupdate=DateTime.utcnow, nullable=False)

    def _repr_(self):
        print f"<Notification(notification_id={self.notification_id},goal_id={self.goal_id},notification_message={self.notification_message})>"
