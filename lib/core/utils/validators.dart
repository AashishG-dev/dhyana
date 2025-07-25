// lib/core/utils/validators.dart
/// Provides utility functions for input validation, ensuring data integrity
/// for forms and user inputs across the Dhyana application.
class Validators {
  /// Validates an email address using a regular expression.
  /// Returns an error message string if the email is invalid, otherwise returns null.
  static String? isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email cannot be empty.';
    }
    // A common regex for email validation.
    // This regex is a good balance between strictness and practicality.
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null; // No error
  }

  /// Validates a password based on minimum length.
  /// Returns an error message string if the password is too short, otherwise returns null.
  static String? isValidPassword(String? password, {int minLength = 6}) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters long.';
    }
    return null; // No error
  }

  /// Checks if a string value is not empty.
  /// Returns an error message string if the value is empty, otherwise returns null.
  static String? isNotEmpty(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty.';
    }
    return null; // No error
  }

  /// Checks if two string values match (e.g., for password confirmation).
  /// Returns an error message string if values do not match, otherwise returns null.
  static String? isMatching(String? value1, String? value2,
      {String field1Name = 'Value', String field2Name = 'Confirmation'}) {
    if (value1 == null || value2 == null || value1 != value2) {
      return '$field1Name and $field2Name do not match.';
    }
    return null; // No error
  }

  /// Validates a name, ensuring it's not empty and optionally checking for minimum length.
  static String? isValidName(String? name, {int minLength = 2}) {
    if (name == null || name.trim().isEmpty) {
      return 'Name cannot be empty.';
    }
    if (name.trim().length < minLength) {
      return 'Name must be at least $minLength characters long.';
    }
    return null;
  }
}
