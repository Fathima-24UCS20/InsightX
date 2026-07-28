from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class CampaignCreate(BaseModel):
    campaign_name: str
    objective: str
    goal: str

    product_id: Optional[str] = None
    product_label: str

    target_segment: dict
    channels: list[str]

    tone: str

    additional_info: Optional[str] = None

    budget: Optional[float] = None
    discount: Optional[float] = None

    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None

    generated_copy: Optional[dict] = None

    status: str = "draft"

    revenue: Optional[float] = None
    change_pct: Optional[float] = None

    created_at: Optional[datetime] = None