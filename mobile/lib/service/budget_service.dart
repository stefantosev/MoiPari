import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/budget.dart';

class BudgetService {
  String baseUrl = "http://localhost:8080/api/budget/user/2";

  Future<List<Budget>> getBudgets() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if(response.statusCode == 200){
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Budget.fromJson(item)).toList();
      }
      else{
        throw Exception('Failed to load budgets: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching budget: $e");
      throw Exception("Failed to load budget $e");
    }
  }
}