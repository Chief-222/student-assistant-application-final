//Tyam M - 222056708
//Masita TM - 223043636
//Mabusela PA - 222021446
//Mkhonza ZZ - 223043927
//Matthews LKM - 222044118

//Admin login:
//admin@gmail.com
//Admin123!

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  String? _userId;
  String? _userEmail;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;

  /// Check if user is already logged in.
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_authService.isLoggedIn) {
        _userId = _authService.currentUserId;
        _userEmail = _authService.currentUserEmail;
        _isLoggedIn = true;

        if (_userEmail != null) {
          _isAdmin = await _authService.isAdmin(_userEmail!);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Register a new student.
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
      studentNumber: studentNumber,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _userId = result['userId'];
      _userEmail = email;
      _isLoggedIn = true;
      _isAdmin = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['error'] ?? 'Registration failed';
      notifyListeners();
      return false;
    }
  }

  /// Login existing user.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signIn(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _userId = result['userId'];
      _userEmail = email;
      _isLoggedIn = true;
      _isAdmin = await _authService.isAdmin(email);
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          result['error'] ?? 'Login failed. Check your credentials.';
      notifyListeners();
      return false;
    }
  }

  /// Logout user.
  Future<void> logout() async {
    await _authService.signOut();
    _isLoggedIn = false;
    _isAdmin = false;
    _userId = null;
    _userEmail = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
