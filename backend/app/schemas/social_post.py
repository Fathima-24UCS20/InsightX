from datetime import datetime
from pydantic import BaseModel
from typing import Optional


class SocialPostCreate(BaseModel):
    campaign_id: int
    day_number: int
    platform: str


class SocialPostResponse(BaseModel):
    id: int
    campaign_id: int
    day_number: int
    platform: str
    content: str
    image_url: Optional[str] = None
    status: str
    scheduled_at: Optional[datetime] = None

    class Config:
        from_attributes = True