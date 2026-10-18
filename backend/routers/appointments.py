from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_, func
from datetime import datetime, timedelta
from typing import List
from ..database import SessionLocal
from ..models import Appointment, Department, DoctorSchedule, Doctor, User
from ..schemas import AppointmentCreate, AppointmentResponse
from .auth2 import get_current_user, require_doctor

router = APIRouter(prefix="/appointments", tags=["Appointments"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/my-appointments", response_model=List[AppointmentResponse])
def get_my_appointments(current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    appointments = db.query(Appointment).filter(Appointment.patient_id == current_user.id).order_by(Appointment.start_datetime.desc()).all()
    return appointments

@router.get("/doctor-appointments", response_model=List[AppointmentResponse])
def get_doctor_appointments(current_user=Depends(require_doctor), db: Session = Depends(get_db)):
    doctor = db.query(Doctor).filter(Doctor.user_id == current_user.id).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor profile not found")
    appointments = db.query(Appointment).filter(Appointment.doctor_id == doctor.id).order_by(Appointment.start_datetime.desc()).all()
    return appointments

@router.post("/", response_model=AppointmentResponse, status_code=status.HTTP_201_CREATED)
def create_appointment(appointment_in: AppointmentCreate, current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "patient":
        raise HTTPException(status_code=403, detail="Only patients can book appointments")
    
    doctor = db.query(Doctor).filter(Doctor.id == appointment_in.doctor_id).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    
    if appointment_in.department_id:
        dept = db.query(Department).filter(Department.id == appointment_in.department_id).first()
        if not dept:
            raise HTTPException(status_code=404, detail="Department not found")
    
    
    overlap = db.query(Appointment).filter(
        and_(
            Appointment.doctor_id == appointment_in.doctor_id,
            Appointment.start_datetime < appointment_in.end_datetime,
            Appointment.end_datetime > appointment_in.start_datetime,
            Appointment.status != 'cancelled'
        )
    ).first()
    if overlap:
        raise HTTPException(status_code=400, detail="Doctor not available")

    
    day_of_week = appointment_in.start_datetime.isoweekday()

    schedule = db.query(DoctorSchedule).filter(
        DoctorSchedule.doctor_id == appointment_in.doctor_id,
        DoctorSchedule.day_of_week == day_of_week,
        DoctorSchedule.is_active == True
    ).first()
    if not schedule or appointment_in.start_datetime.time() < schedule.start_time or appointment_in.start_datetime.time() > schedule.end_time:
        raise HTTPException(status_code=400, detail="Time doesn't match schedule")
    
    appointment = Appointment(
        patient_id=current_user.id,
        doctor_id=appointment_in.doctor_id,
        department_id=appointment_in.department_id,
        start_datetime=appointment_in.start_datetime,
        end_datetime=appointment_in.end_datetime,
        reason=appointment_in.reason,
        status='pending'
    )
    db.add(appointment)
    db.commit()
    db.refresh(appointment)
    return appointment

@router.put("/{appointment_id}/status", response_model=AppointmentResponse)
def update_appointment_status(appointment_id: int, status: str, current_user=Depends(require_doctor), db: Session = Depends(get_db)):
    if status not in ['pending', 'confirmed', 'cancelled', 'completed', 'rejected']:
        raise HTTPException(status_code=400, detail="Invalid status")
    
    doctor = db.query(Doctor).filter(Doctor.user_id == current_user.id).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor profile not found")
    
    appointment = db.query(Appointment).filter(Appointment.id == appointment_id, Appointment.doctor_id == doctor.id).first()
    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
    
    appointment.status = status
    appointment.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(appointment)
    return appointment

@router.delete("/{appointment_id}/cancel")
def cancel_appointment(appointment_id: int, current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "patient":
        raise HTTPException(status_code=403, detail="Only patients can cancel")
    
    appointment = db.query(Appointment).filter(Appointment.id == appointment_id, Appointment.patient_id == current_user.id).first()
    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
    
    if appointment.status == 'cancelled':
        raise HTTPException(status_code=400, detail="Already cancelled")
    
    appointment.status = 'cancelled'
    db.commit()
    return {"message": "Cancelled successfully"}