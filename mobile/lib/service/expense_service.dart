import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/expense.dart';

class ExpenseService {
  String baseUrl = "http://localhost:8080/api/expenses";

  Future<List<Expense>> getExpenses() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

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
      final response = await http.get(Uri.parse("$baseUrl/category/$categoryId"));

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
}
