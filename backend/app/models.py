from sqlalchemy import (
    Column,
    String,
    Integer,
    Numeric,
    Float,
    Date,
    ForeignKey,
    TIMESTAMP,
)
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.sql import func

Base = declarative_base()

# -------------------------
# User Model (Authentication)
# -------------------------

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

    p_id = Column(Integer, primary_key=True)
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
        Integer,
        ForeignKey("products.p_id"),
        nullable=True,
    )

    quantity = Column(Integer)
    unit_price = Column(Numeric)

    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")