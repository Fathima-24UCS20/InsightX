"""
Dashboard analytics endpoint.

Computes month-over-month KPIs from the tables that actually exist
(customers, orders, products, order_items).

Still NOT computable (see module-level TODOs on each endpoint) because
there's no `leads`, `campaigns`, or review/social-text table:
  - Conversion Rate, New Leads      -> needs a `leads` table
  - Active Campaigns / Campaign list -> needs a `campaigns` table
  - Sentiment / Topics of Interest   -> needs review/social text + NLP
  - Audience by age                  -> needs age/DOB on customers
"""

from fastapi import APIRouter
from sqlalchemy import text

from app.database import engine

router = APIRouter(prefix="/analytics", tags=["analytics"])


def _pct_change(current, previous):
    """Percent change from previous -> current. None if we can't divide."""
    if previous in (None, 0):
        return None
    return round(float((current - previous) / previous) * 100, 1)


def _monthly_orders():
    """Revenue + order count per calendar month that has at least one order, oldest -> newest."""
    query = text(
        """
        SELECT date_trunc('month', order_date) AS month,
               SUM(total_amount) AS revenue,
               COUNT(*) AS orders
        FROM orders
        WHERE order_date IS NOT NULL
        GROUP BY month
        ORDER BY month
        """
    )
    with engine.connect() as conn:
        rows = conn.execute(query).mappings().all()
    return [
        {"revenue": float(r["revenue"] or 0), "orders": int(r["orders"] or 0)}
        for r in rows
    ]


def _monthly_new_customers():
    """New customer signups per calendar month, oldest -> newest."""
    query = text(
        """
        SELECT date_trunc('month', registration_date) AS month,
               COUNT(*) AS new_customers
        FROM customers
        WHERE registration_date IS NOT NULL
        GROUP BY month
        ORDER BY month
        """
    )
    with engine.connect() as conn:
        rows = conn.execute(query).mappings().all()
    return [int(r["new_customers"] or 0) for r in rows]


def _total_customers():
    with engine.connect() as conn:
        return conn.execute(text("SELECT COUNT(*) FROM customers")).scalar() or 0


def _card(value, change_pct, available=True):
    return {"value": value, "change_pct": change_pct, "available": available}


@router.get("/dashboard")
def dashboard_stats():
    monthly_orders = _monthly_orders()
    monthly_new_customers = _monthly_new_customers()
    total_customers_all_time = _total_customers()

    # --- Revenue / Orders / AOV: compare the two most recent months present in the data ---
    current = monthly_orders[-1] if monthly_orders else {"revenue": 0, "orders": 0}
    previous = monthly_orders[-2] if len(monthly_orders) >= 2 else None

    revenue_value = current["revenue"]
    orders_value = current["orders"]
    aov_value = round(revenue_value / orders_value, 2) if orders_value else 0

    if previous:
        prev_revenue = previous["revenue"]
        prev_orders = previous["orders"]
        prev_aov = round(prev_revenue / prev_orders, 2) if prev_orders else 0
    else:
        prev_revenue = prev_orders = prev_aov = None

    # --- Customers: reconstruct cumulative total as of the end of each month ---
    cust_current_month_total = None
    cust_previous_month_total = None
    if monthly_new_customers:
        cumulative = total_customers_all_time
        cumulative_by_month = []
        for new_this_month in reversed(monthly_new_customers):
            cumulative_by_month.append(cumulative)  # end-of-month total, newest first
            cumulative -= new_this_month
        cumulative_by_month.reverse()  # oldest -> newest, aligned with monthly_new_customers
        cust_current_month_total = cumulative_by_month[-1]
        cust_previous_month_total = (
            cumulative_by_month[-2] if len(cumulative_by_month) >= 2 else None
        )

    return {
        "total_revenue": _card(revenue_value, _pct_change(revenue_value, prev_revenue)),
        "total_orders": _card(orders_value, _pct_change(orders_value, prev_orders)),
        "total_customers": _card(
            total_customers_all_time,
            _pct_change(cust_current_month_total, cust_previous_month_total),
        ),
        "avg_order_value": _card(aov_value, _pct_change(aov_value, prev_aov)),
        # Not computable yet — no leads/campaigns table.
        "conversion_rate": _card(None, None, available=False),
        "active_campaigns": _card(None, None, available=False),
    }


@router.get("/top-products")
def top_products(limit: int = 5):
    """
    Top products by revenue, computed from order_items x products.
    Real data — replaces the dummy Top Products widget.
    """
    query = text(
        """
        SELECT p.p_id,
               p.p_name,
               p.category,
               p.brand,
               SUM(oi.quantity * oi.unit_price) AS revenue,
               SUM(oi.quantity) AS units_sold
        FROM order_items oi
        JOIN products p ON p.p_id = oi.p_id
        GROUP BY p.p_id, p.p_name, p.category, p.brand
        ORDER BY revenue DESC
        LIMIT :limit
        """
    )
    with engine.connect() as conn:
        rows = conn.execute(query, {"limit": limit}).mappings().all()

    return {
        "products": [
            {
                "p_id": r["p_id"],
                "name": r["p_name"],
                "category": r["category"],
                "brand": r["brand"],
                "revenue": float(r["revenue"] or 0),
                "units_sold": int(r["units_sold"] or 0),
            }
            for r in rows
        ]
    }


@router.get("/customer-distribution")
def customer_distribution(top_n: int = 5):
    """
    Real customer geographic distribution by city (customers.city).
    NOTE: this is distribution by CITY, not by age — there's no age/DOB
    column on customers, so an age-based breakdown (like the current
    AudienceDonutCard demo data) isn't computable yet.
    """
    query = text(
        """
        SELECT city, COUNT(*) AS customer_count
        FROM customers
        WHERE city IS NOT NULL
        GROUP BY city
        ORDER BY customer_count DESC
        """
    )
    with engine.connect() as conn:
        rows = conn.execute(query).mappings().all()

    total = sum(int(r["customer_count"] or 0) for r in rows)
    if total == 0:
        return {"total_customers": 0, "segments": []}

    top_rows = rows[:top_n]
    other_count = sum(int(r["customer_count"] or 0) for r in rows[top_n:])

    segments = [
        {
            "label": r["city"],
            "count": int(r["customer_count"] or 0),
            "percent": round(int(r["customer_count"] or 0) / total * 100, 1),
        }
        for r in top_rows
    ]
    if other_count:
        segments.append(
            {
                "label": "Other",
                "count": other_count,
                "percent": round(other_count / total * 100, 1),
            }
        )

    return {"total_customers": total, "segments": segments}