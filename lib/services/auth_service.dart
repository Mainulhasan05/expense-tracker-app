// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  // Using baseUrl from constants.dart
  static const String accessTokenKey = 'access_token';

  static Map<String, dynamic>? _currentUser;
  static String _errorMessage = '';

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, token);
  }

  static Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
  }

  static Future<bool> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _errorMessage = '';

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null) {
          await saveAccessToken(data['accessToken']);
          _currentUser = {
            'name': data['user']['name'] ?? name,
            'email': data['user']['email'] ?? email,
            'id': data['user']['id'],
          };
          return true;
        } else {
          _errorMessage = 'No access token received';
          return false;
        }
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      return false;
    }
  }

  static Future<bool> signInWithEmail(String email, String password) async {
    try {
      _errorMessage = '';
      // store deice token in a variable
      final fcmToken = await getDeviceToken();

      // add device token to request body
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveAccessToken(data['token']);
          _currentUser = {
            'name': data['user']['name'] ?? 'User',
            'email': data['user']['email'] ?? email,
            'id': data['user']['_id'],
          };
          return true;
        } else {
          _errorMessage = 'No access token received';
          return false;
        }
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      print('Login API Error: $e');
      _errorMessage = 'Network error. Please check your connection.';
      return false;
    }
  }

  static Future<String?> getDeviceToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
    return token;
  }

  static Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = '';

      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Failed to send reset email';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      return false;
    }
  }

  static Future<void> signOut() async {
    _currentUser = null;
    _errorMessage = '';
    await clearAccessToken();
  }

  static Future<bool> isSignedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty && _currentUser != null;
  }

  static Map<String, dynamic>? getCurrentEmailUser() {
    return _currentUser;
  }

  static String getErrorMessage() {
    return _errorMessage;
  }

  static Future<bool> checkAuthenticationStatus() async {
    try {
      final token = await getAccessToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = data['user'];
        return true;
      } else {
        await clearAccessToken();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Map<String, String?> getUserProfile() {
    if (_currentUser != null) {
      return {
        'name': _currentUser!['name'],
        'email': _currentUser!['email'],
        'photoUrl': null,
      };
    } else {
      return {'name': null, 'email': null, 'photoUrl': null};
    }
  }
}
