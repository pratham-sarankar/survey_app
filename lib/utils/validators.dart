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

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }

    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length < 10) {
      return 'Mobile number must be at least 10 digits';
    }

    return null;
  }

  static String? validateLoginId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Login ID is required';
    }

    if (value.length < 4) {
      return 'Login ID must be at least 4 characters';
    }

    final loginIdRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!loginIdRegex.hasMatch(value)) {
      return 'Login ID can only contain letters, numbers, and underscores';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
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

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validatePropertyUid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Property UID is required';
    } else if (value.length < 3) {
      return 'Property UID must be at least 3 characters';
    }
    return null;
  }

  static String? validateQrId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'QR ID is required';
    }
    return null;
  }

  static String? validateWardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ward number is required';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }
}
