//Application Status Enum
//Defines the possible states of a module assistance application.
//Used to track and manage the application lifecycle in the Student Assistant System.

//Tyam M - 222056708
//Masita TM - 223043636
//Mabusela PA - 222021446
//Mkhonza ZZ - 223043927
//Matthews LKM - 222044118

//Admin login:
//admin@gmail.com
//Admin123!

enum ApplicationStatus {
  pending,
  approved,
  rejected;

  /// Converts the enum value to its string representation for database storage.
  String get value => name;

  /// Creates an ApplicationStatus from a string value from the database.
  static ApplicationStatus fromString(String status) {
    return ApplicationStatus.values.firstWhere(
      (element) => element.value == status,
      orElse: () => ApplicationStatus.pending,
    );
  }

  /// Returns a user-friendly display name.
  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending Review';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }
}
