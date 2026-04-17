import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _nameKey = 'name';
  static const String _isLoggedInKey = 'is_logged_in';

  late SharedPreferences _prefs;
  
  String? get currentUserId => _prefs.getString(_userIdKey);
  String? get currentUsername => _prefs.getString(_usernameKey);
  String? get currentEmail => _prefs.getString(_emailKey);
  String? get currentName => _prefs.getString(_nameKey);
  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Sign Up
  Future<bool> signUpWithEmail({
    required String name,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiService.registerUser(
        name: name,
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (response['success'] == true) {
        // Store user data temporarily (not verified yet)
        await _prefs.setString(_userIdKey, response['data']['user_id'].toString());
        await _prefs.setString(_usernameKey, username);
        await _prefs.setString(_emailKey, email);
        await _prefs.setString(_nameKey, name);
        // Don't set isLoggedIn = true until email is verified
        return true;
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign In
  Future<bool> signInWithEmail({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiService.loginUser(
        username: username,
        password: password,
      );

      if (response['success'] == true) {
        final data = response['data'];
        
        // Store user data
        await _prefs.setString(_userIdKey, data['user_id'].toString());
        await _prefs.setString(_usernameKey, data['username']);
        await _prefs.setString(_emailKey, data['email']);
        await _prefs.setString(_nameKey, data['name']);
        await _prefs.setBool(_isLoggedInKey, true);
        
        return true;
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Check if user is logged in
  Future<bool> checkUserLoggedIn() async {
    return isLoggedIn;
  }

  // Sign Out
  Future<void> signOut() async {
    await _prefs.clear();
  }
}