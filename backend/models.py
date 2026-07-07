from sqlalchemy import Column, String, Integer, Numeric, Float, Date, ForeignKey
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


class Customer(Base):
    __tablename__ = "customers"

    c_id = Column(String, primary_key=True)
    c_name = Column(String)
    email = Column(String)
    city = Column(String)
    registration_date = Column(Date)

    orders = relationship("Order", back_populates="customer")


class Product(Base):
    __tablename__ = "products"

    p_id = Column(Integer, primary_key=True)
    p_name = Column(String)
    category = Column(String)
    brand = Column(String)
    price = Column(Numeric)
    rating = Column(Float)

    order_items = relationship("OrderItem", back_populates="product")


class Order(Base):
    __tablename__ = "orders"

    order_id = Column(Integer, primary_key=True)
    # nullable: source data has missing c_id on many rows
    c_id = Column(String, ForeignKey("customers.c_id"), nullable=True)
    order_date = Column(Date)
    payment_method = Column(String)
    total_amount = Column(Numeric)

    customer = relationship("Customer", back_populates="orders")
    items = relationship("OrderItem", back_populates="order")


class OrderItem(Base):
    __tablename__ = "order_items"

    order_item_id = Column(Integer, primary_key=True)
    order_id = Column(Integer, ForeignKey("orders.order_id"), nullable=True)
    p_id = Column(Integer, ForeignKey("products.p_id"), nullable=True)
    quantity = Column(Integer)
    unit_price = Column(Numeric)

    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")