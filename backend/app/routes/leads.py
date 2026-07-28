from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from fastapi import Query
from typing import Optional

from app.database import SessionLocal
from app.services.leads_services import (
    get_leads_data,
    get_leads_summary,
    get_leads_chart,
    get_recent_leads,
    get_lead_suggestions,
)

router = APIRouter(
    prefix="/analytics",
    tags=["Leads"]
)


# Database Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("/leads")
def get_leads(
    search: str | None = None,
    status: str | None = None,
    city: str | None = None,
    sort: str | None = None,
    db: Session = Depends(get_db),
):
    return get_leads_data(
        db,
        search=search,
        status_filter=status,
        city=city,
        sort=sort,
    )


@router.get("/leads/summary")
def lead_summary(db: Session = Depends(get_db)):
    return get_leads_summary(db)


@router.get("/leads/chart")
def lead_chart(db: Session = Depends(get_db)):
    return get_leads_chart(db)


@router.get("/leads/recent")
def recent_leads(
    limit: int = Query(5, ge=1, le=20),
    db: Session = Depends(get_db),
):
    return get_recent_leads(db, limit)


@router.get("/leads/suggestions")
def lead_suggestions(db: Session = Depends(get_db)):
    return get_lead_suggestions(db)