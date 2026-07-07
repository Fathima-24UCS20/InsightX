from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from db import init_db
from routes.upload import router as upload_router
from routes.analytics import router as analytics_router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],      # For development only
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(upload_router)
app.include_router(analytics_router)


@app.on_event("startup")
def on_startup():
    # Creates customers, products, orders, order_items tables if they don't exist yet
    init_db()


@app.get("/")
def home():
    return {"message": "Sales & Marketing AI Backend Running"}