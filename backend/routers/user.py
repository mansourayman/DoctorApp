from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import SessionLocal
from ..models import User
from ..schemas import UserResponse, UserUpdate
from .auth2 import get_current_user, require_admin

router = APIRouter(prefix="/users", tags=["Users"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/me", response_model=UserResponse)
def get_my_profile(current_user: User = Depends(get_current_user)):
    return current_user

@router.put("/me", response_model=UserResponse)
def update_my_profile(update_data: UserUpdate,
                      db: Session = Depends(get_db),
                      current_user: User = Depends(get_current_user)):

    # Load the user using the local DB session so the instance is "persistent" here
    user = db.query(User).filter(User.id == current_user.id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if update_data.full_name is not None:
        user.full_name = update_data.full_name
    if update_data.email is not None:
        user.email = update_data.email
    if update_data.phone is not None:
        user.phone = update_data.phone
    if update_data.avatar_url is not None:
        user.avatar_url = update_data.avatar_url

    db.commit()
    db.refresh(user)
    return user


@router.get("/", response_model=list[UserResponse])
def get_all_users(db: Session = Depends(get_db),
                  admin_user: User = Depends(require_admin)):
    users = db.query(User).all()
    return users

@router.get("/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db),
             admin_user: User = Depends(require_admin)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.delete("/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db),
                admin_user: User = Depends(require_admin)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    db.delete(user)
    db.commit()
    return {"message": "User deleted successfully"}

@router.patch("/{user_id}/role")
def update_user_role(user_id: int, new_role: str, db: Session = Depends(get_db),
                     admin_user: User = Depends(require_admin)):
    if new_role not in ["patient", "doctor", "admin"]:
        raise HTTPException(status_code=400, detail="Invalid role")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.role = new_role
    db.commit()
    return {"message": f"User role updated to {new_role}"}