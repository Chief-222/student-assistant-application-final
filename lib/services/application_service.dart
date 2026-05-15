//Application Service
//Handles all application-related Supabase operations.
//No business logic - just database calls.

//Tyam M - 222056708
//Masita TM - 223043636
//Mabusela PA - 222021446
//Mkhonza ZZ - 223043927
//Matthews LKM - 222044118

//Admin login:
//admin@gmail.com
//Admin123!

import '../models/application.dart';
import 'supabase_service.dart';

class ApplicationService {
  final _client = SupabaseService.instance.client;   

  /// Submit a new module assistance application.
  Future<Map<String, dynamic>> submitApplication({
    required String studentId,
    required String studentName,
    required String module1,
    String? module2,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client.from('applications').insert({
        'student_id': studentId,
        'student_name': studentName,
        'module1': module1,
        'module2': module2,
        'status': 'pending',
        'created_at': now,
        'updated_at': now,
      }).select();

      return {
        'success': true,
        'data': response,
        'error': null,
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Get all applications for a specific student.
  Future<List<Application>> getStudentApplications(String studentId) async {
    try {
      final response = await _client
          .from('applications')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Application.fromMap(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all applications (for admin view).
  Future<List<Application>> getAllApplications() async {
    try {
      final response = await _client
          .from('applications')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Application.fromMap(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Update application status (approve/reject).
  Future<Map<String, dynamic>> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      await _client.from('applications').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', applicationId);

      return {
        'success': true,
        'error': null,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Delete an application.
  Future<Map<String, dynamic>> deleteApplication(String applicationId) async {
    try {
      await _client.from('applications').delete().eq('id', applicationId);

      
      return {
        'success': true,
        'error': null,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}


