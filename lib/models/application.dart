//Application Model
//Represents a student's module assistance application in the Student Assistant System.
//Students can request assistance for 1 or 2 modules, and applications go through
// a review process (pending → approved/rejected).

//Tyam M - 222056708
//Masita TM - 223043636
//Mabusela PA - 222021446
//Mkhonza ZZ - 223043927
//Matthews LKM - 222044118

//Admin login:
//admin@gmail.com
//Admin123!

import 'application_status.dart';

class Application {
  final String id;
  final String studentId;
  final String studentName;
  final String module1;
  final String? module2;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Application({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.module1,
    this.module2,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Helper getter that returns true if the application status is "pending".
  bool get isPending => status == 'pending';

  /// Helper getter that returns true if the application is approved.
  bool get isApproved => status == 'approved';

  /// Helper getter that returns true if the application is rejected.
  bool get isRejected => status == 'rejected';

  /// Returns the ApplicationStatus enum value.
  ApplicationStatus get applicationStatus =>
      ApplicationStatus.fromString(status);

  /// Creates an Application object from a Supabase query result map.
  /// Uses snake_case keys as they appear in the database.
  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      studentName: map['student_name'] as String,
      module1: map['module1'] as String,
      module2: map['module2'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Converts the Application object to a map for Supabase insert/update operations.
  /// Uses snake_case keys to match database column naming conventions.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'module1': module1,
      'module2': module2,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
