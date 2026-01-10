import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/DTO/expense_request.dart';
import 'package:mobile/models/expense.dart';
import 'package:mobile/service/auth_service.dart';

class ExpenseService {
  String baseUrl = "http://10.0.2.2:8080/api/expenses";

  Future<List<Expense>> getExpenses() async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }
      final response = await http.get(
        Uri.parse(baseUrl),
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
          "Failed to load expenses (Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Error fetching expenses: $e");
      throw Exception("Failed to load expenses: $e");
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
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          ...AuthService.authHeaders,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(expenseRequest.toJson()),
      );

      if (response.statusCode == 201) {
        return Expense.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Failed to create expense (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error creating expense: $e");
      throw Exception("Failed to create expense: $e");
    }
  }

  Future<Expense> updateExpense(int id, ExpenseRequest expenseRequest) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {
          ...AuthService.authHeaders,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(expenseRequest.toJson()),
      );

      if (response.statusCode == 200) {
        return Expense.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Failed to update expense (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error updating expense: $e");
      throw Exception("Failed to update expense: $e");
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode != 204) {
        throw Exception(
          "Failed to delete expense (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error deleting expense: $e");
      throw Exception("Failed to delete expense: $e");
    }
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

  Future<double> getTotalSpentBetween(DateTime startDate, DateTime endDate) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/analytics/total-spent")
            .replace(queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
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
      DateTime startDate, DateTime endDate) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/filter/date-range")
            .replace(queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
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

      for (int month = 1; month <= 12; month++) {
        final startDate = DateTime(year, month, 1);
        final endDate = month < 12
            ? DateTime(year, month + 1, 1).subtract(const Duration(days: 1))
            : DateTime(year + 1, 1, 1).subtract(const Duration(days: 1));

        try {
          final total = await getTotalSpentBetween(startDate, endDate);
          monthlyData[DateTime(year, month).toString()] = total;
        } catch (e) {
          monthlyData[DateTime(year, month).toString()] = 0.0;
        }
      }

      return monthlyData;
    } catch (e) {
      debugPrint("Error fetching monthly spending: $e");
      throw Exception("Failed to load monthly spending: $e");
    }
  }

  Future<Map<String, double>> getPaymentMethodBreakdown(DateTime startDate, DateTime endDate) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/filter/date-range")
            .replace(queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
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

}
