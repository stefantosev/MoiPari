import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/service/auth_service.dart';
import '../models/budget.dart';

class BudgetService {
  static const String baseUrl = "http://localhost:8080/api/budget";

  Future<List<Budget>> getBudgetByUserId() async{
    try{
      if(!AuthService.isLoggedIn){
        throw Exception("User not authenticated");
      }

      final userId = await AuthService.getUserId();

      if(userId == null) {
        throw Exception("User ID not found");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/user/$userId"),
        headers: AuthService.authHeaders,
      );

      if(response.statusCode == 200){
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => Budget.fromJson(item)).toList();
      }else if(response.statusCode == 401){
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception("Failed to load budgets (Status ${response.statusCode})");
      }
    }catch(e){
      debugPrint("Error fetching budget: $e");
      throw Exception("Failed to load budget: $e");
    }
  }

  Future <List<Budget>> getBudgetByUser(int userId) async {
   try{
     if(!AuthService.isLoggedIn){
       throw Exception("User not authenticated");
     }

     final response = await http.get(
       Uri.parse('$baseUrl/user/$userId'),
       headers: AuthService.authHeaders,
     );

     if(response.statusCode == 200){
       final List<dynamic> jsonList = jsonDecode(response.body);

       return jsonList
           .map((item) => Budget.fromJson(item))
           .toList();

     } else if (response.statusCode == 401){
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");

     } else {
       throw Exception("Failed to load budgets (Status ${response.statusCode})");
     }
   }catch(e){
     debugPrint("Error fetching budget: $e");
     throw Exception("Failed to load budget: $e");
   }
  }

  Future<Budget> createBudget(Budget budget) async {
    try{
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: AuthService.authHeaders,
        body: jsonEncode({
          "month": budget.month,
          "year": budget.year,
          "monthlyLimit": budget.monthlyLimit,
        }),
      );

      if(response.statusCode == 200){
        return Budget.fromJson(jsonDecode(response.body));
      }else if (response.statusCode == 401){
        await AuthService.logout();
        throw Exception("Session Expired. Please login again.");
      }else {
        throw Exception("Failed to create budgets (Status ${response.statusCode})");
      }
    }catch (e){
      debugPrint("Error creating budget: $e");
      throw Exception("Failed to create budget: $e");
    }
  }

  Future<Budget> updateBudget(Budget budget) async{
    try{
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.put(
        Uri.parse("$baseUrl/update/${budget.id}"),
        headers: AuthService.authHeaders,
        body: jsonEncode({
          "month": budget.month,
          "year": budget.year,
          "monthlyLimit": budget.monthlyLimit,
        }),
      );

      if(response.statusCode == 200){
        return Budget.fromJson(jsonDecode(response.body));
      }else if(response.statusCode == 401){
        await AuthService.logout();
        throw Exception("Session Expired. Please login again.");
      }else {
        throw Exception("Failed to update budgets (Status ${response.statusCode})");
      }
    }catch (e){
      debugPrint("Error updating budget: $e");
      throw Exception("Failed to update budget: $e");
    }
  }

  Future<void> deleteBudget(int budgetId) async {
    try{
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.delete(
        Uri.parse("$baseUrl/$budgetId"),
        headers: AuthService.authHeaders,
      );

      if(response.statusCode == 204){
        return;
      }else if (response.statusCode == 401){
        await AuthService.logout();
        throw Exception("Session Expired. Please login again.");
      }else {
        throw Exception("Failed to delete budget (Status ${response.statusCode})");
      }

    } catch (e) {
      debugPrint("Error creating budget: $e");
      throw Exception("Failed to create budget: $e");
    }
  }


  Future<double> convertCurrency(double amount, String fromCurrency, String toCurrency) async {
     try{
       final uri = Uri.parse("$baseUrl/convert-currency").replace(queryParameters: {
         "amount": amount.toString(),
         "fromCurrency": fromCurrency.toString(),
         "toCurrency": toCurrency.toString(),
       });

       final response = await http.get(uri);

       if(response.statusCode == 200){
         return (jsonDecode(response.body) as num).toDouble();
       }else{
         throw Exception("Failed to convert currency (Status ${response.statusCode})");
       }
     }catch (e){
       debugPrint("Error converting currency: $e");
       throw Exception("Failed to convert currency: $e");
     }
  }

  Future<bool> checkBudgetLimit(int userId, int month, int year) async {
    try{
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final uri = Uri.parse("$baseUrl/check-limit").replace(queryParameters: {
        "userId": userId.toString(),
        "month": month.toString(),
        "year": year.toString(),
      });

      final response = await http.get(uri, headers: AuthService.authHeaders);

      if(response.statusCode == 200){
        return jsonDecode(response.body) as bool;
      }else if(response.statusCode == 401){
        await AuthService.logout();
        throw Exception("Session Expired. Please login again.");
      }else {
        throw Exception("Failed to check budget limit (Status ${response.statusCode})");
      }

    }catch (e){
      debugPrint("Error checking budget limit: $e");
      throw Exception("Failed to check budget limit: $e");
    }
  }

  Future<double> getTotalBudget(int userId, int month, int year) async {
      try{
        if (!AuthService.isLoggedIn) {
          throw Exception("User not authenticated");
        }

        final uri = Uri.parse('$baseUrl/total-budget').replace(queryParameters: {
          'userId': userId.toString(),
          'month': month.toString(),
          'year': year.toString(),
        });

        final response = await http.get(uri, headers: AuthService.authHeaders);

        if(response.statusCode == 200) {
          return (jsonDecode(response.body) as num).toDouble();
        }else if(response.statusCode == 401) {
          await AuthService.logout();
          throw Exception("Session expired. Please login again.");
        }else{
          throw Exception("Failed to get total budget (Status ${response.statusCode})");
        }
      }catch(e){
        debugPrint("Error fetching total budget: $e");
        throw Exception("Failed to get total budget: $e");
      }
    }
}
