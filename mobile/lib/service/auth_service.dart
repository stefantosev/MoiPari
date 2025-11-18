import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://localhost:8080/api/users";
  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  static Future<Map<String, dynamic>> register(
      String email,
      String password,
      String name,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed');
    }
  }

  static Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey('token')) {
        _token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['userId'] ?? data['id'] ?? '');
        await prefs.setBool('isFirstLaunch', false);
        await prefs.setString('userEmail', data['email'] ?? '');

        return {
          'success': true,
          'token': data['token'],
          'userId': data['userId'] ?? data['id'],
          'email': data['email'],
        };
      } else {
        return {'success': false, 'error': data['error']};
      }
    } else {
      throw Exception("Login failed with status: ${response.statusCode}");
    }
  }

  static Map<String, String> get authHeaders {
    if (_token == null) {
      throw Exception('No token available. User not authenticated.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  static bool get isLoggedIn => _token != null;

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  static Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    _token = token;
    return token != null;
  }

  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
  }

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstLaunch') ?? true;
  }

  static String? get token => _token;
}