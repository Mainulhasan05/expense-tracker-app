// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://api.codesharer.xyz/api';
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  static Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Dashboard API Error: $e');
      return null;
    }
  }
  
  static Future<List<dynamic>?> getCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Categories API Error: $e');
      return null;
    }
  }
  
  static Future<bool> addCategory(String name, String type) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
        body: jsonEncode({'name': name, 'type': type}),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Add Category API Error: $e');
      return false;
    }
  }
  
  static Future<bool> addTransaction({
    required String categoryId,
    required double amount,
    required String date,
    required String description,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: headers,
        body: jsonEncode({
          'categoryId': categoryId,
          'amount': amount,
          'date': date,
          'description': description,
        }),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Add Transaction API Error: $e');
      return false;
    }
  }
  
  static Future<List<dynamic>?> getMonthlyTrends() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/monthly-trends'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Monthly Trends API Error: $e');
      return null;
    }
  }
}
