import tkinter as tk
from tkinter import ttk, messagebox
import requests
import json
from typing import Optional, List
from datetime import datetime

# API Configuration
API_BASE_URL = "http://127.0.0.1:8000"
HEADERS = {"Content-Type": "application/json"}

class AdminGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Admin Control Panel - Clinic API (Full Version)")
        self.root.geometry("1000x700")
        
        self.token: Optional[str] = None
        self.current_user = None
        
        # Create login frame initially
        self.show_login()
    
    def show_login(self):
        # Clear window
        for widget in self.root.winfo_children():
            widget.destroy()
        
        login_frame = ttk.Frame(self.root, padding="20")
        login_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        ttk.Label(login_frame, text="Admin Login", font=("Arial", 16)).grid(row=0, column=0, columnspan=2, pady=10)
        
        ttk.Label(login_frame, text="Email/Phone:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.login_identifier = ttk.Entry(login_frame, width=30)
        self.login_identifier.grid(row=1, column=1, pady=5)
        
        ttk.Label(login_frame, text="Password:").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.login_password = ttk.Entry(login_frame, show="*", width=30)
        self.login_password.grid(row=2, column=1, pady=5)
        
        ttk.Button(login_frame, text="Login", command=self.login).grid(row=3, column=0, columnspan=2, pady=20)
    
    def login(self):
        identifier = self.login_identifier.get()
        password = self.login_password.get()
        if not identifier or not password:
            messagebox.showerror("Error", "Please fill in all fields.")
            return
        
        try:
            response = requests.post(
                f"{API_BASE_URL}/auth/token",
                data={"username": identifier, "password": password},
                headers={"Content-Type": "application/x-www-form-urlencoded"}
            )
            response.raise_for_status()
            data = response.json()
            self.token = data["access_token"]
            HEADERS["Authorization"] = f"Bearer {self.token}"
            
            # Get current user to verify admin
            user_response = requests.get(f"{API_BASE_URL}/users/me", headers=HEADERS)
            user_response.raise_for_status()
            self.current_user = user_response.json()
            
            if self.current_user["role"] != "admin":
                messagebox.showerror("Error", "Admin access required.")
                self.token = None
                return
            
            messagebox.showinfo("Success", "Login successful!")
            self.show_main_window()
            
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Login failed: {str(e)}")
    
    def show_main_window(self):
        # Clear window
        for widget in self.root.winfo_children():
            widget.destroy()
        
        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Title with user info
        title_frame = ttk.Frame(main_frame)
        title_frame.grid(row=0, column=0, sticky=(tk.W, tk.E), pady=5)
        ttk.Label(title_frame, text=f"Welcome, {self.current_user['full_name']} ({self.current_user['role']})", font=("Arial", 12)).pack(side=tk.LEFT)
        ttk.Button(title_frame, text="Logout", command=self.logout).pack(side=tk.RIGHT)
        
        # Notebook for tabs
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=10)
        
        # Dashboard tab
        self.dashboard_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.dashboard_frame, text="Dashboard")
        self.setup_dashboard()
        
        # Users tab
        self.users_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.users_frame, text="Users")
        self.setup_users_tab()
        
        # Departments tab
        self.dept_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.dept_frame, text="Departments")
        self.setup_departments_tab()
        
        # Doctors tab
        self.doctor_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.doctor_frame, text="Doctors")
        self.setup_doctors_tab()
        
        # Appointments tab
        self.app_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.app_frame, text="Appointments")
        self.setup_appointments_tab()
        
        # Reviews tab
        self.review_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.review_frame, text="Reviews")
        self.setup_reviews_tab()
        
        # Notifications tab
        self.notif_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.notif_frame, text="Notifications")
        self.setup_notifications_tab()
        
        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(1, weight=1)
    
    def logout(self):
        self.token = None
        self.current_user = None
        self.show_login()
    
    def setup_dashboard(self):
        # Simple stats
        stats_frame = ttk.LabelFrame(self.dashboard_frame, text="Quick Stats", padding="10")
        stats_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=10, pady=10)
        
        try:
            # Total users
            users = requests.get(f"{API_BASE_URL}/users/", headers=HEADERS).json()
            ttk.Label(stats_frame, text=f"Total Users: {len(users)}").grid(row=0, column=0, sticky=tk.W, pady=5)
            
            # Total departments
            depts = requests.get(f"{API_BASE_URL}/departments/", headers=HEADERS).json()
            ttk.Label(stats_frame, text=f"Total Departments: {len(depts)}").grid(row=1, column=0, sticky=tk.W, pady=5)
            
            # Total doctors
            doctors = requests.get(f"{API_BASE_URL}/doctors/", headers=HEADERS).json()
            ttk.Label(stats_frame, text=f"Total Doctors: {len(doctors)}").grid(row=2, column=0, sticky=tk.W, pady=5)
            
            # Total appointments
            appts = requests.get(f"{API_BASE_URL}/appointments/", headers=HEADERS).json()  # Note: may need admin endpoint if not exists
            ttk.Label(stats_frame, text=f"Total Appointments: {len(appts)}").grid(row=3, column=0, sticky=tk.W, pady=5)
            
        except:
            pass  # Fallback if endpoints vary
        
        self.dashboard_frame.columnconfigure(0, weight=1)
        self.dashboard_frame.rowconfigure(0, weight=1)
    
    def setup_users_tab(self):
        # List frame
        list_frame = ttk.LabelFrame(self.users_frame, text="Users List", padding="10")
        list_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=5, pady=5)
        
        columns = ("ID", "Full Name", "Email", "Phone", "Role")
        self.user_tree = ttk.Treeview(list_frame, columns=columns, show="headings", height=15)
        for col in columns:
            self.user_tree.heading(col, text=col)
            self.user_tree.column(col, width=150)
        self.user_tree.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.user_tree.yview)
        scrollbar.grid(row=0, column=1, sticky=(tk.N, tk.S))
        self.user_tree.configure(yscrollcommand=scrollbar.set)
        
        btn_frame = ttk.Frame(list_frame)
        btn_frame.grid(row=1, column=0, columnspan=2, pady=5)
        ttk.Button(btn_frame, text="Refresh", command=self.refresh_users).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Add", command=self.add_user).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Edit", command=self.edit_user).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Delete", command=self.delete_user).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Change Role", command=self.change_user_role).pack(side=tk.LEFT, padx=5)
        
        # Form frame
        form_frame = ttk.LabelFrame(self.users_frame, text="Add/Edit User", padding="10")
        form_frame.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=5, pady=5)
        
        ttk.Label(form_frame, text="Full Name:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.user_fullname = ttk.Entry(form_frame, width=25)
        self.user_fullname.grid(row=0, column=1, pady=5)
        
        ttk.Label(form_frame, text="Email:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.user_email = ttk.Entry(form_frame, width=25)
        self.user_email.grid(row=1, column=1, pady=5)
        
        ttk.Label(form_frame, text="Phone:").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.user_phone = ttk.Entry(form_frame, width=25)
        self.user_phone.grid(row=2, column=1, pady=5)
        
        ttk.Label(form_frame, text="Password:").grid(row=3, column=0, sticky=tk.W, pady=5)
        self.user_password = ttk.Entry(form_frame, show="*", width=25)
        self.user_password.grid(row=3, column=1, pady=5)
        
        ttk.Label(form_frame, text="Role:").grid(row=4, column=0, sticky=tk.W, pady=5)
        self.user_role = ttk.Combobox(form_frame, values=["patient", "doctor", "admin"], width=23)
        self.user_role.grid(row=4, column=1, pady=5)
        
        ttk.Button(form_frame, text="Save", command=self.save_user).grid(row=5, column=0, columnspan=2, pady=10)
        
        list_frame.columnconfigure(0, weight=1)
        list_frame.rowconfigure(0, weight=1)
        self.users_frame.columnconfigure(0, weight=1)
        self.users_frame.rowconfigure(0, weight=1)
        
        self.refresh_users()
    
    def refresh_users(self):
        try:
            response = requests.get(f"{API_BASE_URL}/users/", headers=HEADERS)
            response.raise_for_status()
            users = response.json()
            
            for item in self.user_tree.get_children():
                self.user_tree.delete(item)
            
            for user in users:
                self.user_tree.insert("", tk.END, values=(user["id"], user["full_name"], user["email"], user["phone"], user["role"]))
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed to fetch users: {str(e)}")
    
    def add_user(self):
        self.user_tree.selection_set()  # Clear
        self.user_fullname.delete(0, tk.END)
        self.user_email.delete(0, tk.END)
        self.user_phone.delete(0, tk.END)
        self.user_password.delete(0, tk.END)
        self.user_role.set("")
        self.user_fullname.focus()
    
    def edit_user(self):
        selection = self.user_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select a user to edit.")
            return
        
        item = self.user_tree.item(selection[0])
        values = item["values"]
        self.user_fullname.delete(0, tk.END)
        self.user_fullname.insert(0, values[1])
        self.user_email.delete(0, tk.END)
        self.user_email.insert(0, values[2])
        self.user_phone.delete(0, tk.END)
        self.user_phone.insert(0, values[3])
        self.user_role.set(values[4])
        self.user_password.delete(0, tk.END)  # Password not shown
    
    def save_user(self):
        fullname = self.user_fullname.get().strip()
        email = self.user_email.get().strip()
        phone = self.user_phone.get().strip()
        password = self.user_password.get().strip()
        role = self.user_role.get()
        
        if not all([fullname, email, phone, role]):
            messagebox.showerror("Error", "All fields except password are required.")
            return
        
        data = {
            "full_name": fullname,
            "email": email,
            "phone": phone,
            "role": role  # Will be set after create
        }
        
        try:
            selection = self.user_tree.selection()
            if selection:
                # Update (password optional)
                user_id = self.user_tree.item(selection[0])["values"][0]
                if password:
                    data["password"] = password  # Assuming update accepts it, but may need change-password endpoint
                response = requests.put(f"{API_BASE_URL}/users/{user_id}", json=data, headers=HEADERS)
            else:
                # Create
                if not password or len(password) < 8:
                    messagebox.showerror("Error", "Password required for new user (min 8 chars).")
                    return
                data["password"] = password
                response = requests.post(f"{API_BASE_URL}/auth/register", json=data, headers=HEADERS)
                user_data = response.json()
                user_id = user_data["id"]
                # Set role
                requests.patch(f"{API_BASE_URL}/users/{user_id}/role", json={"new_role": role}, headers=HEADERS)
            
            response.raise_for_status()
            messagebox.showinfo("Success", "User saved!")
            self.refresh_users()
            self.add_user()
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed to save user: {str(e)}")
    
    def delete_user(self):
        selection = self.user_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select a user to delete.")
            return
        
        if messagebox.askyesno("Confirm", "Delete this user?"):
            user_id = self.user_tree.item(selection[0])["values"][0]
            try:
                response = requests.delete(f"{API_BASE_URL}/users/{user_id}", headers=HEADERS)
                response.raise_for_status()
                messagebox.showinfo("Success", "User deleted!")
                self.refresh_users()
            except requests.exceptions.RequestException as e:
                messagebox.showerror("Error", f"Failed to delete user: {str(e)}")
    
    def change_user_role(self):
        selection = self.user_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select a user to change role.")
            return
        
        user_id = self.user_tree.item(selection[0])["values"][0]
        new_role = tk.simpledialog.askstring("Change Role", "Enter new role (patient/doctor/admin):")
        if new_role in ["patient", "doctor", "admin"]:
            try:
                response = requests.patch(f"{API_BASE_URL}/users/{user_id}/role", json={"new_role": new_role}, headers=HEADERS)
                response.raise_for_status()
                messagebox.showinfo("Success", f"Role changed to {new_role}")
                self.refresh_users()
            except requests.exceptions.RequestException as e:
                messagebox.showerror("Error", f"Failed to change role: {str(e)}")
        else:
            messagebox.showerror("Error", "Invalid role.")
    
    def setup_departments_tab(self):
        # Similar to previous, but abbreviated for space
        list_frame = ttk.LabelFrame(self.dept_frame, text="Departments List", padding="10")
        list_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=5, pady=5)
        
        columns = ("ID", "Name", "Description")
        self.dept_tree = ttk.Treeview(list_frame, columns=columns, show="headings", height=10)
        for col in columns:
            self.dept_tree.heading(col, text=col)
            self.dept_tree.column(col, width=150)
        self.dept_tree.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.dept_tree.yview)
        scrollbar.grid(row=0, column=1, sticky=(tk.N, tk.S))
        self.dept_tree.configure(yscrollcommand=scrollbar.set)
        
        btn_frame = ttk.Frame(list_frame)
        btn_frame.grid(row=1, column=0, columnspan=2, pady=5)
        ttk.Button(btn_frame, text="Refresh", command=self.refresh_departments).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Add", command=self.add_department).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Edit", command=self.edit_department).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Delete", command=self.delete_department).pack(side=tk.LEFT, padx=5)
        
        form_frame = ttk.LabelFrame(self.dept_frame, text="Add/Edit Department", padding="10")
        form_frame.grid(row=1, column=0, sticky=(tk.W, tk.E), padx=5, pady=5)
        
        ttk.Label(form_frame, text="Name:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.dept_name = ttk.Entry(form_frame, width=30)
        self.dept_name.grid(row=0, column=1, pady=5)
        
        ttk.Label(form_frame, text="Description:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.dept_desc = tk.Text(form_frame, width=30, height=3)
        self.dept_desc.grid(row=1, column=1, pady=5)
        
        ttk.Button(form_frame, text="Save", command=self.save_department).grid(row=2, column=0, columnspan=2, pady=10)
        
        list_frame.columnconfigure(0, weight=1)
        list_frame.rowconfigure(0, weight=1)
        self.dept_frame.columnconfigure(0, weight=1)
        
        self.refresh_departments()
    
    # Department methods (same as previous)
    def refresh_departments(self):
        try:
            response = requests.get(f"{API_BASE_URL}/departments/", headers=HEADERS)
            response.raise_for_status()
            depts = response.json()
            
            for item in self.dept_tree.get_children():
                self.dept_tree.delete(item)
            
            for dept in depts:
                self.dept_tree.insert("", tk.END, values=(dept["id"], dept["name"], dept["description"] or ""))
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed to fetch departments: {str(e)}")
    
    def add_department(self):
        self.dept_tree.selection_set()
        self.dept_name.delete(0, tk.END)
        self.dept_desc.delete(1.0, tk.END)
        self.dept_name.focus()
    
    def edit_department(self):
        selection = self.dept_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select a department to edit.")
            return
        
        item = self.dept_tree.item(selection[0])
        values = item["values"]
        self.dept_name.delete(0, tk.END)
        self.dept_name.insert(0, values[1])
        self.dept_desc.delete(1.0, tk.END)
        self.dept_desc.insert(1.0, values[2])
    
    def save_department(self):
        name = self.dept_name.get().strip()
        desc = self.dept_desc.get(1.0, tk.END).strip()
        if not name:
            messagebox.showerror("Error", "Name is required.")
            return
        
        data = {"name": name, "description": desc if desc else None}
        
        try:
            selection = self.dept_tree.selection()
            if selection:
                dept_id = self.dept_tree.item(selection[0])["values"][0]
                response = requests.put(f"{API_BASE_URL}/departments/{dept_id}", json=data, headers=HEADERS)
            else:
                response = requests.post(f"{API_BASE_URL}/departments/", json=data, headers=HEADERS)
            response.raise_for_status()
            messagebox.showinfo("Success", "Department saved!")
            self.refresh_departments()
            self.add_department()
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed to save department: {str(e)}")
    
    def delete_department(self):
        selection = self.dept_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select a department to delete.")
            return
        
        if messagebox.askyesno("Confirm", "Delete this department?"):
            dept_id = self.dept_tree.item(selection[0])["values"][0]
            try:
                response = requests.delete(f"{API_BASE_URL}/departments/{dept_id}", headers=HEADERS)
                response.raise_for_status()
                messagebox.showinfo("Success", "Department deleted!")
                self.refresh_departments()
            except requests.exceptions.RequestException as e:
                messagebox.showerror("Error", f"Failed to delete department: {str(e)}")
    
    def setup_doctors_tab(self):
        # User creation for doctors
        user_frame = ttk.LabelFrame(self.doctor_frame, text="Create Doctor User", padding="10")
        user_frame.grid(row=0, column=0, sticky=(tk.W, tk.E), padx=5, pady=5, columnspan=2)
        
        ttk.Label(user_frame, text="Full Name:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.doctor_user_fullname = ttk.Entry(user_frame, width=20)
        self.doctor_user_fullname.grid(row=0, column=1, pady=5)
        
        ttk.Label(user_frame, text="Email:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.doctor_user_email = ttk.Entry(user_frame, width=20)
        self.doctor_user_email.grid(row=1, column=1, pady=5)
        
        ttk.Label(user_frame, text="Phone:").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.doctor_user_phone = ttk.Entry(user_frame, width=20)
        self.doctor_user_phone.grid(row=2, column=1, pady=5)
        
        ttk.Label(user_frame, text="Password:").grid(row=3, column=0, sticky=tk.W, pady=5)
        self.doctor_user_password = ttk.Entry(user_frame, show="*", width=20)
        self.doctor_user_password.grid(row=3, column=1, pady=5)
        
        ttk.Button(user_frame, text="Create User & Set Doctor", command=self.create_doctor_user).grid(row=4, column=0, columnspan=2, pady=10)
        
        # Doctor profile
        profile_frame = ttk.LabelFrame(self.doctor_frame, text="Doctor Profile", padding="10")
        profile_frame.grid(row=1, column=0, sticky=(tk.W, tk.E), padx=5, pady=5)
        
        ttk.Label(profile_frame, text="User ID:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.doctor_user_id = ttk.Entry(profile_frame, width=20)
        self.doctor_user_id.grid(row=0, column=1, pady=5)
        
        ttk.Label(profile_frame, text="Department ID:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.doctor_dept_id = ttk.Entry(profile_frame, width=20)
        self.doctor_dept_id.grid(row=1, column=1, pady=5)
        
        ttk.Label(profile_frame, text="Bio:").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.doctor_bio = tk.Text(profile_frame, width=20, height=2)
        self.doctor_bio.grid(row=2, column=1, pady=5)
        
        ttk.Label(profile_frame, text="Specialization:").grid(row=3, column=0, sticky=tk.W, pady=5)
        self.doctor_specialization = ttk.Entry(profile_frame, width=20)
        self.doctor_specialization.grid(row=3, column=1, pady=5)
        
        ttk.Label(profile_frame, text="Years Exp:").grid(row=4, column=0, sticky=tk.W, pady=5)
        self.doctor_years = ttk.Entry(profile_frame, width=20)
        self.doctor_years.grid(row=4, column=1, pady=5)
        
        ttk.Label(profile_frame, text="Fee:").grid(row=5, column=0, sticky=tk.W, pady=5)
        self.doctor_fee = ttk.Entry(profile_frame, width=20)
        self.doctor_fee.grid(row=5, column=1, pady=5)
        
        ttk.Button(profile_frame, text="Save Profile", command=self.save_doctor_profile).grid(row=6, column=0, columnspan=2, pady=10)
        
        # List
        list_frame = ttk.LabelFrame(self.doctor_frame, text="Doctors List", padding="10")
        list_frame.grid(row=0, column=1, sticky=(tk.W, tk.E, tk.N, tk.S), rowspan=2, padx=5, pady=5)
        
        columns = ("ID", "User ID", "Name", "Spec", "Fee", "Rating")
        self.doctor_tree = ttk.Treeview(list_frame, columns=columns, show="headings", height=15)
        for col in columns:
            self.doctor_tree.heading(col, text=col)
            self.doctor_tree.column(col, width=100)
        self.doctor_tree.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.doctor_tree.yview)
        scrollbar.grid(row=0, column=1, sticky=(tk.N, tk.S))
        self.doctor_tree.configure(yscrollcommand=scrollbar.set)
        
        btn_frame = ttk.Frame(list_frame)
        btn_frame.grid(row=1, column=0, columnspan=2, pady=5)
        ttk.Button(btn_frame, text="Refresh", command=self.refresh_doctors).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Delete", command=self.delete_doctor).pack(side=tk.LEFT, padx=5)
        
        list_frame.columnconfigure(0, weight=1)
        list_frame.rowconfigure(0, weight=1)
        self.doctor_frame.columnconfigure(1, weight=1)
        self.doctor_frame.rowconfigure(1, weight=1)
        
        self.refresh_doctors()
    
    # Doctor methods
    def create_doctor_user(self):
        fullname = self.doctor_user_fullname.get().strip()
        email = self.doctor_user_email.get().strip()
        phone = self.doctor_user_phone.get().strip()
        password = self.doctor_user_password.get().strip()
        
        if not all([fullname, email, phone, password]):
            messagebox.showerror("Error", "All fields required.")
            return
        
        try:
            reg_data = {"full_name": fullname, "email": email, "phone": phone, "password": password}
            reg_resp = requests.post(f"{API_BASE_URL}/auth/register", json=reg_data, headers=HEADERS)
            reg_resp.raise_for_status()
            user_data = reg_resp.json()
            user_id = user_data["id"]
            
            role_resp = requests.patch(f"{API_BASE_URL}/users/{user_id}/role", json={"new_role": "doctor"}, headers=HEADERS)
            role_resp.raise_for_status()
            
            messagebox.showinfo("Success", f"Doctor user ID: {user_id}")
            self.doctor_user_id.insert(0, str(user_id))
            # Clear
            for entry in [self.doctor_user_fullname, self.doctor_user_email, self.doctor_user_phone, self.doctor_user_password]:
                entry.delete(0, tk.END)
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def save_doctor_profile(self):
        user_id_str = self.doctor_user_id.get().strip()
        if not user_id_str:
            messagebox.showerror("Error", "User ID required.")
            return
        
        try:
            user_id = int(user_id_str)
        except ValueError:
            messagebox.showerror("Error", "Invalid User ID.")
            return
        
        data = {
            "user_id": user_id,
            "department_id": int(self.doctor_dept_id.get().strip()) if self.doctor_dept_id.get().strip() else None,
            "bio": self.doctor_bio.get(1.0, tk.END).strip() or None,
            "specialization": self.doctor_specialization.get().strip() or None,
            "years_experience": int(self.doctor_years.get().strip() or 0),
            "consultation_fee": float(self.doctor_fee.get().strip() or 0.0)
        }
        
        try:
            response = requests.post(f"{API_BASE_URL}/doctors/", json=data, headers=HEADERS)
            response.raise_for_status()
            messagebox.showinfo("Success", "Profile saved!")
            self.refresh_doctors()
            # Clear profile form
            self.doctor_user_id.delete(0, tk.END)
            self.doctor_dept_id.delete(0, tk.END)
            self.doctor_bio.delete(1.0, tk.END)
            self.doctor_specialization.delete(0, tk.END)
            self.doctor_years.delete(0, tk.END)
            self.doctor_fee.delete(0, tk.END)
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def refresh_doctors(self):
        try:
            response = requests.get(f"{API_BASE_URL}/doctors/", headers=HEADERS)
            response.raise_for_status()
            doctors = response.json()
            
            for item in self.doctor_tree.get_children():
                self.doctor_tree.delete(item)
            
            for doc in doctors:
                name = doc["user"]["full_name"]
                spec = doc["specialization"] or "N/A"
                self.doctor_tree.insert("", tk.END, values=(
                    doc["id"], doc["user_id"], name, spec,
                    doc["consultation_fee"], doc["average_rating"]
                ))
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def delete_doctor(self):
        selection = self.doctor_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select a doctor.")
            return
        
        if messagebox.askyesno("Confirm", "Delete this doctor?"):
            doc_id = self.doctor_tree.item(selection[0])["values"][0]
            try:
                response = requests.delete(f"{API_BASE_URL}/doctors/{doc_id}", headers=HEADERS)
                response.raise_for_status()
                messagebox.showinfo("Success", "Deleted!")
                self.refresh_doctors()
            except requests.exceptions.RequestException as e:
                messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def setup_appointments_tab(self):
        list_frame = ttk.LabelFrame(self.app_frame, text="Appointments List", padding="10")
        list_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=5, pady=5)
        
        columns = ("ID", "Patient", "Doctor", "Start", "End", "Status")
        self.app_tree = ttk.Treeview(list_frame, columns=columns, show="headings", height=15)
        for col in columns:
            self.app_tree.heading(col, text=col)
            self.app_tree.column(col, width=120)
        self.app_tree.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.app_tree.yview)
        scrollbar.grid(row=0, column=1, sticky=(tk.N, tk.S))
        self.app_tree.configure(yscrollcommand=scrollbar.set)
        
        btn_frame = ttk.Frame(list_frame)
        btn_frame.grid(row=1, column=0, columnspan=2, pady=5)
        ttk.Button(btn_frame, text="Refresh", command=self.refresh_appointments).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Update Status", command=self.update_app_status).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Delete", command=self.delete_appointment).pack(side=tk.LEFT, padx=5)
        
        # Status update frame
        status_frame = ttk.LabelFrame(self.app_frame, text="Update Status", padding="10")
        status_frame.grid(row=1, column=0, sticky=(tk.W, tk.E), padx=5, pady=5)
        
        ttk.Label(status_frame, text="New Status:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.app_status = ttk.Combobox(status_frame, values=["pending", "confirmed", "cancelled", "completed", "rejected"], width=20)
        self.app_status.grid(row=0, column=1, pady=5)
        
        ttk.Button(status_frame, text="Apply to Selected", command=self.apply_status).grid(row=1, column=0, columnspan=2, pady=10)
        
        list_frame.columnconfigure(0, weight=1)
        list_frame.rowconfigure(0, weight=1)
        self.app_frame.columnconfigure(0, weight=1)
        
        self.refresh_appointments()
    
    def refresh_appointments(self):
        # Assuming /appointments/ is admin-accessible; else implement
        try:
            response = requests.get(f"{API_BASE_URL}/appointments/", headers=HEADERS)  # May need custom endpoint
            response.raise_for_status()
            appts = response.json()
            
            for item in self.app_tree.get_children():
                self.app_tree.delete(item)
            
            for app in appts:
                self.app_tree.insert("", tk.END, values=(
                    app["id"], app["patient"]["full_name"], app["doctor"]["user"]["full_name"],
                    app["start_datetime"], app["end_datetime"], app["status"]
                ))
        except:
            # Fallback: use doctor-appointments or something
            messagebox.showwarning("Warning", "Appointments endpoint may need admin access.")
    
    def update_app_status(self):
        selection = self.app_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select an appointment.")
            return
        self.app_status.set("")
        # Focus on status combo
    
    def apply_status(self):
        selection = self.app_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select an appointment.")
            return
        
        new_status = self.app_status.get()
        if not new_status:
            messagebox.showerror("Error", "Select a status.")
            return
        
        app_id = self.app_tree.item(selection[0])["values"][0]
        try:
            response = requests.put(f"{API_BASE_URL}/appointments/{app_id}/status", params={"status": new_status}, headers=HEADERS)
            response.raise_for_status()
            messagebox.showinfo("Success", "Status updated!")
            self.refresh_appointments()
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def delete_appointment(self):
        selection = self.app_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select an appointment.")
            return
        
        if messagebox.askyesno("Confirm", "Delete this appointment?"):
            app_id = self.app_tree.item(selection[0])["values"][0]
            try:
                response = requests.delete(f"{API_BASE_URL}/appointments/{app_id}/cancel", headers=HEADERS)  # Use cancel or custom delete
                response.raise_for_status()
                messagebox.showinfo("Success", "Deleted!")
                self.refresh_appointments()
            except requests.exceptions.RequestException as e:
                messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def setup_reviews_tab(self):
        list_frame = ttk.LabelFrame(self.review_frame, text="Reviews List", padding="10")
        list_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=5, pady=5)
        
        columns = ("ID", "Patient", "Doctor", "Rating", "Comment", "Date")
        self.review_tree = ttk.Treeview(list_frame, columns=columns, show="headings", height=15)
        for col in columns:
            self.review_tree.heading(col, text=col)
            self.review_tree.column(col, width=120)
        self.review_tree.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.review_tree.yview)
        scrollbar.grid(row=0, column=1, sticky=(tk.N, tk.S))
        self.review_tree.configure(yscrollcommand=scrollbar.set)
        
        btn_frame = ttk.Frame(list_frame)
        btn_frame.grid(row=1, column=0, columnspan=2, pady=5)
        ttk.Button(btn_frame, text="Refresh", command=self.refresh_reviews).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Delete", command=self.delete_review).pack(side=tk.LEFT, padx=5)
        
        list_frame.columnconfigure(0, weight=1)
        list_frame.rowconfigure(0, weight=1)
        self.review_frame.columnconfigure(0, weight=1)
        
        self.refresh_reviews()
    
    def refresh_reviews(self):
        try:
            # Get all reviews, perhaps aggregate or use /reviews/
            # For now, use doctor reviews example, but loop over doctors or custom endpoint
            response = requests.get(f"{API_BASE_URL}/reviews/", headers=HEADERS)  # Assume endpoint
            response.raise_for_status()
            reviews = response.json()
            
            for item in self.review_tree.get_children():
                self.review_tree.delete(item)
            
            for rev in reviews:
                self.review_tree.insert("", tk.END, values=(
                    rev["id"], rev["patient"]["full_name"], rev["doctor"]["user"]["full_name"],
                    rev["rating"], rev["comment"][:50] + "..." if rev["comment"] else "", rev["created_at"]
                ))
        except:
            messagebox.showwarning("Warning", "Reviews endpoint needed.")
    
    def delete_review(self):
        selection = self.review_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select a review.")
            return
        
        if messagebox.askyesno("Confirm", "Delete this review?"):
            rev_id = self.review_tree.item(selection[0])["values"][0]
            try:
                response = requests.delete(f"{API_BASE_URL}/reviews/{rev_id}", headers=HEADERS)  # Assume delete endpoint
                response.raise_for_status()
                messagebox.showinfo("Success", "Deleted!")
                self.refresh_reviews()
            except requests.exceptions.RequestException as e:
                messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def setup_notifications_tab(self):
        # Send notification frame
        send_frame = ttk.LabelFrame(self.notif_frame, text="Send Notification", padding="10")
        send_frame.grid(row=0, column=0, sticky=(tk.W, tk.E), padx=5, pady=5)
        
        ttk.Label(send_frame, text="Title:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.notif_title = ttk.Entry(send_frame, width=30)
        self.notif_title.grid(row=0, column=1, pady=5)
        
        ttk.Label(send_frame, text="Body:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.notif_body = tk.Text(send_frame, width=30, height=4)
        self.notif_body.grid(row=1, column=1, pady=5)
        
        ttk.Label(send_frame, text="User ID (or leave for all):").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.notif_user_id = ttk.Entry(send_frame, width=30)
        self.notif_user_id.grid(row=2, column=1, pady=5)
        
        ttk.Label(send_frame, text="Role (patient/doctor/admin):").grid(row=3, column=0, sticky=tk.W, pady=5)
        self.notif_role = ttk.Combobox(send_frame, values=["patient", "doctor", "admin"], width=28)
        self.notif_role.grid(row=3, column=1, pady=5)
        
        ttk.Button(send_frame, text="Send", command=self.send_notification).grid(row=4, column=0, columnspan=2, pady=10)
        
        # List frame
        list_frame = ttk.LabelFrame(self.notif_frame, text="Notifications List", padding="10")
        list_frame.grid(row=0, column=1, sticky=(tk.W, tk.E, tk.N, tk.S), padx=5, pady=5)
        
        columns = ("ID", "User ID", "Title", "Body", "Read", "Date")
        self.notif_tree = ttk.Treeview(list_frame, columns=columns, show="headings", height=15)
        for col in columns:
            self.notif_tree.heading(col, text=col)
            self.notif_tree.column(col, width=120)
        self.notif_tree.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.notif_tree.yview)
        scrollbar.grid(row=0, column=1, sticky=(tk.N, tk.S))
        self.notif_tree.configure(yscrollcommand=scrollbar.set)
        
        btn_frame = ttk.Frame(list_frame)
        btn_frame.grid(row=1, column=0, columnspan=2, pady=5)
        ttk.Button(btn_frame, text="Refresh", command=self.refresh_notifications).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Mark Read", command=self.mark_read).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Delete", command=self.delete_notification).pack(side=tk.LEFT, padx=5)
        
        list_frame.columnconfigure(0, weight=1)
        list_frame.rowconfigure(0, weight=1)
        self.notif_frame.columnconfigure(1, weight=1)
        
        self.refresh_notifications()
    
    def send_notification(self):
        title = self.notif_title.get().strip()
        body = self.notif_body.get(1.0, tk.END).strip()
        user_id_str = self.notif_user_id.get().strip()
        role = self.notif_role.get()
        
        if not title or not body:
            messagebox.showerror("Error", "Title and body required.")
            return
        
        data = {"title": title, "body": body}
        if user_id_str:
            try:
                data["user_id"] = int(user_id_str)
            except ValueError:
                messagebox.showerror("Error", "Invalid User ID.")
                return
        elif role:
            data["role"] = role
        
        try:
            response = requests.post(f"{API_BASE_URL}/notifications/send", json=data, headers=HEADERS)
            response.raise_for_status()
            sent_count = response.json().get("sent", 0)
            messagebox.showinfo("Success", f"Sent to {sent_count} users!")
            self.notif_title.delete(0, tk.END)
            self.notif_body.delete(1.0, tk.END)
            self.notif_user_id.delete(0, tk.END)
            self.notif_role.set("")
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def refresh_notifications(self):
        try:
            response = requests.get(f"{API_BASE_URL}/notifications/", headers=HEADERS)
            response.raise_for_status()
            notifs = response.json()
            
            for item in self.notif_tree.get_children():
                self.notif_tree.delete(item)
            
            for notif in notifs:
                self.notif_tree.insert("", tk.END, values=(
                    notif["id"], notif["user_id"], notif["title"], notif["body"][:30] + "...",
                    notif["is_read"], notif["created_at"]
                ))
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def mark_read(self):
        selection = self.notif_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select a notification.")
            return
        
        notif_id = self.notif_tree.item(selection[0])["values"][0]
        try:
            response = requests.patch(f"{API_BASE_URL}/notifications/{notif_id}/read", headers=HEADERS)
            response.raise_for_status()
            messagebox.showinfo("Success", "Marked as read!")
            self.refresh_notifications()
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def delete_notification(self):
        selection = self.notif_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Select a notification.")
            return
        
        if messagebox.askyesno("Confirm", "Delete this notification?"):
            notif_id = self.notif_tree.item(selection[0])["values"][0]
            try:
                response = requests.delete(f"{API_BASE_URL}/notifications/{notif_id}", headers=HEADERS)  # Assume endpoint
                response.raise_for_status()
                messagebox.showinfo("Success", "Deleted!")
                self.refresh_notifications()
            except requests.exceptions.RequestException as e:
                messagebox.showerror("Error", f"Failed: {str(e)}")
    
    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    app = AdminGUI()
    app.run()