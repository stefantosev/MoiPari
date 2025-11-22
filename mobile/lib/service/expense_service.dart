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

  Future<List<Expense>> getExpensesByCategoryId(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/category/$categoryId"),
      );

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
      debugPrint("Error fetching expenses by Category Id: $e");
      throw Exception("Failed to load expenses by Category Id: $e");
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
}
