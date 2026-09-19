/// Form validation utilities for RelayCare inputs.
class Validators {
  /// Validates required text fields (e.g., patient name, village name).
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates patient age.
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value.trim());
    if (age == null || age < 0 || age > 130) {
      return 'Please enter a valid age (0-130)';
    }
    return null;
  }

  /// Validates phone number if provided.
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional in some low-resource setups
    }
    final cleanPhone = value.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length < 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  // TODO: Add any specific medical registration / ASHA worker ID format validators.
}
