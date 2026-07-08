from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise RuntimeError(
        "DATABASE_URL is not set.\n"
        "Create a .env file with:\n"
        "DATABASE_URL=postgresql://postgres:password@localhost:5432/sales_marketing_ai"
    )

# SQLAlchemy Engine
engine = create_engine(DATABASE_URL)

# Session Factory
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

# Create Tables
def init_db():
    """
    Creates all tables defined in models.py
    if they do not already exist.
    """
    from app.models import Base

    Base.metadata.create_all(bind=engine)