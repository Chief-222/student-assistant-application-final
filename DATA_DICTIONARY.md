# Supabase Data Dictionary

Complete reference for all tables, columns, and relationships in the Student Assistant database.

## Overview

```
┌─────────────────────────────────────────────────────────┐
│                  auth.users (Supabase Auth)             │
│  Managed by Supabase - stores email, password, etc.     │
│  id (UUID) ← primary key for student identity           │
└──────────────────────┬──────────────────────────────────┘
                       │
                       │ REFERENCES (Foreign Key)
                       │
┌──────────────────────▼──────────────────────────────────┐
│                  PUBLIC.STUDENTS                        │
│  Student profiles linked to auth accounts               │
│  id (UUID) → auth.users(id)                             │
└──────────────────────┬──────────────────────────────────┘
                       │
                       │ REFERENCES (Foreign Key)
                       │
┌──────────────────────▼──────────────────────────────────┐
│                 PUBLIC.APPLICATIONS                     │
│  Module assistance applications from students           │
│  student_id (UUID) → students(id)                       │
└─────────────────────────────────────────────────────────┘
```

---

## Table 1: `students`

**Purpose:** Store student profiles linked to Supabase Authentication

**Relationship:** 1 student = 1 auth.users account = 0..* applications

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, REFERENCES auth.users(id) | Unique identifier, linked to Supabase Auth user |
| `full_name` | VARCHAR(255) | NOT NULL | Student's full name |
| `student_number` | VARCHAR(50) | NOT NULL, UNIQUE | Unique student ID number |
| `email` | VARCHAR(255) | NOT NULL, UNIQUE | Student's email address |
| `created_at` | TIMESTAMP | DEFAULT now() | Auto-set when profile created |
| `updated_at` | TIMESTAMP | DEFAULT now() | Auto-updated on any change |

**Indexes:**
- `idx_students_student_number` - Fast lookup by student number
- `idx_students_email` - Fast lookup by email

**Example Row:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "full_name": "John Doe",
  "student_number": "STU001",
  "email": "john@university.edu",
  "created_at": "2026-05-11T10:30:00Z",
  "updated_at": "2026-05-11T10:30:00Z"
}
```

**Key Operations:**

| Operation | By | RLS Policy |
|-----------|----|----|
| SELECT own profile | Student | `auth.uid() = id` |
| UPDATE own profile | Student | `auth.uid() = id` |
| INSERT own profile | Student (during signup) | `auth.uid() = id` |
| SELECT all profiles | Admin | Email in admin list |

**Created By:**
- AuthService.signUp() - inserts new student profile when user registers

**Cascade Behavior:**
- If user deleted from auth.users → student record auto-deleted → all applications deleted

---

## Table 2: `applications`

**Purpose:** Store module assistance applications submitted by students

**Relationship:** 1 application = 1 student = 0..1 approval/rejection

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique application identifier |
| `student_id` | UUID | NOT NULL, REFERENCES students(id) | Foreign key to student who submitted |
| `student_name` | VARCHAR(255) | NOT NULL | Denormalized student name (for easy display) |
| `module1` | VARCHAR(255) | NOT NULL | First module requiring assistance (required) |
| `module2` | VARCHAR(255) | NULLABLE | Second module requiring assistance (optional) |
| `status` | VARCHAR(50) | DEFAULT 'pending', CHECK (pending\|approved\|rejected) | Application review status |
| `created_at` | TIMESTAMP | DEFAULT now() | When application was submitted |
| `updated_at` | TIMESTAMP | DEFAULT now() | When application was last updated |

**Indexes:**
- `idx_applications_student_id` - Fast lookup by student
- `idx_applications_status` - Fast filtering by status
- `idx_applications_created_at` - Fast sorting by date

**Example Rows:**

```json
[
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "student_id": "550e8400-e29b-41d4-a716-446655440000",
    "student_name": "John Doe",
    "module1": "CS101 - Introduction to Programming",
    "module2": "CS102 - Data Structures",
    "status": "pending",
    "created_at": "2026-05-11T11:00:00Z",
    "updated_at": "2026-05-11T11:00:00Z"
  },
  {
    "id": "660e8400-e29b-41d4-a716-446655440002",
    "student_id": "550e8400-e29b-41d4-a716-446655440000",
    "student_name": "John Doe",
    "module1": "MATH201 - Calculus II",
    "module2": null,
    "status": "approved",
    "created_at": "2026-05-10T14:30:00Z",
    "updated_at": "2026-05-10T15:45:00Z"
  }
]
```

**Key Operations:**

| Operation | By | RLS Policy |
|-----------|----|----|
| SELECT own apps | Student | `auth.uid() = student_id` |
| INSERT application | Student | `auth.uid() = student_id` |
| DELETE pending app | Student | `auth.uid() = student_id AND status = 'pending'` |
| SELECT all apps | Admin | Email in admin list |
| UPDATE status | Admin | Email in admin list |
| DELETE any app | Admin | Email in admin list |

**Created By:**
- ApplicationService.submitApplication() - inserts new application

**Updated By:**
- ApplicationService.updateApplicationStatus() - changes status to 'approved' or 'rejected'

**Deleted By:**
- ApplicationService.deleteApplication() - removes application
- Cascade: When student deleted → all their applications deleted

---

## Field Data Types Explained

| Type | Example | Notes |
|------|---------|-------|
| UUID | `550e8400-e29b-41d4-a716-446655440000` | 36-char unique ID |
| VARCHAR(n) | `"John Doe"` | String up to n characters |
| TIMESTAMP | `2026-05-11T10:30:00Z` | ISO 8601 format with timezone |
| CHECK constraint | `status IN ('pending', 'approved', 'rejected')` | Only these 3 values allowed |

---

## Status Lifecycle

```
┌─────────┐
│ pending │  ← Initial status when application created
└────┬────┘
     │
     ├──────────────────────────────┐
     │                              │
     ▼                              ▼
┌─────────────┐            ┌──────────────┐
│  approved   │            │  rejected    │
└─────────────┘            └──────────────┘

Rules:
- Only admins can change status
- Students cannot change status
- Status = pending allows students to delete
- Status = approved/rejected is final (cannot delete)
```

---

## Query Examples

### Get a student's profile
```sql
SELECT * FROM students WHERE id = '550e8400-e29b-41d4-a716-446655440000';
```

### Get all applications for a student
```sql
SELECT * FROM applications 
WHERE student_id = '550e8400-e29b-41d4-a716-446655440000'
ORDER BY created_at DESC;
```

### Get all pending applications (admin view)
```sql
SELECT * FROM applications 
WHERE status = 'pending'
ORDER BY created_at DESC;
```

### Count applications by status
```sql
SELECT status, COUNT(*) as count FROM applications GROUP BY status;
```

### Get applications for a specific module
```sql
SELECT * FROM applications 
WHERE module1 = 'CS101' OR module2 = 'CS101'
ORDER BY created_at DESC;
```

### Get all applications from the last 7 days
```sql
SELECT * FROM applications 
WHERE created_at >= now() - interval '7 days'
ORDER BY created_at DESC;
```

---

## Important Notes

### Data Integrity
- ✅ Foreign keys enforce referential integrity
- ✅ CHECK constraints prevent invalid status values
- ✅ UNIQUE constraints prevent duplicate emails/student numbers
- ✅ Cascade delete ensures no orphaned records

### Security
- 🔒 RLS policies control data access
- 🔒 Password never stored in students table (Supabase Auth handles it)
- 🔒 Admin status checked via JWT token email claim
- 🔒 Students cannot see other students' data

### Performance
- ⚡ Indexes optimize common queries
- ⚡ student_id lookup: O(log n) via index
- ⚡ status filtering: O(log n) via index
- ⚡ created_at sorting: O(log n) via index

### Timestamps
- All timestamps in UTC with timezone
- Stored as ISO 8601 strings
- Automatically set on insert
- Manually updated on application status change

---

## Denormalization Note

The `student_name` column in `applications` table is denormalized (duplicated from `students` table).

**Why?**
- Faster queries (no JOIN needed)
- Historical record (name preserved even if student updates profile)
- Simplified application display in UI

**Tradeoff:**
- Must update in both places if student changes name
- Current code doesn't handle this - acceptable for MVP

---

## Related Code Files

| Component | File | Uses |
|-----------|------|------|
| Model | `lib/models/student.dart` | Student table schema |
| Model | `lib/models/application.dart` | Application table schema |
| Service | `lib/services/auth_service.dart` | students table operations |
| Service | `lib/services/application_service.dart` | applications table operations |
| ViewModel | `lib/viewmodels/auth_viewmodel.dart` | Student authentication |
| ViewModel | `lib/viewmodels/application_viewmodel.dart` | Application management |

---

**Last Updated:** 2026-05-11  
**Dart Model Mapping:** Snake_case in DB ↔ camelCase in Dart
