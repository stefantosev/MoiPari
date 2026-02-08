import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/service/auth_service.dart';

class ApiService {
  static Future<http.Response> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080$endpoint'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 403 || response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expired. Please login again.');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> post(String endpoint, dynamic data) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080$endpoint'),
        headers: AuthService.authHeaders,
        body: json.encode(data),
      );

      if (response.statusCode == 403 || response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expired. Please login again.');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> put(String endpoint, dynamic data) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080$endpoint'),
        headers: AuthService.authHeaders,
        body: json.encode(data),
      );

      if (response.statusCode == 403 || response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expired. Please login again.');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> delete(String endpoint) async {
  try {
    final response = await http.delete(
      Uri.parse('http://localhost:8080$endpoint'),
      headers: AuthService.authHeaders,
    );
    
    if (response.statusCode == 403 || response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired. Please login again.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Delete failed with status: ${response.statusCode}');
    }
    
    return response;
  } catch (e) {
    rethrow;
  }
}
}
