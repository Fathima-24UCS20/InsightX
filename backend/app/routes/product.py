from fastapi import APIRouter,Query,HTTPException,Form
from sqlalchemy import text

from app.database import engine

router = APIRouter(prefix="", tags=["Products"])


@router.get("/products")
def get_products(
    search: str | None = Query(default=None),
    category: str | None = Query(default=None),
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=5, ge=1, le=100),
    sort_by: str = Query(default="name"),
    sort_order: str = Query(default="asc"),
):
    offset = (page - 1) * limit
    
    count_query = text("""
        SELECT COUNT(*)
        FROM products
        WHERE
            (
                :search IS NULL
                OR p_name ILIKE '%' || :search || '%'
                OR category ILIKE '%' || :search || '%'
                OR brand ILIKE '%' || :search || '%'
            )
            AND (
                :category IS NULL
                OR category = :category
            )
    """)

    sort_columns = {
            "name": "p_name",
            "category": "category",
            "brand": "brand",
            "price": "price",
            "rating": "rating",
        }
    
    sort_column = sort_columns.get(sort_by, "p_name")
    
    sort_direction = "DESC" if sort_order.lower() == "desc" else "ASC"

    products_query = text(f"""
        SELECT
            p_id AS id,
            p_name AS name,
            category,
            brand,
            price,
            rating,
            is_active
        FROM products
        WHERE
            (
                :search IS NULL
                OR p_name ILIKE '%' || :search || '%'
                OR category ILIKE '%' || :search || '%'
                OR brand ILIKE '%' || :search || '%'
            )
            AND (
                :category IS NULL
                OR category = :category
            )
        ORDER BY {sort_column} {sort_direction}
        LIMIT :limit
        OFFSET :offset
    """)

    search_value = search.strip() if search else None
    category_value = category if category else None

    with engine.connect() as conn:

        total = conn.execute(
            count_query,
            {
                "search": search_value,
                "category": category_value,
            }
        ).scalar()

        rows = conn.execute(
            products_query,
            {
                "search": search_value,
                "category": category_value,
                "limit": limit,
                "offset": offset,
            }
        ).mappings().all()

    return {
        "products": [
            {
                "id": r["id"],
                "name": r["name"],
                "category": r["category"],
                "brand": r["brand"],
                "price": float(r["price"] or 0),
                "rating": float(r["rating"] or 0),
                "is_active": r["is_active"],
            }
            for r in rows
        ],
        "total": total,
        "page": page,
        "limit": limit,
        "total_pages": (total + limit - 1) // limit,
    }

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

@router.get("/products/summary")
def get_product_summary():

    # -------------------------
    # Total Products
    # -------------------------
    total_products_query = text("""
        SELECT COUNT(*) AS total_products
        FROM products
    """)

    # -------------------------
    # Total Units Sold
    # -------------------------
    units_sold_query = text("""
        SELECT COALESCE(SUM(quantity), 0) AS total_units_sold
        FROM order_items
    """)

    # -------------------------
    # Total Revenue
    # -------------------------
    revenue_query = text("""
    SELECT COALESCE(SUM(unit_price * quantity), 0) AS total_revenue
    FROM order_items
    """)

    # -------------------------
    # Average Product Price
    # -------------------------
    avg_price_query = text("""
        SELECT COALESCE(AVG(price), 0) AS avg_product_price
        FROM products
    """)

    # -------------------------
    # Best Selling Product
    # -------------------------
    best_selling_query = text("""
        SELECT
            p.p_name AS product_name,
            COALESCE(SUM(oi.quantity), 0) AS units_sold
        FROM products p
        JOIN order_items oi
            ON p.p_id = oi.p_id
        GROUP BY p.p_id, p.p_name
        ORDER BY units_sold DESC
        LIMIT 1
    """)

    # -------------------------
    # Latest Order Date
    # -------------------------
    latest_date_query = text("""
        SELECT MAX(order_date) AS latest_date
        FROM orders
    """)

    with engine.connect() as conn:

        total_products = conn.execute(
            total_products_query
        ).scalar()

        total_units_sold = conn.execute(
            units_sold_query
        ).scalar()

        total_revenue = conn.execute(
            revenue_query
        ).scalar()

        avg_product_price = conn.execute(
            avg_price_query
        ).scalar()

        best_selling = conn.execute(
            best_selling_query
        ).mappings().first()

        latest_date = conn.execute(
            latest_date_query
        ).scalar()

    # -------------------------
    # 7-Day Comparison
    # -------------------------

    current_units_query = text("""
        SELECT COALESCE(SUM(oi.quantity), 0)
        FROM orders o
        JOIN order_items oi
            ON o.order_id = oi.order_id
        WHERE o.order_date BETWEEN
            :latest_date - INTERVAL '6 days'
            AND :latest_date
    """)

    previous_units_query = text("""
        SELECT COALESCE(SUM(oi.quantity), 0)
        FROM orders o
        JOIN order_items oi
            ON o.order_id = oi.order_id
        WHERE o.order_date BETWEEN
            :latest_date - INTERVAL '13 days'
            AND :latest_date - INTERVAL '7 days'
    """)

    current_revenue_query = text("""
    SELECT COALESCE(SUM(oi.unit_price * oi.quantity), 0)
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_date BETWEEN
        :latest_date - INTERVAL '6 days'
        AND :latest_date
    """)

    previous_revenue_query = text("""
    SELECT COALESCE(SUM(oi.unit_price * oi.quantity), 0)
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_date BETWEEN
            :latest_date - INTERVAL '13 days'
            AND :latest_date - INTERVAL '7 days'
    """)

    with engine.connect() as conn:

        current_units = conn.execute(
            current_units_query,
            {"latest_date": latest_date}
        ).scalar()

        previous_units = conn.execute(
            previous_units_query,
            {"latest_date": latest_date}
        ).scalar()

        current_revenue = conn.execute(
            current_revenue_query,
            {"latest_date": latest_date}
        ).scalar()

        previous_revenue = conn.execute(
            previous_revenue_query,
            {"latest_date": latest_date}
        ).scalar()

    # -------------------------
    # Calculate percentage change
    # -------------------------

    current_units = float(current_units or 0)
    previous_units = float(previous_units or 0)

    current_revenue = float(current_revenue or 0)
    previous_revenue = float(previous_revenue or 0)

    if previous_units > 0:
        units_sold_change = (
            (current_units - previous_units) / previous_units
        ) * 100
    else:
        units_sold_change = None

    if previous_revenue > 0:
        revenue_change = (
            (current_revenue - previous_revenue) / previous_revenue
        ) * 100
    else:
        revenue_change = None

    # -------------------------
    # Return summary
    # -------------------------

    return {
        "total_products": int(total_products or 0),

        "total_units_sold": int(total_units_sold or 0),

        "total_revenue": float(total_revenue or 0),

        "avg_product_price": float(avg_product_price or 0),

        "best_selling_product": {
            "name": best_selling["product_name"]
            if best_selling else "N/A",

            "units_sold": int(best_selling["units_sold"])
            if best_selling else 0,
        },

        "units_sold_change": round(units_sold_change, 2)
        if units_sold_change is not None else None,

        "revenue_change": round(revenue_change, 2)
        if revenue_change is not None else None,
    }

@router.put("/products/{product_id}")
def update_product(
    product_id: str,
    product_name: str = Form(...),
    category: str = Form(...),
    brand: str = Form(...),
    price: float = Form(...),
    rating: float = Form(...),
):
    query = text("""
        UPDATE products
        SET
            p_name = :product_name,
            category = :category,
            brand = :brand,
            price = :price,
            rating = :rating
        WHERE p_id = :product_id
        RETURNING
            p_id AS id,
            p_name AS name,
            category,
            brand,
            price,
            rating
    """)

    with engine.begin() as conn:
        row = conn.execute(
            query,
            {
                "product_id": product_id,
                "product_name": product_name,
                "category": category,
                "brand": brand,
                "price": price,
                "rating": rating,
            },
        ).mappings().first()

    if not row:
        raise HTTPException(
            status_code=404,
            detail="Product not found",
        )

    return {
        "id": row["id"],
        "name": row["name"],
        "category": row["category"],
        "brand": row["brand"],
        "price": float(row["price"] or 0),
        "rating": float(row["rating"] or 0),
    }

@router.post("/products")
def create_product(
    product_id: str = Form(...),
    product_name: str = Form(...),
    category: str = Form(...),
    brand: str = Form(...),
    price: float = Form(...),
    rating: float = Form(...),
):
    check_query = text("""
        SELECT p_id
        FROM products
        WHERE p_id = :product_id
    """)

    insert_query = text("""
        INSERT INTO products (
            p_id,
            p_name,
            category,
            brand,
            price,
            rating
        )
        VALUES (
            :product_id,
            :product_name,
            :category,
            :brand,
            :price,
            :rating
        )
        RETURNING
            p_id AS id,
            p_name AS name,
            category,
            brand,
            price,
            rating
    """)

    with engine.begin() as conn:

        existing = conn.execute(
            check_query,
            {"product_id": product_id},
        ).first()

        if existing:
            raise HTTPException(
                status_code=409,
                detail="Product ID already exists"
            )

        row = conn.execute(
            insert_query,
            {
                "product_id": product_id,
                "product_name": product_name,
                "category": category,
                "brand": brand,
                "price": price,
                "rating": rating,
            },
        ).mappings().first()

    return {
        "id": row["id"],
        "name": row["name"],
        "category": row["category"],
        "brand": row["brand"],
        "price": float(row["price"] or 0),
        "rating": float(row["rating"] or 0),
    }

@router.get("/products/{product_id}/details")
def get_product_details(product_id: str):
    query = text("""
        SELECT
            p.p_id AS id,
            p.p_name AS name,
            p.category,
            p.brand,
            p.price,
            p.rating,
            COALESCE(SUM(oi.quantity), 0) AS units_sold,
            COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS revenue,
            COUNT(DISTINCT oi.order_id) AS orders
        FROM products p
        LEFT JOIN order_items oi
            ON p.p_id = oi.p_id
        WHERE p.p_id = :product_id
        GROUP BY
            p.p_id,
            p.p_name,
            p.category,
            p.brand,
            p.price,
            p.rating
    """)

    with engine.begin() as conn:
        row = conn.execute(
            query,
            {"product_id": product_id}
        ).mappings().first()

    if not row:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    return {
        "id": row["id"],
        "name": row["name"],
        "category": row["category"],
        "brand": row["brand"],
        "price": float(row["price"] or 0),
        "rating": float(row["rating"] or 0),
        "units_sold": int(row["units_sold"] or 0),
        "revenue": float(row["revenue"] or 0),
        "orders": int(row["orders"] or 0),
    }

@router.get("/products/{product_id}/orders")
def get_product_orders(product_id: str):
    query = text("""
        SELECT
            o.order_id,
            o.order_date,
            o.c_id,
            oi.quantity,
            oi.unit_price,
            (oi.quantity * oi.unit_price) AS item_total
        FROM order_items oi
        JOIN orders o
            ON oi.order_id = o.order_id
        WHERE oi.p_id = :product_id
        ORDER BY o.order_date DESC
    """)

    with engine.begin() as conn:
        rows = conn.execute(
            query,
            {"product_id": product_id}
        ).mappings().all()

    return {
        "product_id": product_id,
        "orders": [
            {
                "order_id": row["order_id"],
                "order_date": row["order_date"].isoformat()
                    if row["order_date"] else None,
                "customer_id": row["c_id"],
                "quantity": int(row["quantity"] or 0),
                "unit_price": float(row["unit_price"] or 0),
                "item_total": float(row["item_total"] or 0),
            }
            for row in rows
        ]
    }

@router.patch("/products/{product_id}/deactivate")
def deactivate_product(product_id: str):
    query = text("""
        UPDATE products
        SET is_active = FALSE
        WHERE p_id = :product_id
        RETURNING
            p_id AS id,
            p_name AS name,
            is_active
    """)

    with engine.begin() as conn:
        row = conn.execute(
            query,
            {"product_id": product_id}
        ).mappings().first()

    if not row:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    return {
        "id": row["id"],
        "name": row["name"],
        "is_active": row["is_active"],
        "message": "Product deactivated successfully"
    }

@router.patch("/products/{product_id}/reactivate")
def reactivate_product(product_id: str):
    query = text("""
        UPDATE products
        SET is_active = TRUE
        WHERE p_id = :product_id
        RETURNING p_id
    """)

    with engine.begin() as conn:
        result = conn.execute(query, {"product_id": product_id}).fetchone()

    if not result:
        raise HTTPException(status_code=404, detail="Product not found")

    return {
        "message": "Product reactivated successfully",
        "product_id": product_id
    }

@router.get("/orders")
def get_orders():
    query = text("""
        SELECT
            o.order_id,
            o.order_date,
            o.c_id,
            o.payment_method,
            o.total_amount,
            COALESCE(SUM(oi.quantity), 0) AS total_items
        FROM orders o
        LEFT JOIN order_items oi
            ON o.order_id = oi.order_id
        GROUP BY
            o.order_id,
            o.order_date,
            o.c_id,
            o.payment_method,
            o.total_amount
        ORDER BY o.order_date DESC
    """)

    with engine.begin() as conn:
        rows = conn.execute(query).mappings().all()

    return {
        "orders": [
            {
                "order_id": row["order_id"],
                "order_date": (
                    row["order_date"].isoformat()
                    if row["order_date"]
                    else None
                ),
                "customer_id": row["c_id"],
                "payment_method": row["payment_method"],
                "total_amount": float(row["total_amount"] or 0),
                "total_items": int(row["total_items"] or 0),
            }
            for row in rows
        ]
    }

@router.get("/orders/{order_id}")
def get_order_details(order_id: str):

    query = text("""
        SELECT
            o.order_id,
            o.order_date,
            o.c_id,
            o.payment_method,
            o.total_amount,
            p.p_id,
            p.p_name,
            oi.quantity,
            oi.unit_price,
            (oi.quantity * oi.unit_price) AS item_total
        FROM orders o
        LEFT JOIN order_items oi
            ON o.order_id = oi.order_id
        LEFT JOIN products p
            ON oi.p_id = p.p_id
        WHERE o.order_id = :order_id
        ORDER BY p.p_name
    """)

    with engine.begin() as conn:
        rows = conn.execute(
            query,
            {"order_id": order_id}
        ).mappings().all()

    if not rows:
        raise HTTPException(
            status_code=404,
            detail="Order not found"
        )

    first = rows[0]

    return {
        "order_id": first["order_id"],
        "order_date": (
            first["order_date"].isoformat()
            if first["order_date"]
            else None
        ),
        "customer_id": first["c_id"],
        "payment_method": first["payment_method"],
        "total_amount": float(first["total_amount"] or 0),

        "items": [
            {
                "product_id": row["p_id"],
                "product_name": row["p_name"],
                "quantity": int(row["quantity"] or 0),
                "unit_price": float(row["unit_price"] or 0),
                "item_total": float(row["item_total"] or 0),
            }
            for row in rows
            if row["p_id"] is not None
        ]
    }

@router.put("/orders/{order_id}")
def update_order(
    order_id: str,
    customer_id: str = Form(...),
    order_date: str = Form(...),
    payment_method: str = Form(...),
    total_amount: float = Form(...),
):
    query = text("""
        UPDATE orders
        SET
            c_id = :customer_id,
            order_date = :order_date,
            payment_method = :payment_method,
            total_amount = :total_amount
        WHERE order_id = :order_id
        RETURNING
            order_id,
            order_date,
            c_id,
            payment_method,
            total_amount
    """)

    with engine.begin() as conn:
        row = conn.execute(
            query,
            {
                "order_id": order_id,
                "customer_id": customer_id,
                "order_date": order_date,
                "payment_method": payment_method,
                "total_amount": total_amount,
            },
        ).mappings().first()

    if not row:
        raise HTTPException(
            status_code=404,
            detail="Order not found",
        )

    return {
        "order_id": row["order_id"],
        "order_date": row["order_date"].isoformat()
        if row["order_date"]
        else None,
        "customer_id": row["c_id"],
        "payment_method": row["payment_method"],
        "total_amount": float(row["total_amount"] or 0),
        "message": "Order updated successfully",
    }