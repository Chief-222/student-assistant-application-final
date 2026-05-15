//Student Assistant App - Main Entry Point
//MVVM Architecture with Provider State Management
//Backend: Supabase

//Tyam M - 222056708
//Masita TM - 223043636
//Mabusela PA - 222021446
//Mkhonza ZZ - 223043927
//Matthews LKM - 222044118

//Admin login:
//admin@gmail.com
//Admin123!

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/student/student_dashboard.dart';
import 'views/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.initialize();
  } catch (e) {
    print('Supabase init skipped for local testing: $e');
  }
  runApp(const StudentAssistantApp());
}

class StudentAssistantApp extends StatelessWidget {
  const StudentAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
      ],
      child: MaterialApp(
        title: 'Student Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const AuthGate(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/student-dashboard': (context) => const StudentDashboard(),
          '/admin-dashboard': (context) => const AdminDashboard(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        if (authVM.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (authVM.isLoggedIn) {
          if (authVM.isAdmin) {
            return const AdminDashboard();
          }
          return const StudentDashboard();
        }
        return const LoginScreen();
      },
    );
  }
}
