# Student Assistant System

A Flutter application for student module assistance applications with admin management.

## 🔑 Admin Login Credentials

**Default Admin Accounts:**
- **Email:** `admin@studentassistant.com`
- **Password:** `AdminPass123!`

- **Email:** `lecturer@university.com`  
- **Password:** `LecturerPass123!`

## 🚀 Quick Setup

### 1. Database Setup
1. Open `SUPABASE_QUICK_START.md` for complete setup guide
2. Run the SQL commands from `supabase_setup_simple.sql` in Supabase SQL Editor
3. Run the SQL commands from `create_admin_users.sql` to create admin users

### 2. Configure App
Edit `lib/services/supabase_service.dart`:
```dart
static const String _supabaseUrl = 'YOUR_SUPABASE_URL';
static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Test the App
- **Student Registration:** Any email/password creates student account
- **Admin Login:** Use the admin credentials above
- **Student Login:** Use registered student credentials

## 📱 Features

- **Student Registration & Login**
- **Module Assistance Applications**
- **Admin Dashboard** - View and manage all applications
- **Student Dashboard** - Submit and track applications
- **Role-based Access Control**

## 🗄️ Database Tables

- `students` - Student profiles linked to Supabase Auth
- `applications` - Module assistance applications with status tracking

## 🔐 Authentication

- **Students:** Can register and login normally
- **Admins:** Predefined admin emails with special privileges
- **Row Level Security:** Students only see their own data, admins see all

## 📚 Documentation

- `SUPABASE_QUICK_START.md` - 5-minute setup guide
- `SUPABASE_SETUP.md` - Detailed setup instructions
- `DATA_DICTIONARY.md` - Database schema reference
- `ARCHITECTURE.md` - App architecture and design patterns

## 🛠️ Tech Stack

- **Frontend:** Flutter with Provider state management
- **Backend:** Supabase (PostgreSQL + Auth + Realtime)
- **Architecture:** MVVM pattern
