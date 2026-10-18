from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import SessionLocal
from ..models import Notification, User
from ..schemas import NotificationCreate, NotificationResponse
from .auth2 import get_current_user, require_admin

router = APIRouter(prefix="/notifications", tags=["Notifications"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/my-notifications", response_model=List[NotificationResponse])
def get_my_notifications(current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    notifications = db.query(Notification).filter(Notification.user_id == current_user.id).order_by(Notification.created_at.desc()).all()
    return notifications

@router.patch("/{notification_id}/read")
def mark_as_read(notification_id: int, current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()
    if not notification:
        raise HTTPException(status_code=404, detail="Not found")
    
    notification.is_read = True
    db.commit()
    return {"message": "Marked as read"}

@router.post("/send", status_code=status.HTTP_201_CREATED)
def send_notification(payload: NotificationCreate, admin_user=Depends(require_admin), db: Session = Depends(get_db)):
    """
    Send notification:
    - If user_id provided -> send to that user
    - Else if role provided -> send to all users with that role
    - Else -> send to ALL users (use with caution)
    """
    recipients = []
    if payload.user_id:
        user = db.query(User).filter(User.id == payload.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        recipients = [user]
    elif payload.role:
        if payload.role not in ("patient", "doctor", "admin"):
            raise HTTPException(status_code=400, detail="Invalid role")
        recipients = db.query(User).filter(User.role == payload.role).all()
    else:
        # broadcast to all users — optional: you might restrict this
        recipients = db.query(User).all()

    created = []
    for r in recipients:
        note = Notification(user_id=r.id, title=payload.title, body=payload.body, is_read=False)
        db.add(note)
        created.append(note)
    db.commit()
    # refresh each to get ids/timestamps
    for n in created:
        db.refresh(n)
    # return list of created notifications (or a simple message)
    return {"sent": len(created)}

@router.get("/", response_model=List[NotificationResponse])
def get_all_notifications(admin_user=Depends(require_admin), db: Session = Depends(get_db)):
    notifications = db.query(Notification).order_by(Notification.created_at.desc()).all()
    return notifications