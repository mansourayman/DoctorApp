from pydantic import BaseModel, EmailStr, Field
from datetime import datetime, time, date
from typing import Optional, List

class UserBase(BaseModel):
    full_name: str = Field(..., max_length=150)
    email: EmailStr
    phone: str = Field(..., max_length=30)
    avatar_url: Optional[str] = Field(None, max_length=500)

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = Field(None, min_length=10, max_length=30)
    avatar_url: Optional[str] = None

class UserResponse(UserBase):
    id: int
    role: str
    avatar_url: Optional[str] = None
    created_at: datetime

    class Config:
        orm_mode = True

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

# Department
class DepartmentBase(BaseModel):
    name: str
    description: Optional[str] = None

class DepartmentCreate(DepartmentBase):
    pass

class DepartmentResponse(DepartmentBase):
    id: int
    created_at: datetime

    class Config:
        orm_mode = True

# Doctor
class DoctorBase(BaseModel):
    bio: Optional[str] = None
    specialization: Optional[str] = None
    years_experience: Optional[int] = 0
    consultation_fee: Optional[float] = 0.0

class DoctorCreate(DoctorBase):
    user_id: int
    department_id: Optional[int] = None

class DoctorUpdate(DoctorBase):
    department_id: Optional[int] = None

class DoctorResponse(DoctorBase):
    id: int
    user: UserResponse
    department: Optional[DepartmentResponse] = None
    average_rating: Optional[float] = 0.0
    created_at: datetime

    class Config:
        orm_mode = True

# Appointment
class AppointmentBase(BaseModel):
    start_datetime: datetime
    end_datetime: datetime
    reason: Optional[str] = None

class AppointmentCreate(AppointmentBase):
    doctor_id: int
    department_id: Optional[int] = None  # Optional, inferred from doctor

class AppointmentResponse(AppointmentBase):
    id: int
    status: str
    patient: UserResponse
    doctor: DoctorResponse
    department: Optional[DepartmentResponse] = None
    created_at: datetime

    class Config:
        orm_mode = True

# Review
class ReviewBase(BaseModel):
    rating: int = Field(..., gt=0, le=5)
    comment: Optional[str] = None

class ReviewCreate(ReviewBase):
    appointment_id: int

class ReviewResponse(ReviewBase):
    id: int
    created_at: datetime
    patient: UserResponse
    doctor: DoctorResponse

    class Config:
        orm_mode = True

# Notification
class NotificationBase(BaseModel):
    title: Optional[str] = None
    body: Optional[str] = None

class NotificationCreate(NotificationBase):
    user_id: int

class NotificationResponse(NotificationBase):
    id: int
    is_read: bool
    created_at: datetime

    class Config:
        orm_mode = True
# في schemas.py (أضف بعد NotificationCreate)
class NotificationSend(BaseModel):
    title: Optional[str] = None
    body: Optional[str] = None
    user_id: Optional[int] = None
    role: Optional[str] = None
