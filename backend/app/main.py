from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
load_dotenv()

# Login router
from app.routes.login import router as login_router
#from app.routes.customer import router as customer_router

# Analytics & Upload routers
from app.routes.analytics import router as analytics_router
from app.routes.upload import router as upload_router

# Database initialization
from app.database import init_db

from app.routes.product import router as product_router
from app.routes.customer import router as customer_router
from app.routes.campaign import router as campaign_router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all routers
app.include_router(login_router)
app.include_router(upload_router)
app.include_router(analytics_router)

app.include_router(customer_router)
app.include_router(product_router)
app.include_router(campaign_router)
@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/")
def home():
    return {"message": "Sales & Marketing AI Backend Running"}