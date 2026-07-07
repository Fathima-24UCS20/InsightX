import io
import pandas as pd
from fastapi import APIRouter, UploadFile, File, HTTPException
from sqlalchemy.exc import IntegrityError

from db import engine

router = APIRouter(prefix="/upload", tags=["upload"])

# Expected columns + date columns (with their exact expected format) for each dataset,
# based on the actual CSV headers. Dates are parsed with an explicit format rather than
# left to pandas' guesswork, because day/month-ambiguous formats (e.g. 03-07-2024) can
# silently parse to the wrong date if the format is inferred instead of specified.
DATASET_CONFIG = {
    "customers": {
        "table": "customers",
        "required_columns": {"c_id", "c_name", "email", "city", "registration_date"},
        "date_columns": {"registration_date": "%Y-%m-%d"},  # e.g. 2023-07-18
    },
    "products": {
        "table": "products",
        "required_columns": {"p_id", "p_name", "category", "brand", "price", "rating"},
        "date_columns": {},
    },
    "orders": {
        "table": "orders",
        "required_columns": {"order_id", "c_id", "order_date", "payment_method", "total_amount"},
        "date_columns": {"order_date": "%d-%m-%Y"},  # e.g. 17-03-2025
    },
    "order_items": {
        "table": "order_items",
        "required_columns": {"order_item_id", "order_id", "p_id", "quantity", "unit_price"},
        "date_columns": {},
    },
}


def read_dataset(file: UploadFile) -> pd.DataFrame:
    """Parse an uploaded CSV or Excel file into a DataFrame."""
    raw = file.file.read()
    if file.filename.endswith(".csv"):
        return pd.read_csv(io.BytesIO(raw))
    elif file.filename.endswith((".xlsx", ".xls")):
        return pd.read_excel(io.BytesIO(raw), engine="openpyxl")
    raise HTTPException(status_code=400, detail="Unsupported file format. Please upload a .csv or .xlsx file.")


def upload_dataset(dataset_key: str, file: UploadFile):
    config = DATASET_CONFIG[dataset_key]
    df = read_dataset(file)

    # Validate the file actually matches the dataset the user picked
    missing = config["required_columns"] - set(df.columns)
    if missing:
        raise HTTPException(
            status_code=400,
            detail=f"This doesn't look like a {dataset_key} file. Missing columns: {sorted(missing)}",
        )

    # Parse date columns with an explicit, known format. If the source file's date
    # format ever changes again, this raises a clear error instead of silently
    # producing wrong (day/month-swapped) or null dates.
    for col, fmt in config["date_columns"].items():
        parsed = pd.to_datetime(df[col], format=fmt, errors="coerce")
        bad_rows = df.index[parsed.isna() & df[col].notna()].tolist()
        if bad_rows:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Column '{col}' doesn't match the expected date format {fmt} "
                    f"(e.g. row {bad_rows[0]}: '{df.loc[bad_rows[0], col]}'). "
                    f"Fix the file or update the expected format in upload.py."
                ),
            )
        df[col] = parsed.dt.date

    try:
        df.to_sql(config["table"], con=engine, if_exists="append", index=False)
    except IntegrityError as e:
        raise HTTPException(
            status_code=409,
            detail=(
                f"Upload rejected — likely duplicate primary keys (this file may already be "
                f"uploaded) or a foreign key reference to a row that doesn't exist yet "
                f"(e.g. uploading orders before customers). Details: {str(e.orig)}"
            ),
        )

    return {"message": f"{dataset_key.capitalize()} dataset uploaded successfully", "rows": len(df)}


@router.post("/customers")
async def upload_customers(file: UploadFile = File(...)):
    return upload_dataset("customers", file)


@router.post("/products")
async def upload_products(file: UploadFile = File(...)):
    return upload_dataset("products", file)


@router.post("/orders")
async def upload_orders(file: UploadFile = File(...)):
    return upload_dataset("orders", file)


@router.post("/order_items")
async def upload_order_items(file: UploadFile = File(...)):
    return upload_dataset("order_items", file)