import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/DTO/expense_request.dart';
import 'package:mobile/models/expense.dart';
import 'package:mobile/service/api_service.dart';
import 'package:mobile/service/auth_service.dart';

class ExpenseService {
  static const String baseUrl = "/api/expenses";

  Future<List<Expense>> getExpenses() async {
    final response = await ApiService.get(baseUrl);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<List<Expense>> getExpensesByUserId(String userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/user/$userId"));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);

        List<Expense> expenses = jsonList
            .map((jsonItem) => Expense.fromJson(jsonItem))
            .toList();

        return expenses;
      } else {
        throw Exception(
          "Failed to load expenses by Category Id (Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Error fetching expenses by userId: $e");
      throw Exception("Failed to load expenses by userId: $e");
    }
  }

  Future<Expense> createExpense(ExpenseRequest expenseRequest) async {
    final response = await ApiService.post(baseUrl, expenseRequest.toJson());
    if (response.statusCode != 201) {
      throw Exception('Failed to create expense');
    }
    return Expense.fromJson(jsonDecode(response.body));
  }

  Future<Expense> updateExpense(int id, ExpenseRequest expenseRequest) async {
    final response = await ApiService.put(baseUrl, expenseRequest.toJson());
    if (response.statusCode != 201) {
      throw Exception('Failed to update expense');
    }
    return Expense.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteExpense(int id) async {
    await ApiService.delete('$baseUrl/${id.toString()}');
  }

  Future<List<Expense>> getExpensesByCategoryId(String categoryId) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/category/$categoryId"),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);

        List<Expense> expenses = jsonList
            .map((jsonItem) => Expense.fromJson(jsonItem))
            .toList();

        return expenses;
      } else {
        throw Exception(
          "Failed to load expenses by category (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching expenses by category: $e");
      throw Exception("Failed to load expenses by category: $e");
    }
  }

  Future<double> getTotalSpentBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/analytics/total-spent").replace(
          queryParameters: {
            'startDate': startDate.toIso8601String(),
            'endDate': endDate.toIso8601String(),
          },
        ),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return (data['totalSpent'] as num).toDouble();
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

  Future<Map<String, List<Expense>>> getExpensesByCategoryForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/filter/date-range").replace(
          queryParameters: {
            'startDate': startDate.toIso8601String(),
            'endDate': endDate.toIso8601String(),
          },
        ),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Expense> expenses = jsonList
            .map((jsonItem) => Expense.fromJson(jsonItem))
            .toList();

        Map<String, List<Expense>> categorizedExpenses = {};
        for (var expense in expenses) {
          String categoryKey = expense.categoryIds.isNotEmpty
              ? "Category ${expense.categoryIds.first}"
              : "Uncategorized";

          categorizedExpenses.putIfAbsent(categoryKey, () => []).add(expense);
        }

        return categorizedExpenses;
      } else {
        throw Exception(
          "Failed to get expenses by date range (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching expenses by date range: $e");
      throw Exception("Failed to load expenses by date range: $e");
    }
  }

  Future<Map<String, double>> getMonthlySpending(int year) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final Map<String, double> monthlyData = {};
      final List<Future<void>> futures = [];

      for (int month = 1; month <= 12; month++) {
        final startDate = DateTime(year, month, 1);
        final endDate = month < 12
            ? DateTime(year, month + 1, 1).subtract(const Duration(days: 1))
            : DateTime(year + 1, 1, 1).subtract(const Duration(days: 1));

        futures.add(
          getTotalSpentBetween(startDate, endDate)
              .then((total) {
                monthlyData[DateTime(year, month).toString()] = total;
              })
              .catchError((e) {
                monthlyData[DateTime(year, month).toString()] = 0.0;
              }),
        );
      }

      await Future.wait(futures);
      return monthlyData;
    } catch (e) {
      debugPrint("Error fetching monthly spending: $e");
      throw Exception("Failed to load monthly spending: $e");
    }
  }

  Future<Map<String, double>> getPaymentMethodBreakdown(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/filter/date-range").replace(
          queryParameters: {
            'startDate': startDate.toIso8601String(),
            'endDate': endDate.toIso8601String(),
          },
        ),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Expense> expenses = jsonList
            .map((jsonItem) => Expense.fromJson(jsonItem))
            .toList();

        Map<String, double> paymentMethodTotals = {};
        for (var expense in expenses) {
          String method = expense.paymentMethod ?? 'Unknown';
          paymentMethodTotals.update(
            method,
            (value) => value + expense.amount,
            ifAbsent: () => expense.amount,
          );
        }

        return paymentMethodTotals;
      } else {
        throw Exception(
          "Failed to get payment method breakdown (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching payment method breakdown: $e");
      throw Exception("Failed to load payment method breakdown: $e");
    }
  }

  Future<List<Expense>> getExpensesForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/filter/date-range").replace(
          queryParameters: {
            'startDate': startDate.toIso8601String(),
            'endDate': endDate.toIso8601String(),
          },
        ),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((jsonItem) => Expense.fromJson(jsonItem)).toList();
      } else {
        throw Exception(
          "Failed to get expenses by date range (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching expenses by date range: $e");
      throw Exception("Failed to load expenses by date range: $e");
    }
  }

  Future<List<Expense>> searchExpenses(String query) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/search").replace(queryParameters: {'query': query}),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((jsonItem) => Expense.fromJson(jsonItem)).toList();
      } else {
        throw Exception(
          "Failed to search expenses (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error searching expenses: $e");
      throw Exception("Failed to search expenses: $e");
    }
  }
}
