# Supabase Architecture & Data Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       FLUTTER APP (Client)                      │
│                                                                 │
│  ┌──────────────────────────┐      ┌──────────────────────────┐│
│  │   AuthViewModel          │      │  ApplicationViewModel    ││
│  │  (Auth state)            │      │  (Application state)    ││
│  └────────────┬─────────────┘      └────────────┬─────────────┘│
│               │                                 │               │
│  ┌────────────▼─────────────┐      ┌───────────▼──────────────┐│
│  │   AuthService            │      │ ApplicationService       ││
│  │  • signUp()              │      │ • submitApplication()    ││
│  │  • signIn()              │      │ • getApplications()      ││
│  │  • signOut()             │      │ • updateStatus()         ││
│  │  • isAdmin()             │      │ • deleteApplication()    ││
│  └────────────┬─────────────┘      └───────────┬──────────────┘│
│               │                                 │               │
│               └───────────────────┬─────────────┘               │
│                                   │                             │
│                   ┌───────────────▼───────────────┐            │
│                   │    SupabaseService            │            │
│                   │  • Singleton client instance  │            │
│                   │  • initialize()               │            │
│                   │  • currentUserId              │            │
│                   └───────────────┬───────────────┘            │
└────────────────────────────────────┼─────────────────────────────┘
                                     │
                    ┌────────────────▼────────────────┐
                    │  SUPABASE BACKEND (Cloud)      │
                    │                                │
                    │  ┌──────────────────────────┐ │
                    │  │  Auth Module             │ │
                    │  │  • JWT tokens            │ │
                    │  │  • Sessions              │ │
                    │  │  • User management       │ │
                    │  └──────────────────────────┘ │
                    │                                │
                    │  ┌──────────────────────────┐ │
                    │  │  PostgreSQL Database     │ │
                    │  │  • students table        │ │
                    │  │  • applications table    │ │
                    │  │  • RLS policies         │ │
                    │  └──────────────────────────┘ │
                    │                                │
                    └────────────────────────────────┘
```

---

## Authentication Flow

```
SIGNUP FLOW:
┌─────────┐
│ Register│
│ Screen  │
└────┬────┘
     │ User enters: email, password, name, student#
     │
     ▼
┌──────────────────┐
│ AuthViewModel    │
│ .register()      │
└────┬─────────────┘
     │
     ▼
┌──────────────────────────────┐
│ AuthService.signUp()         │
│                              │
│ 1. Supabase Auth.signUp()    │─────────→ Supabase Auth
│                              │         Creates user account
│ 2. Create student profile    │─────────→ INSERT into students
│    (links to auth user id)   │         Links to auth.users(id)
└──────────────────────────────┘
     │
     ▼
┌──────────────────┐
│ isLoggedIn=true  │
│ Redirect to      │
│ StudentDashboard │
└──────────────────┘

---

LOGIN FLOW:
┌─────────┐
│  Login  │
│ Screen  │
└────┬────┘
     │ User enters: email, password
     │
     ▼
┌──────────────────┐
│ AuthViewModel    │
│ .login()         │
└────┬─────────────┘
     │
     ▼
┌──────────────────────────────┐
│ AuthService.signIn()         │
│                              │
│ Supabase Auth.signInWithPwd()│─────────→ Supabase Auth
│ → Returns: user id, email    │         Validates credentials
└──────────────────────────────┘
     │
     ▼
┌──────────────────┐
│ Check admin?     │
│ isAdmin(email)   │─────────→ Check if email in admin list
└────┬─────────────┘
     │
     ├─ YES → Admin Dashboard
     │
     └─ NO → Student Dashboard
```

---

## Application Submission Flow

```
┌──────────────────────┐
│ Submit Application   │
│ Screen               │
└──────┬───────────────┘
       │ User selects: module1, module2
       │
       ▼
┌──────────────────────────┐
│ ApplicationViewModel     │
│ .submitApplication()     │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│ ApplicationService.submitApplication │
│                                      │
│ INSERT into applications:            │─────────→ Supabase
│  • id: gen_random_uuid()             │
│  • student_id: current_user_id       │        INSERT
│  • student_name: from auth           │        ↓
│  • module1: selected                 │   applications table
│  • module2: selected                 │        ↓
│  • status: 'pending'                 │   RLS check:
│  • created_at: now()                 │   auth.uid() = student_id
│  • updated_at: now()                 │        ↓
│                                      │   ✓ ALLOWED
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────┐
│ isSubmitted=true     │
│ Show success message │
└──────────────────────┘
```

---

## Admin Review Flow

```
ADMIN DASHBOARD:
┌─────────────────────────┐
│ Admin logs in           │
│ email: admin@...        │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────────────┐
│ ApplicationViewModel             │
│ .loadAllApplications()           │
└──────┬──────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│ ApplicationService.getAllApplications│
│                                      │
│ SELECT * FROM applications;          │─────────→ Supabase
│                                      │
│ RLS check:                           │        SELECT
│ → auth.jwt()->email IN               │        ↓
│   ('admin@...', 'lecturer@...')      │   applications table
│                                      │        ↓
│ ✓ ALLOWED (admin email matches)      │
│                                      │
│ Returns: List of all applications    │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────┐
│ Display all applications │
│ by status:               │
│ • Pending                │
│ • Approved               │
│ • Rejected               │
└──────────────────────────┘

---

APPROVE/REJECT APPLICATION:
┌──────────────────────────┐
│ Admin clicks "Approve"   │
│ or "Reject"              │
└──────┬───────────────────┘
       │
       ▼
┌────────────────────────────────────┐
│ ApplicationViewModel               │
│ .approveApplication(appId)         │
│ or                                 │
│ .rejectApplication(appId)          │
└────────┬─────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│ ApplicationService.updateStatus()  │
│                                    │
│ UPDATE applications               │─────────→ Supabase
│ SET status = 'approved'/'rejected'│
│ WHERE id = appId                  │        UPDATE
│                                    │        ↓
│ RLS check:                         │   applications table
│ → admin email in admin list        │        ↓
│                                    │   ✓ ALLOWED
└────────┬─────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│ Reload applications list           │
│ Application status now shows:       │
│ [APPROVED] or [REJECTED]          │
└────────────────────────────────────┘
```

---

## Row Level Security (RLS) in Action

```
STUDENT PERSPECTIVE:

Student 1 logs in as: student1@university.edu
┌────────────────────────────────────────┐
│ SELECT * FROM applications;            │
│ ↓                                      │
│ RLS Policy Check:                      │
│ "Students can view own apps"           │
│ → auth.uid() = student_id?             │
│                                        │
│ Database returns ONLY:                 │
│ - App A (created by student 1) ✓       │
│ - App B (created by student 1) ✓       │
│                                        │
│ BLOCKED:                               │
│ - App C (created by student 2) ✗       │
│ - App D (created by student 3) ✗       │
└────────────────────────────────────────┘

ADMIN PERSPECTIVE:

Admin logs in as: admin@university.edu
┌────────────────────────────────────────┐
│ SELECT * FROM applications;            │
│ ↓                                      │
│ RLS Policy Check:                      │
│ "Admins can view all apps"             │
│ → email in admin list?                 │
│ → YES ✓                                │
│                                        │
│ Database returns ALL:                  │
│ - App A (student 1) ✓                  │
│ - App B (student 1) ✓                  │
│ - App C (student 2) ✓                  │
│ - App D (student 3) ✓                  │
│ - (all applications visible)           │
└────────────────────────────────────────┘
```

---

## Database Operations Matrix

| Operation | Table | Who | RLS Policy | Status |
|-----------|-------|-----|-----------|--------|
| Create account | auth.users | Any user | (none) | ✓ |
| Create student profile | students | (auto via signUp) | `auth.uid() = id` | ✓ |
| View own profile | students | Student | `auth.uid() = id` | ✓ |
| View all profiles | students | Admin | Email in list | ✓ |
| Update own profile | students | Student | `auth.uid() = id` | ✓ |
| View own apps | applications | Student | `auth.uid() = student_id` | ✓ |
| Create app | applications | Student | `auth.uid() = student_id` | ✓ |
| Delete pending app | applications | Student | `auth.uid() = student_id AND status = 'pending'` | ✓ |
| View all apps | applications | Admin | Email in list | ✓ |
| Approve app | applications | Admin | Email in list | ✓ |
| Reject app | applications | Admin | Email in list | ✓ |
| Delete any app | applications | Admin | Email in list | ✓ |

---

## Error Handling Flow

```
┌──────────────────────────┐
│ User action              │
│ (Register/Login/Submit)  │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ Service call             │
│ (AuthService/AppService) │
└──────┬───────────────────┘
       │
       ├─────────────────────────────────┐
       │                                 │
       ▼                                 ▼
   SUCCESS                           ERROR
   ┌────────┐                   ┌──────────────┐
   │ Return │                   │ Catch error  │
   │ {      │                   │ Log it       │
   │success:│                   │ Return {     │
   │ true   │                   │  success:    │
   │}       │                   │  false,      │
   └────┬───┘                   │  error: msg  │
        │                       │ }            │
        │                       └──────┬───────┘
        │                              │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │ ViewModel                    │
        │ _errorMessage = msg          │
        │ isLoading = false            │
        │ notifyListeners()            │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │ UI Widget                    │
        │ Shows error message          │
        │ or success notification      │
        └──────────────────────────────┘
```

---

## Data Consistency Guarantees

```
✓ FOREIGN KEY INTEGRITY
  - application.student_id → students.id
  - Cannot create app with invalid student_id
  - Cannot delete student with active apps (prevented by CASCADE)

✓ UNIQUE CONSTRAINTS
  - students.student_number (no duplicates)
  - students.email (no duplicate emails)
  - Prevents registration with existing student number

✓ CHECK CONSTRAINTS
  - applications.status IN ('pending', 'approved', 'rejected')
  - Only valid statuses allowed
  - Database enforces at SQL level

✓ CASCADE DELETE
  - Delete from auth.users → students record deleted
  - Delete from students → applications records deleted
  - No orphaned data left behind

✓ TIMESTAMPS
  - created_at: Set once on insert, never changed
  - updated_at: Updated whenever record changes
  - Always in UTC with timezone
```

---

## Performance Considerations

```
INDEXES CREATED:
┌────────────────────────────┬──────────────┬─────────────────┐
│ Index Name                 │ Table        │ Column          │
├────────────────────────────┼──────────────┼─────────────────┤
│ idx_students_student_number│ students     │ student_number  │
│ idx_students_email         │ students     │ email           │
│ idx_applications_student_id│ applications │ student_id      │
│ idx_applications_status    │ applications │ status          │
│ idx_applications_created_at│ applications │ created_at DESC │
└────────────────────────────┴──────────────┴─────────────────┘

QUERY PERFORMANCE:
- Lookup student by number: O(log n) ✓ Fast
- Lookup student by email: O(log n) ✓ Fast
- Get apps for student: O(log n) ✓ Fast
- Filter apps by status: O(log n) ✓ Fast
- Sort apps by date: O(log n) ✓ Fast
- Get all apps: O(n) + RLS checks

OPTIMIZATION TIPS:
1. Always use WHERE to filter before sorting
2. Use indexes for frequent queries
3. Avoid SELECT * if possible (select specific columns)
4. Batch inserts when possible
```

---

## Monitoring Points

```
Supabase Dashboard Metrics:
┌───────────────────────────────────────────┐
│ Monitor these in Supabase Dashboard:       │
├───────────────────────────────────────────┤
│ 1. API Request Count                      │
│    → Spike indicates unusual activity      │
│                                           │
│ 2. Database Size                          │
│    → Growing with applications submitted  │
│                                           │
│ 3. Auth Success/Failure Rates             │
│    → Track login attempts                 │
│                                           │
│ 4. RLS Policy Violations                  │
│    → Check logs for security issues       │
│                                           │
│ 5. Error Rates                            │
│    → Monitor for data integrity issues    │
│                                           │
│ 6. Connection Pool Usage                  │
│    → Ensure not reaching limits           │
└───────────────────────────────────────────┘
```

---

**Architecture Version:** 1.0  
**Last Updated:** 2026-05-11  
**For:** Student Assistant App
