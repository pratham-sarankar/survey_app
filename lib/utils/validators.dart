import '../config/app_config.dart';

class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length != AppConfig.phoneNumberLength) {
      return 'Phone number must be ${AppConfig.phoneNumberLength} digits';
    }
    
    return null;
  }

  static String? validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Latitude is required';
    }
    
    try {
      final lat = double.parse(value);
      if (lat < -90 || lat > 90) {
        return 'Latitude must be between -90 and 90';
      }
    } catch (e) {
      return 'Invalid latitude format';
    }
    
    return null;
  }

  static String? validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Longitude is required';
    }
    
    try {
      final lng = double.parse(value);
      if (lng < -180 || lng > 180) {
        return 'Longitude must be between -180 and 180';
      }
    } catch (e) {
      return 'Invalid longitude format';
    }
    
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}