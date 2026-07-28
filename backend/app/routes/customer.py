from fastapi import APIRouter
from sqlalchemy import text

from app.database import engine

router = APIRouter(prefix="", tags=["Customers"])


@router.get("/customers/cities")
def get_customer_cities():

    query = text("""
        SELECT DISTINCT city
        FROM customers
        WHERE city IS NOT NULL
        ORDER BY city
    """)

    with engine.connect() as conn:
        rows = conn.execute(query).fetchall()

    return [r[0] for r in rows]