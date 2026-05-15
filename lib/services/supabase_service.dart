//Supabase Service
//Initializes and provides Supabase client instance.
//This is the core service that all other services depend on.

//Tyam M - 222056708
//Masita TM - 223043636
//Mabusela PA - 222021446
//Mkhonza ZZ - 223043927
//Matthews LKM - 222044118

//Admin login:
//admin@gmail.com
//Admin123!

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://yotmewbeyxizprlwyqtx.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_CvoyZGby7imryjDuoQ_BzA_Yy-iBU54';

  static SupabaseService? _instance;
  late final SupabaseClient client;

  SupabaseService._();

  

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase with URL and Anon Key.
  /// Call this in main() before runApp().
  static Future<void> initialize() async {
    try {
      // Check if placeholder values are still in place
      if (_supabaseUrl == 'YOUR_SUPABASE_URL' ||
          _supabaseAnonKey == 'YOUR_SUPABASE_ANON_KEY') {
        print('Warning: Supabase credentials not configured. Using mock mode.');
        // Initialize with empty values to prevent crashes
        await Supabase.initialize(
          url: 'https://placeholder.supabase.co',
          anonKey: 'placeholder-key',
        );
      } else {
        await Supabase.initialize(
          url: _supabaseUrl,
          anonKey: _supabaseAnonKey,
        );
      }
      instance.client = Supabase.instance.client;
    } catch (e) {
      print('Supabase initialization failed (app will run in mock mode): $e');
      // Don't rethrow - allow app to run without Supabase for local testing
    }
  }
  

  /// Get the current authenticated user's ID.
  String? get currentUserId => instance.client.auth.currentUser?.id;

  /// Get the current authenticated user's email.
  String? get currentUserEmail => instance.client.auth.currentUser?.email;
}


