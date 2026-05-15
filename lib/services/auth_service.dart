//Tyam M - 222056708
//Masita TM - 223043636
//Mabusela PA - 222021446
//Mkhonza ZZ - 223043927
//Matthews LKM - 222044118

//Admin login:
//admin@gmail.com
//Admin123!

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  late final SupabaseClient _client;

  AuthService() {
    try {
      _client = SupabaseService.instance.client;
    } catch (e) {
      print('Warning: AuthService - Supabase client not available: $e');
      rethrow;
    }
  }

  /// Sign up a new student user.
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      

      if (response.user != null) {
        // Insert student profile into students table
        await _client.from('students').insert({
          'id': response.user!.id,
          'full_name': fullName,
          'student_number': studentNumber,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return {
        'success': response.user != null,
        'userId': response.user?.id,
        'error': response.user == null ? 'Registration failed' : null,
      };
    } catch (e) {
      return {
        'success': false,
        'userId': null,
        'error': 'Registration failed: $e',
      };
    }
  }

  /// Sign in an existing user.
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,  
        password: password,
      );

      return {
        'success': response.user != null,
        'userId': response.user?.id,
        'email': response.user?.email,
        'error': null,
      };
    } catch (e) {
      return {
        'success': false,
        'userId': null,
        'email': null,
        'error': e.toString(),
      };
    }
  }

  

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get the current logged-in user's session.
  bool get isLoggedIn => _client.auth.currentUser != null;

  /// Get the current user's ID.
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Get the current user's email.
  String? get currentUserEmail => _client.auth.currentUser?.email;

  /// Get student profile data.
  Future<Map<String, dynamic>?> getStudentProfile(String userId) async {
    try {
      final response =
          await _client.from('students').select().eq('id', userId).single();

      return response;
    } catch (e) {
      print('Error getting student profile: $e');
      return null;
    }
  }
  

  /// Check if user is admin by checking against hardcoded admin emails.
  Future<bool> isAdmin(String email) async {
    try {
      // List of admin emails - must match RLS policies in database
      final adminEmails = [
        'admin@gmail.com',
        'lecturer@gmailcom',
      ];

      return adminEmails.contains(email.toLowerCase());
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}
