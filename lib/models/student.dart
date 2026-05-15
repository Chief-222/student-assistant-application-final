//Student Model
//Represents a student user in the Student Assistant System.
//Contains core student information and provides mapping methods
// for Supabase database operations.

//Tyam M - 222056708
//Masita TM - 223043636
//Mabusela PA - 222021446
//Mkhonza ZZ - 223043927
//Matthews LKM - 222044118

//Admin login:
//admin@gmail.com
//Admin123!

class Student {
  final String id;
  final String fullName;
  final String studentNumber;
  final String email;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.fullName,
    required this.studentNumber,
    required this.email,
    required this.createdAt,
  });

  /// Creates a Student object from a Supabase query result map.
  /// Uses snake_case keys as they appear in the database.
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      studentNumber: map['student_number'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converts the Student object to a map for Supabase insert/update operations.
  /// Uses snake_case keys to match database column naming conventions.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'student_number': studentNumber,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
