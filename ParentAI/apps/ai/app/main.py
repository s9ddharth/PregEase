from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.auth import router as auth_router

from app.api.chat import router as chat_router
from app.config.settings import settings
from app.api.pregnancy import router as pregnancy_router

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="AI Assistant for Parents"
)


# CORS configuration
# Allows the Flutter Web app to communicate with FastAPI
# during local development.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Chat API
app.include_router(chat_router)
app.include_router(auth_router)
app.include_router(pregnancy_router)


@app.get("/")
def root():
    return {
        "message": f"Welcome to {settings.app_name} 🚀"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "version": settings.app_version
    }