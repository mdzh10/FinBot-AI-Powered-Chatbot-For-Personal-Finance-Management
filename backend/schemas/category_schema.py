from pydantic import BaseModel
from typing import List, Union


class BaseResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Operation successful"


class CategoryCreate(BaseModel):
    """Schema for creating a new category."""

    category_name: str


class CategoryDetails(BaseModel):
    """Schema for the individual category details."""

    category_id: int
    category_name: str


class CategoryResponse(BaseResponse):
    """Schema for response that includes category details or a list of categories."""

    data: Union[CategoryDetails, List[CategoryDetails]]
