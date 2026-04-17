import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Update this to your backend URL
  static const String baseUrl = 'http://192.168.100.5/remindly_api/api';

  // Register endpoint
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: {
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration error: ${e.toString()}',
      };
    }
  }

  // Login endpoint
  static Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {
          'username': username,
          'password': password,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Login error: ${e.toString()}',
      };
    }
  }

  // Check username availability
  static Future<Map<String, dynamic>> checkUsername(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check_username.php'),
        body: {'username': username},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Check failed: ${e.toString()}',
      };
    }
  }

  // Check email availability
  static Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check_email.php'),
        body: {'email': email},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Check failed: ${e.toString()}',
      };
    }
  }

  // Verify email endpoint
  static Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_email.php'),
        body: {'token': token},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Verification error: ${e.toString()}',
      };
    }
  }

  // Resend verification email
  static Future<Map<String, dynamic>> resendVerificationEmail({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend_verification.php'),
        body: {'email': email},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Resend error: ${e.toString()}',
      };
    }
  }
}