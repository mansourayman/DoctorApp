from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_
from ..database import SessionLocal
from ..models import Doctor, User, Department
from ..schemas import DoctorCreate, DoctorResponse, DoctorUpdate
from .auth2 import get_current_user, require_admin, require_doctor
from sqlalchemy.orm import joinedload
from sqlalchemy import or_, and_, exists

router = APIRouter(prefix="/doctors", tags=["Doctors"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/", response_model=list[DoctorResponse])
def get_all_doctors(
    q: Optional[str] = None,
    department_id: Optional[int] = None,
    min_fee: Optional[float] = None,
    max_fee: Optional[float] = None,
    min_rating: Optional[float] = None,
    available: Optional[bool] = None,
    page: int = 1,
    per_page: int = 20,
    db: Session = Depends(get_db)
):
    """
    Retrieve doctors with optional filters:
    - q: search text (matches doctor user full_name or specialization)
    - department_id: filter by department
    - min_fee / max_fee: fee range
    - min_rating: minimal average_rating
    - available: if true, only doctors who have at least one active schedule (DoctorSchedule.is_active == True)
    - page/per_page: pagination
    """
    query = db.query(Doctor).join(User).options(joinedload(Doctor.user), joinedload(Doctor.department))

    if q:
        pat = f"%{q}%"
        query = query.filter(
            or_(
                User.full_name.ilike(pat),
                Doctor.specialization.ilike(pat),
                Doctor.bio.ilike(pat)
            )
        )

    if department_id:
        query = query.filter(Doctor.department_id == department_id)

    if min_fee is not None:
        query = query.filter(Doctor.consultation_fee >= min_fee)

    if max_fee is not None:
        query = query.filter(Doctor.consultation_fee <= max_fee)

    if min_rating is not None:
        query = query.filter(Doctor.average_rating >= min_rating)

    if available:
        
        from ..models import DoctorSchedule
        query = query.join(Doctor.schedules).filter(DoctorSchedule.is_active == True)

    # pagination
    if page < 1:
        page = 1
    if per_page < 1 or per_page > 100:
        per_page = 20

    offset = (page - 1) * per_page
    doctors = query.order_by(Doctor.average_rating.desc(), Doctor.created_at.desc()).offset(offset).limit(per_page).all()
    return doctors
@router.get("/{doctor_id}", response_model=DoctorResponse)
def get_doctor(doctor_id: int, db: Session = Depends(get_db)):
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id).join(User).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    return doctor

@router.post("/", response_model=DoctorResponse, status_code=status.HTTP_201_CREATED)
def create_doctor(doctor_in: DoctorCreate,
                  db: Session = Depends(get_db),
                  admin_user = Depends(require_admin)):
    
    user = db.query(User).filter(User.id == doctor_in.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if user.role != "doctor":
        raise HTTPException(status_code=400, detail="User must have doctor role")

    existing = db.query(Doctor).filter(Doctor.user_id == doctor_in.user_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Doctor profile already exists")

    if doctor_in.department_id:
        dept = db.query(Department).filter(Department.id == doctor_in.department_id).first()
        if not dept:
            raise HTTPException(status_code=404, detail="Department not found")

    doctor = Doctor(**doctor_in.dict())
    db.add(doctor)
    db.commit()
    db.refresh(doctor)
    return doctor

@router.put("/{doctor_id}", response_model=DoctorResponse)
def update_doctor(doctor_id: int, doctor_in: DoctorUpdate,
                  db: Session = Depends(get_db),
                  current_user = Depends(get_current_user)):
    
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    
    if current_user.role != "admin" and doctor.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    update_data = doctor_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(doctor, field, value)
    
    if 'department_id' in update_data and doctor_in.department_id:
        dept = db.query(Department).filter(Department.id == doctor_in.department_id).first()
        if not dept:
            raise HTTPException(status_code=404, detail="Department not found")
        doctor.department_id = doctor_in.department_id

    db.commit()
    db.refresh(doctor)
    return doctor

@router.delete("/{doctor_id}")
def delete_doctor(doctor_id: int, 
                  db: Session = Depends(get_db),
                  admin_user = Depends(require_admin)):
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")

    db.delete(doctor)
    db.commit()
    return {"message": "Doctor deleted successfully"}

@router.get("/me", response_model=DoctorResponse)
def get_my_doctor_profile(current_user=Depends(require_doctor), db: Session = Depends(get_db)):
    doctor = db.query(Doctor).filter(Doctor.user_id == current_user.id).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor profile not found")
    return doctor