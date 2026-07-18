from datetime import date

from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models import Customer, Order
from app.models import OrderItem, Product

def calculate_score(order_count, total_spend, last_purchase):
    score = 0

    # Order Score (30)
    if order_count > 10:
        score += 30
    elif order_count >= 5:
        score += 20
    elif order_count >= 1:
        score += 10

    # Spending Score (30)
    if total_spend > 100000:
        score += 30
    elif total_spend > 50000:
        score += 20
    elif total_spend > 10000:
        score += 10

    # Recency Score (40)
    if last_purchase:
        days = (date.today() - last_purchase).days

        if days <= 30:
            score += 40
        elif days <= 90:
            score += 20
        else:
            score += 5

    return score


def get_status(score):
    if score >= 90:
        return "Hot"
    elif score >= 60:
        return "Warm"
    return "Cold"


def get_followup(status):
    if status == "Hot":
        return "Call this week"

    if status == "Warm":
        return "Send promotional email"

    return "Offer discount coupon"

def get_customer_preferences(db: Session):

    preferences = (
        db.query(
            Order.c_id,
            Product.category,
            Product.brand,
            func.count(Product.p_id).label("purchase_count")
        )
        .join(OrderItem, Order.order_id == OrderItem.order_id)
        .join(Product, Product.p_id == OrderItem.p_id)
        .group_by(
            Order.c_id,
            Product.category,
            Product.brand,
        )
        .all()
    )

    customer_preferences = {}

    for row in preferences:

        if row.c_id not in customer_preferences:

            customer_preferences[row.c_id] = {
                "favorite_category": row.category,
                "favorite_brand": row.brand,
                "count": row.purchase_count,
            }

        elif row.purchase_count > customer_preferences[row.c_id]["count"]:

            customer_preferences[row.c_id] = {
                "favorite_category": row.category,
                "favorite_brand": row.brand,
                "count": row.purchase_count,
            }

    return customer_preferences

def generate_recommendation(
    spend,
    orders,
    last_purchase,
    category,
    brand,
):

    if last_purchase:
        inactive_days = (date.today() - last_purchase).days

        if inactive_days > 90:
            return (
                "Send Promotional Email",
                "Customer has been inactive for more than 90 days."
            )

    if spend > 100000:
        return (
            "Personal Sales Call",
            "High-value customer based on total spending."
        )

    if orders >= 10:
        return (
            "Offer Loyalty Discount",
            "Customer purchases frequently."
        )

    if category:
        return (
            f"Recommend {category} Products",
            f"Most purchases belong to the {category} category."
        )

    if brand:
        return (
            f"Promote {brand} Products",
            f"Customer prefers {brand}."
        )

    return (
        "General Marketing Campaign",
        "No strong purchasing pattern found."
    )

def get_leads_data(db: Session):

    preferences = get_customer_preferences(db)

    customer_stats = (
        db.query(
            Customer.c_id,
            Customer.c_name,
            Customer.city,
            Customer.email,
            Customer.registration_date,

            func.count(Order.order_id).label("orders"),

            func.coalesce(
                func.sum(Order.total_amount),
                0
            ).label("spend"),

            func.max(Order.order_date).label("last_purchase"),
        )
        .outerjoin(Order, Customer.c_id == Order.c_id)
        .group_by(
            Customer.c_id,
            Customer.c_name,
            Customer.city,
            Customer.email,
            Customer.registration_date,
        )
        .all()
    )

    leads = []

    for row in customer_stats:

        score = calculate_score(
            row.orders,
            float(row.spend),
            row.last_purchase,
        )

        preference = preferences.get(
            row.c_id,
            {}
        )

        category = preference.get(
            "favorite_category"
        )

        brand = preference.get(
            "favorite_brand"
        )

        recommendation, reason = generate_recommendation(
            float(row.spend),
            row.orders,
            row.last_purchase,
            category,
            brand,
        )

        status = get_status(score)

        followup = get_followup(status)

        leads.append(
            {
                "customer": row.c_name,
                "city": row.city,
                "email": row.email,
                "registration_date": row.registration_date,
                "last_purchase": row.last_purchase,
                "orders": row.orders,
                "spend": float(row.spend),

                "favorite_category": category,
                "favorite_brand": brand,

                "score": score,
                "status": status,

                "recommendation": recommendation,
                "reason": reason,

                "followup": get_followup(status),
            }
        )

    return leads

def get_leads_summary(db: Session):
    leads = get_leads_data(db)

    total = len(leads)

    hot = sum(1 for lead in leads if lead["status"] == "Hot")
    warm = sum(1 for lead in leads if lead["status"] == "Warm")
    cold = sum(1 for lead in leads if lead["status"] == "Cold")

    average_score = (
        round(sum(lead["score"] for lead in leads) / total, 2)
        if total > 0
        else 0
    )

    followups = sum(
        1 for lead in leads if lead["status"] in ["Hot", "Warm"]
    )

    return {
        "total_leads": total,
        "hot_leads": hot,
        "warm_leads": warm,
        "cold_leads": cold,
        "average_score": average_score,
        "followups": followups,
    }


def get_leads_chart(db: Session):
    leads = get_leads_data(db)

    return {
        "Hot": sum(1 for lead in leads if lead["status"] == "Hot"),
        "Warm": sum(1 for lead in leads if lead["status"] == "Warm"),
        "Cold": sum(1 for lead in leads if lead["status"] == "Cold"),
    }

def get_recent_leads(db: Session, limit: int = 5):
    leads = get_leads_data(db)

    leads = [lead for lead in leads if lead["last_purchase"] is not None]

    leads.sort(
        key=lambda x: x["last_purchase"],
        reverse=True,
    )

    return leads[:limit]

def get_lead_suggestions(db: Session):
    leads = get_leads_data(db)

    leads.sort(key=lambda x: x["score"], reverse=True)

    suggestions = []

    for lead in leads[:5]:
        suggestions.append({
            "customer": lead["customer"],
            "recommendation": lead["recommendation"],
            "reason": lead["reason"],
            "status": lead["status"],
        })

    return suggestions