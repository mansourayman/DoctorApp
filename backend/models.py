from sqlalchemy import (
    Column, Integer, String, Text, Enum, ForeignKey, Date, DateTime,
    Time, Boolean, DECIMAL, TIMESTAMP, func, CheckConstraint, Index
)
from sqlalchemy.orm import relationship
from .database import Base
from sqlalchemy.dialects.mysql import TINYINT

# Users Table
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    full_name = Column(String(150), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    phone = Column(String(30), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(Enum("patient", "doctor", "admin", name="role_enum"), nullable=False, server_default="patient")
    avatar_url = Column(String(500), nullable=True)
    created_at = Column(TIMESTAMP, server_default=func.current_timestamp())
    updated_at = Column(TIMESTAMP, server_default=func.current_timestamp(), onupdate=func.current_timestamp())

    doctor_details = relationship("Doctor", uselist=False, back_populates="user", cascade="all, delete")
    appointments_as_patient = relationship("Appointment", back_populates="patient", foreign_keys="Appointment.patient_id", cascade="all, delete-orphan")
    reviews_as_patient = relationship("Review", back_populates="patient", foreign_keys="Review.patient_id", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")

# Department Table
class Department(Base):
    __tablename__ = "departments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(120), unique=True, nullable=False)
    description = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP, server_default=func.current_timestamp())

    doctors = relationship("Doctor", back_populates="department")
    appointments = relationship("Appointment", back_populates="department")

# Doctor Table
class Doctor(Base):
    __tablename__ = "doctors"

    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    department_id = Column(Integer, ForeignKey("departments.id", ondelete="SET NULL"), nullable=True)
    bio = Column(Text, nullable=True)
    specialization = Column(String(255), nullable=True)
    years_experience = Column(Integer, server_default="0")
    consultation_fee = Column(DECIMAL(8, 2), server_default="0.00")
    average_rating = Column(DECIMAL(3, 2), server_default="0.00")
    created_at = Column(TIMESTAMP, server_default=func.current_timestamp())

    user = relationship("User", back_populates="doctor_details")
    department = relationship("Department", back_populates="doctors")
    schedules = relationship("DoctorSchedule", back_populates="doctor", cascade="all, delete-orphan")
    appointments = relationship("Appointment", back_populates="doctor", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="doctor", cascade="all, delete-orphan")

# Doctor Schedule Table
class DoctorSchedule(Base):
    __tablename__ = "doctor_schedules"

    id = Column(Integer, primary_key=True, autoincrement=True)
    doctor_id = Column(Integer, ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False)
    day_of_week = Column(TINYINT)  # 0=Sun .. 6=Sat
    start_time = Column(Time)
    end_time = Column(Time)
    date_specific = Column(Date)
    slot_duration_minutes = Column(Integer, server_default="15")
    is_active = Column(Boolean, server_default="1")
    created_at = Column(TIMESTAMP, server_default=func.current_timestamp())

    doctor = relationship("Doctor", back_populates="schedules")

# Appointment Table
class Appointment(Base):
    __tablename__ = "appointments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    patient_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    doctor_id = Column(Integer, ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False)
    department_id = Column(Integer, ForeignKey("departments.id", ondelete="SET NULL"), nullable=True)
    start_datetime = Column(DateTime, nullable=False)
    end_datetime = Column(DateTime, nullable=False)
    status = Column(Enum('pending', 'confirmed', 'cancelled', 'completed', 'rejected', name="appointment_status"), server_default="pending")
    reason = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP, server_default=func.current_timestamp())
    updated_at = Column(TIMESTAMP, server_default=func.current_timestamp(), onupdate=func.current_timestamp())

    patient = relationship("User", back_populates="appointments_as_patient", foreign_keys=[patient_id])
    doctor = relationship("Doctor", back_populates="appointments")
    department = relationship("Department", back_populates="appointments")
    review = relationship("Review", back_populates="appointment", uselist=False, cascade="all, delete-orphan")

    __table_args__ = (Index("idx_doctor_start", "doctor_id", "start_datetime"),)

# Review Table
class Review(Base):
    __tablename__ = "reviews"

    id = Column(Integer, primary_key=True, autoincrement=True)
    appointment_id = Column(Integer, ForeignKey("appointments.id", ondelete="SET NULL"), unique=True)
    patient_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    doctor_id = Column(Integer, ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False)
    rating = Column(TINYINT, nullable=False)
    comment = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP, server_default=func.current_timestamp())

    __table_args__ = (CheckConstraint("rating >= 1 AND rating <= 5", name="rating_check"),)

    appointment = relationship("Appointment", back_populates="review")
    patient = relationship("User", back_populates="reviews_as_patient", foreign_keys=[patient_id])
    doctor = relationship("Doctor", back_populates="reviews")

# Notification Table
class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(255), nullable=True)
    body = Column(Text, nullable=True)
    is_read = Column(Boolean, server_default="0")
    created_at = Column(TIMESTAMP, server_default=func.current_timestamp())

    user = relationship("User", back_populates="notifications")