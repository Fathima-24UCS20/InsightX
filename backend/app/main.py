from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from dotenv import load_dotenv

import asyncio

from app.scheduler.campaign_scheduler import scheduler_loop

load_dotenv()

# Login router
from app.routes.login import router as login_router
#from app.routes.customer import router as customer_router

# Analytics & Upload routers
from app.routes.analytics import router as analytics_router
from app.routes.upload import router as upload_router
from app.routes import leads

# Database initialization
from app.database import init_db

from app.routes.product import router as product_router
from app.routes.customer import router as customer_router
from app.routes.campaign import router as campaign_router
from app.routes.social_post import router as social_post_router
from app.routes.notifications import router as notifications_router

app = FastAPI()

# Folder for generated social media images
GENERATED_POSTS_DIR = Path("generated_posts")
GENERATED_POSTS_DIR.mkdir(exist_ok=True)

# Make generated images accessible to Flutter
app.mount(
    "/generated-posts",
    StaticFiles(directory=GENERATED_POSTS_DIR),
    name="generated-posts",
)

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

app.include_router(customer_router)
app.include_router(product_router)
app.include_router(campaign_router)
app.include_router(social_post_router)
app.include_router(notifications_router)
@app.on_event("startup")
async def on_startup():
    init_db()

    asyncio.create_task(
        scheduler_loop()
    )


@app.get("/")
def home():
    return {"message": "Sales & Marketing AI Backend Running"}