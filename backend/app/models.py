from sqlalchemy import (
    Column,
    String,
    Integer,
    Numeric,
    Float,
    Date,
    ForeignKey,
    TIMESTAMP,
    Text,
    DateTime,
)
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.sql import func
from sqlalchemy import JSON
Base = declarative_base()

# -------------------------
# User Model (Authentication)
# -------------------------
class Campaign(Base):
    __tablename__ = "campaigns"

    campaign_id = Column(Integer, primary_key=True, index=True)   # was: id

    campaign_name = Column(String, nullable=False)                # was: name

    objective = Column(String, nullable=False)
    goal = Column(String, nullable=False)

    product_id = Column(String)
    product_label = Column(String)

    target_segment = Column(JSON)
    channels = Column(JSON, nullable=True)

    tone = Column(String)
    additional_info = Column(String)

    budget = Column(Numeric)
    discount = Column(Float)

    start_date = Column(Date)
    end_date = Column(Date)

    generated_copy = Column(JSON)

    status = Column(String, default="draft")

    revenue = Column(Numeric)
    change_pct = Column(Float)

    created_at = Column(TIMESTAMP, server_default=func.now())
    
class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    role = Column(String)
    created_at = Column(TIMESTAMP, server_default=func.now())


# -------------------------
# Customer Model
# -------------------------

class Customer(Base):
    __tablename__ = "customers"

    c_id = Column(String, primary_key=True)
    c_name = Column(String)
    email = Column(String)
    city = Column(String)
    registration_date = Column(Date)

    orders = relationship("Order", back_populates="customer")


# -------------------------
# Product Model
# -------------------------

class Product(Base):
    __tablename__ = "products"

    p_id = Column(String, primary_key=True)
    p_name = Column(String)
    category = Column(String)
    brand = Column(String)
    price = Column(Numeric)
    rating = Column(Float)

    order_items = relationship("OrderItem", back_populates="product")


# -------------------------
# Order Model
# -------------------------

class Order(Base):
    __tablename__ = "orders"

    order_id = Column(Integer, primary_key=True)

    # nullable because source data has missing customer IDs
    c_id = Column(String, ForeignKey("customers.c_id"), nullable=True)

    order_date = Column(Date)
    payment_method = Column(String)
    total_amount = Column(Numeric)

    customer = relationship("Customer", back_populates="orders")
    items = relationship("OrderItem", back_populates="order")


# -------------------------
# Order Item Model
# -------------------------

class OrderItem(Base):
    __tablename__ = "order_items"

    order_item_id = Column(Integer, primary_key=True)

    order_id = Column(
        Integer,
        ForeignKey("orders.order_id"),
        nullable=True,
    )

    p_id = Column(
    String,
    ForeignKey("products.p_id"),
    nullable=True,
)

    quantity = Column(Integer)
    unit_price = Column(Numeric)

    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")

# -------------------------
# Social Media Post Model
# -------------------------

class SocialPost(Base):
    __tablename__ = "social_posts"

    id = Column(Integer, primary_key=True, index=True)

    campaign_id = Column(
        Integer,
        ForeignKey("campaigns.campaign_id"),
        nullable=False,
        index=True,
    )

    day_number = Column(
        Integer,
        nullable=False,
    )

    platform = Column(
        String(50),
        nullable=False,
    )

    content = Column(
        Text,
        nullable=False,
    )

    image_url = Column(
        String(500),
        nullable=True,
    )

    status = Column(
        String(30),
        default="Draft",
        nullable=False,
    )

    scheduled_at = Column(
        DateTime,
        nullable=True,
    )

    created_at = Column(
        TIMESTAMP,
        server_default=func.now(),
    )