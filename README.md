# Clinic Appointment System

This repository brings the clinic appointment apps, API, and admin panel together in one project.

## Project folders

- `lib/` — patient appointment Flutter app
- `doctorapp/` — doctor Flutter app
- `backend/` — FastAPI service and database models
- `adminControl/` — Python desktop admin panel

## Requirements

- Flutter and Dart for either mobile app
- Python 3.10 or newer and MySQL for the API
- Python with Tk support for the desktop admin panel

## Run the API

1. Create and activate a Python virtual environment.
2. Install dependencies with `pip install -r requirements.txt`.
3. Copy `.env.example` to `.env` and set `DATABASE_URL` and a private `JWT_SECRET_KEY`.
4. From this repository folder, start the service with `uvicorn backend.main:app --reload`.

The MySQL database named in `DATABASE_URL` must exist before starting the API.

## Run the apps

Run `flutter pub get` in the repository root for the patient app, or in `doctorapp/` for the doctor app. Then use `flutter run` in that same folder.

## Run the admin panel

Install the Python dependencies, start the API, then run `python adminControl/adminControl.py` from this repository folder.

The admin panel connects to `http://127.0.0.1:8000` by default.
