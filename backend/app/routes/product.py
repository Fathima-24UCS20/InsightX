from fastapi import APIRouter
from sqlalchemy import text

from app.database import engine

router = APIRouter(prefix="", tags=["Products"])


@router.get("/products")
def get_products():
    query = text("""
        SELECT
            p_id AS id,
            p_name AS name,
            category,
            brand,
            price,
            rating
        FROM products
        ORDER BY p_name
    """)

    with engine.connect() as conn:
        rows = conn.execute(query).mappings().all()

    return [
        {
            "id": r["id"],
            "name": r["name"],
            "category": r["category"],
            "brand": r["brand"],
            "price": float(r["price"] or 0),
            "rating": float(r["rating"] or 0),
        }
        for r in rows
    ]


@router.get("/products/categories")
def get_categories():

    query = text("""
        SELECT DISTINCT category
        FROM products
        WHERE category IS NOT NULL
        ORDER BY category
    """)

    with engine.connect() as conn:
        rows = conn.execute(query).fetchall()

    return [r[0] for r in rows]