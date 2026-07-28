from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Login router
from app.routes.login import router as login_router

# Analytics & Upload routers
from app.routes.analytics import router as analytics_router
from app.routes.upload import router as upload_router
from app.routes import leads

# Database initialization
from app.database import init_db

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
app.include_router(leads.router)

@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/")
def home():
    return {"message": "Sales & Marketing AI Backend Running"}