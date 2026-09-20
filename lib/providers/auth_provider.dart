import 'package:flutter/material.dart';

/// Supported User Roles in RelyCare.
enum UserRole {
  phcStaff('PHC Staff'),
  hospitalStaff('Hospital Staff'),
  patient('Patient');

  final String label;
  const UserRole(this.label);

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.label.toLowerCase() == role.toLowerCase(),
      orElse: () => UserRole.phcStaff,
    );
  }
}

/// Provider managing authentication state, role selection, and user credentials.
///
/// Passwords are NEVER stored in state. Only [emailOrPhone] is persisted when
/// "Remember Me" is enabled — password must be re-entered on every session.
class AuthProvider extends ChangeNotifier {
  String _selectedRole = 'PHC Staff';
  String _emailOrPhone = '';
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Available roles for the login dropdown
  final List<String> _availableRoles = [
    'PHC Staff',
    'Hospital Staff',
    'Patient',
  ];

  // Getters
  String get selectedRole => _selectedRole;
  UserRole get currentRole => UserRole.fromString(_selectedRole);
  String get emailOrPhone => _emailOrPhone;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  List<String> get availableRoles => List.unmodifiable(_availableRoles);

  /// Sets the selected role
  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  /// Sets the remember me preference
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// Performs simulated login and updates authentication status.
  /// [password] is used only for in-flight credential verification and is
  /// never retained in state.
  Future<bool> login({required String emailOrPhone, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Persist email/phone only when "Remember Me" is on — never persist password.
    if (_rememberMe) {
      _emailOrPhone = emailOrPhone;
    } else {
      _emailOrPhone = '';
    }

    // Simulate authentication delay for offline/local verification
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulated login success
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Logs out the active user and clears transient state.
  void logout() {
    _isAuthenticated = false;
    // emailOrPhone retained only when rememberMe was active (password never stored).
    if (!_rememberMe) {
      _emailOrPhone = '';
    }
    notifyListeners();
  }
}
