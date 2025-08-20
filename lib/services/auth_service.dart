// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  static const String baseUrl = 'https://api.codesharer.xyz/api';
  static const String accessTokenKey = 'access_token';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
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
  
  static Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.attemptLightweightAuthentication();
      if (googleUser == null) return false;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) return false;
      
      // Get device token for notifications
      final String? deviceToken = await FirebaseMessaging.instance.getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'deviceToken': deviceToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveAccessToken(data['accessToken']);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return false;
    }
  }
  
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await clearAccessToken();
  }
}