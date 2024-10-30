from fastapi import APIRouter, HTTPException, Depends
from schemas.visualization_schema import VisualizationRequest, VisualizationResponse
from services.visualization_service import generate_visualization
from config.db.database import get_db
from sqlalchemy.orm import Session

router = APIRouter()

@router.post("/generate-plots/", response_model=VisualizationResponse)
async def generate_plots(request: VisualizationRequest):
    result = await generate_visualization(request.prompt)

    if not result:
        raise HTTPException(status_code=500, detail="Failed to generate visualization.")
    
    return result