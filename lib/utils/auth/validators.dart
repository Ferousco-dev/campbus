/// Validation utilities for auth form fields.
class AuthValidators {
  AuthValidators._();

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().split(RegExp(r'\s+')).length < 2) {
      return 'Name must include first and last name';
    }
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value.trim())) {
      return 'Name can only contain letters';
    }
    return null;
  }

  static String? matricNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Matric number is required';
    }
    if (!RegExp(r'^[A-Za-z0-9/\-]+$').hasMatch(value.trim())) {
      return 'Enter a valid matric number';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w\.\-\+]+@[\w\.\-]+\.\w{2,}$').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Enter a valid phone number (10-11 digits)';
    }
    return null;
  }

  static String? dateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Please select your date of birth';
    }
    final age = DateTime.now().difference(value).inDays ~/ 365;
    if (age < 16) {
      return 'You must be at least 16 years old';
    }
    return null;
  }

  static String? gender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  /// Returns true if a 6-digit code is considered weak (sequential/repeated).
  static bool isWeakCode(String code) {
    if (code.length != 6) return false;
    // All same digit
    if (RegExp(r'^(\d)\1{5}$').hasMatch(code)) return true;
    // Sequential ascending
    bool ascending = true;
    bool descending = true;
    for (int i = 1; i < code.length; i++) {
      if (int.parse(code[i]) != int.parse(code[i - 1]) + 1) ascending = false;
      if (int.parse(code[i]) != int.parse(code[i - 1]) - 1) descending = false;
    }
    return ascending || descending;
  }
}
