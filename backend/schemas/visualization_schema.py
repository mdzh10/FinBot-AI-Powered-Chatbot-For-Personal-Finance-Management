from typing import Optional
from pydantic import BaseModel


class VisualizationRequest(BaseModel):
    prompt: str
    showPopup: Optional[bool] = False  # Default is False


class VisualizationResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Visualization generated successfully"
    chart: Optional[str] = None  # Chart can be None