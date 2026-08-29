from sqlalchemy.orm import sessionmaker

from app.database.database import engine


SessionLocal = sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=False,
)