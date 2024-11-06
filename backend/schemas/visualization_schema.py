from pydantic import BaseModel


class VisualizationRequest(BaseModel):
    prompt: str


class VisualizationResponse(BaseModel):
    chart: str  # Base64-encoded image
    analysis: str  # Analysis text from ChatGPT
    isSuccess: bool = True
    msg: str = "Visualization generated successfully"
