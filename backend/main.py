from dotenv import load_dotenv
from fastapi import FastAPI

load_dotenv()

from .database import Base, engine
from .routers import auth2, user, departments, doctors, appointments, reviews, notifications

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Clinic API")

app.include_router(auth2.router)
app.include_router(user.router)
app.include_router(departments.router)
app.include_router(doctors.router)
app.include_router(appointments.router)
app.include_router(reviews.router)
app.include_router(notifications.router)

@app.get("/")
def root():
    return {"message": "Clinic API up and running"}
