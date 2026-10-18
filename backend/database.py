# database.py
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# عدّل URL حسب إعداداتك
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "mysql+mysqlconnector://root@127.0.0.1:3306/doctorapp",
)

engine = create_engine(DATABASE_URL, echo=True)


SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
