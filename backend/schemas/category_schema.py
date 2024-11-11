from pydantic import BaseModel
from typing import List, Union, Optional


class BaseResponse(BaseModel):
    isSuccess: bool = True
    msg: str = "Operation successful"


class CategoryCreate(BaseModel):
    name: str
    icon_code_point: int
    color_value: int
    budget: Optional[float] = 0
    expense: Optional[float] = 0


class CategoryDetails(BaseModel):
    id: int
    name: str
    icon_code_point: int
    color_value: int
    budget: Optional[float] = 0
    expense: Optional[float] = 0


class CategoryResponse(BaseResponse):
    data: Union[CategoryDetails, List[CategoryDetails]]
