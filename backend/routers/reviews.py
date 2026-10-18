from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import SessionLocal
from ..models import Review, Appointment
from ..schemas import ReviewCreate, ReviewResponse
from .auth2 import get_current_user

router = APIRouter(prefix="/reviews", tags=["Reviews"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=ReviewResponse, status_code=status.HTTP_201_CREATED)
def create_review(review_in: ReviewCreate, current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "patient":
        raise HTTPException(status_code=403, detail="Only patients can review")
    
    appointment = db.query(Appointment).filter(
        Appointment.id == review_in.appointment_id,
        Appointment.patient_id == current_user.id,
        Appointment.status == 'completed'
    ).first()
    if not appointment:
        raise HTTPException(status_code=400, detail="Completed appointment required")
    
    existing = db.query(Review).filter(Review.appointment_id == review_in.appointment_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Review already exists")
    
    review = Review(
        appointment_id=review_in.appointment_id,
        patient_id=current_user.id,
        doctor_id=appointment.doctor_id,
        rating=review_in.rating,
        comment=review_in.comment
    )
    db.add(review)
    db.commit()
    db.refresh(review)
    
    # Update average rating
    reviews = db.query(Review).filter(Review.doctor_id == appointment.doctor_id).all()
    if reviews:
        avg = sum(r.rating for r in reviews) / len(reviews)
        appointment.doctor.average_rating = round(avg, 2)
        db.commit()
    
    return review

@router.get("/doctor/{doctor_id}", response_model=List[ReviewResponse])
def get_doctor_reviews(doctor_id: int, db: Session = Depends(get_db)):
    reviews = db.query(Review).filter(Review.doctor_id == doctor_id).order_by(Review.created_at.desc()).all()
    return reviews