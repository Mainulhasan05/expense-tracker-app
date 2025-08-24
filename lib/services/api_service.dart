// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../constants.dart';

class ApiService {
  // Using baseUrl from constants.dart

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>?> getDashboardData([String? month]) async {
    try {
      final headers = await _getHeaders();

      // If month is provided, use it in the URL, otherwise use current month
      final selectedMonth = month ?? _getCurrentMonthString();
      final encodedMonth = Uri.encodeComponent(selectedMonth);

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/$encodedMonth'),
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

  // Helper method to get current month string in required format
  static String _getCurrentMonthString() {
    final now = DateTime.now();
    final months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month]} ${now.year}';
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
        Uri.parse('$baseUrl/transactions/add'),
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
        Uri.parse('$baseUrl/dashboard/monthly-trends'),
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

  static Future<Map<String, dynamic>?> getCategoryData([String? month]) async {
    try {
      final headers = await _getHeaders();

      // If month is provided, use it in the URL, otherwise use current month
      final selectedMonth = month ?? _getCurrentMonthString();
      final encodedMonth = Uri.encodeComponent(selectedMonth);

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/categories/$encodedMonth'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Category Data API Error: $e');
      return null;
    }
  }
}
