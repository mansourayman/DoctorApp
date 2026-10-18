from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import SessionLocal
from ..models import Department
from ..schemas import DepartmentCreate, DepartmentResponse
from .auth2 import require_admin

router = APIRouter(prefix="/departments", tags=["Departments"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/", response_model=list[DepartmentResponse])
def get_all_departments(db: Session = Depends(get_db)):
    departments = db.query(Department).all()
    return departments

@router.get("/{department_id}", response_model=DepartmentResponse)
def get_department(department_id: int, db: Session = Depends(get_db)):
    department = db.query(Department).filter(Department.id == department_id).first()
    if not department:
        raise HTTPException(status_code=404, detail="Department not found")
    return department

@router.post("/", response_model=DepartmentResponse, status_code=status.HTTP_201_CREATED)
def create_department(department_in: DepartmentCreate,
                      db: Session = Depends(get_db),
                      admin_user = Depends(require_admin)):

    existing = db.query(Department).filter(Department.name == department_in.name).first()
    if existing:
        raise HTTPException(status_code=400, detail="Department with this name already exists")

    department = Department(**department_in.dict())
    db.add(department)
    db.commit()
    db.refresh(department)
    return department

@router.put("/{department_id}", response_model=DepartmentResponse)
def update_department(department_id: int, department_in: DepartmentCreate,
                      db: Session = Depends(get_db),
                      admin_user = Depends(require_admin)):
    
    department = db.query(Department).filter(Department.id == department_id).first()
    if not department:
        raise HTTPException(status_code=404, detail="Department not found")

    department.name = department_in.name
    department.description = department_in.description
    db.commit()
    db.refresh(department)
    return department

@router.delete("/{department_id}")
def delete_department(department_id: int, 
                      db: Session = Depends(get_db),
                      admin_user = Depends(require_admin)):
    department = db.query(Department).filter(Department.id == department_id).first()
    if not department:
        raise HTTPException(status_code=404, detail="Department not found")

    db.delete(department)
    db.commit()
    return {"message": "Department deleted successfully"}   
#added
@router.get("/categories", response_model=list[dict])
def get_categories(db: Session = Depends(get_db)):
    """
    Return simplified list of categories for frontend (id + name).
    """
    departments = db.query(Department).order_by(Department.name.asc()).all()
    # return minimal structure
    return [{"id": d.id, "name": d.name} for d in departments]