from pydantic import BaseModel
from typing import Optional
from enum import Enum
from datetime import datetime

class NotificationCreate(BaseModel):

    notification_id: int
    goal_id:int
    notification_type:str
    notification_message:str
    status:str
    created_at: Optional[datetime]=None
    updated_at: Optional[datetime]=None

class NotificationResponse(BaseModel):
    
    isSuccess: bool=True
    msg: str= "notification created successfully"
    notification_id: int
    goal_id:int
    notification_type:str
    notification_message:str
    status:str
    created_at:datetime
    updated_at:datetime
