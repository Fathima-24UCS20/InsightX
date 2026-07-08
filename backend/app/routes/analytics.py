"""
Dashboard analytics endpoint.

Computes month-over-month KPIs from the tables that actually exist
(customers, orders). Conversion Rate and Active Campaigns are NOT
computable yet — there's no `leads` or `campaigns` table in models.py.
Those two cards are returned with available=False so the frontend can
show an honest "no data yet" instead of a made-up number.

TODO (to enable the last two cards):
  - Add a `leads` table (with a `converted` boolean/status) to compute
    conversion_rate = converted_leads / total_leads.
  - Add a `campaigns` table (with an `is_active` boolean) to compute
    active_campaigns = COUNT(*) WHERE is_active.
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
        # Not computable yet — see module docstring TODO.
        "conversion_rate": _card(None, None, available=False),
        "active_campaigns": _card(None, None, available=False),
    }