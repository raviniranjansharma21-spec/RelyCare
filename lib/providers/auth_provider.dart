import 'package:flutter/material.dart';

/// Available user roles for the RelyCare offline-first referral ecosystem.
enum UserRole {
  phcStaff('PHC Staff'),
  hospitalStaff('Hospital Staff'),
  patient('Patient');

  final String displayName;
  const UserRole(this.displayName);

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.displayName.toLowerCase() == role.toLowerCase() || r.name.toLowerCase() == role.toLowerCase(),
      orElse: () => UserRole.phcStaff,
    );
  }
}

/// Provider managing authentication state, role selection, and user credentials.
class AuthProvider extends ChangeNotifier {
  String _selectedRole = 'PHC Staff';
  String _emailOrPhone = '';
  String _password = '';
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Available roles for UI dropdowns
  final List<String> _availableRoles = const [
    'PHC Staff',
    'Hospital Staff',
    'Patient',
  ];

  // Getters
  String get selectedRole => _selectedRole;
  UserRole get currentRole => UserRole.fromString(_selectedRole);
  String get emailOrPhone => _emailOrPhone;
  String get password => _password;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  List<String> get availableRoles => _availableRoles;

  /// Updates the currently selected role from dropdown.
  void setSelectedRole(String role) {
    if (_availableRoles.contains(role) && _selectedRole != role) {
      _selectedRole = role;
      notifyListeners();
    }
  }

  /// Toggles the 'Remember Me' preference.
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// Sets credentials
  void setCredentials({required String emailOrPhone, required String password}) {
    _emailOrPhone = emailOrPhone;
    _password = password;
  }

  /// Performs simulated login and updates authentication status.
  Future<bool> login({String? emailOrPhone, String? password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (emailOrPhone != null) _emailOrPhone = emailOrPhone;
    if (password != null) _password = password;

    // Simulate authentication delay for offline/local verification
    await Future.delayed(const Duration(milliseconds: 600));

    _isLoading = false;
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  /// Logs out the active user and clears transient state.
  void logout() {
    _isAuthenticated = false;
    if (!_rememberMe) {
      _emailOrPhone = '';
      _password = '';
    }
    notifyListeners();
  }
}
