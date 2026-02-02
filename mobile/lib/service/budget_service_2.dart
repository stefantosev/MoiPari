import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/exceptions/budget_exceptions.dart';
import 'package:mobile/models/budget.dart';
import 'auth_service.dart';

class BudgetService {
  static const String baseUrl = "http://10.0.2.2:8080/api/budget";

  Future<Budget> getCurrentBudget() async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/current'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Budget.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else if (response.statusCode == 403) {
        throw NoBudgetSetExcpetion();
      } else {
        throw BudgetServiceException(
          "Failed to get current budget",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is NoBudgetSetExcpetion || e is BudgetServiceException) {
        rethrow;
      }
      throw BudgetServiceException('Failed to load current budget: $e');
    }
  }

  Future<Budget> getBudgetForMonth(int month, int year) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/month/$month/$year'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Budget.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to get budget for month (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching budget for month: $e");
      throw Exception("Failed to load budget for month: $e");
    }
  }

  Future<Budget> createOrUpdateBudget({
    required double amount,
    required int month,
    required int year,
    String? currency,
  }) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final Map<String, dynamic> body = {
        'monthlyLimit': amount,
        'month': month,
        'year': year,
      };

      if (currency != null) {
        body['currency'] = currency;
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: AuthService.authHeaders,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Budget.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to create/update budget (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error creating/updating budget: $e");
      throw Exception("Failed to create/update budget: $e");
    }
  }

  Future<Budget> updateBudget({
    required int id,
    required double amount,
    required int month,
    required int year,
    String? currency,
  }) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final Map<String, dynamic> body = {
        'monthlyLimit': amount,
        'month': month,
        'year': year,
      };

      if (currency != null) {
        body['currency'] = currency;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: AuthService.authHeaders,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Budget.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to update budget (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error updating budget: $e");
      throw Exception("Failed to update budget: $e");
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to delete budget (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error deleting budget: $e");
      throw Exception("Failed to delete budget: $e");
    }
  }

  Future<List<Budget>> getMyBudgets() async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/my-budgets'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Budget.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to get budgets (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching budgets: $e");
      throw Exception("Failed to load budgets: $e");
    }
  }

  Future<bool> checkOverBudget(int month, int year) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/check-over-budget/$month/$year'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['isOverBudget'] ?? false;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to check budget status (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error checking over budget: $e");
      throw Exception("Failed to check budget status: $e");
    }
  }

  Future<Map<String, dynamic>> getRemainingBudget(int month, int year) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/remaining/$month/$year'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to get remaining budget (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching remaining budget: $e");
      throw Exception("Failed to load remaining budget: $e");
    }
  }

  Future<List<Budget>> getBudgetHistory({int months = 6}) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/history?months=$months'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Budget.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to get budget history (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching budget history: $e");
      throw Exception("Failed to load budget history: $e");
    }
  }

  Future<double> getTotalSpent(int month, int year) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/total-spent/$month/$year'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['totalSpent']?.toDouble() ?? 0.0;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to get total spent (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching total spent: $e");
      throw Exception("Failed to load total spent: $e");
    }
  }

  Future<Map<String, dynamic>> getSuggestedBudget() async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/suggested'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to get suggested budget (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching suggested budget: $e");
      throw Exception("Failed to load suggested budget: $e");
    }
  }
}
