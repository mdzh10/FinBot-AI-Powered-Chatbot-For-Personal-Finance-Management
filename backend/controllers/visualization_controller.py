from fastapi import APIRouter, HTTPException
from schemas.visualization_schema import VisualizationRequest, VisualizationResponse
from services.visualization_service import generate_visualization

router = APIRouter()


@router.post("/generate-plots/", response_model=VisualizationResponse)
async def generate_plots(request: VisualizationRequest):
    result = await generate_visualization(request.prompt, request.showPopup)

    if not result or not result["isSuccess"]:
        raise HTTPException(
            status_code=500,
            detail=result.get("msg", "Failed to generate visualization."),
        )

    return result
