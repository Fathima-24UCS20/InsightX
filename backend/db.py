import os
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv(dotenv_path=".env")

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise RuntimeError(
        "DATABASE_URL is not set. Create a .env file with a line like:\n"
        "DATABASE_URL=postgresql://postgres:password@localhost:5432/sales_marketing_ai"
    )

engine = create_engine(DATABASE_URL)


def init_db():
    """Create all tables (customers, products, orders, order_items) if they don't exist yet."""
    from models import Base  # local import avoids circular import at module load time
    Base.metadata.create_all(bind=engine)