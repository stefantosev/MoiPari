import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/category.dart';

import 'auth_service.dart';

class CategoryService {
  static const String baseUrl = "http://10.0.2.2:8080/api/categories";

  Future<List<Category>> getCategories() async {
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

        List<Category> categories = jsonList
            .map((jsonItem) => Category.fromJson(jsonItem))
            .toList();

        return categories;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to load categories (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      throw Exception("Failed to load categories: $e");
    }
  }

  Future<Category> createCategory(String name, String icon, String color) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: AuthService.authHeaders,
        body: json.encode({
          'name': name,
          'icon': icon,
          'color': color,
        }),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return Category.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to create category (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error creating category: $e");
      throw Exception("Failed to create category: $e");
    }
  }

  Future<Category> updateCategory(int id, String name, String icon, String color) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: AuthService.authHeaders,
        body: json.encode({
          'name': name,
          'icon': icon,
          'color': color,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Category.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to update category (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error updating category: $e");
      throw Exception("Failed to update category: $e");
    }
  }

  Future<void> deleteCategory(int id) async {
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
          "Failed to delete category (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error deleting category: $e");
      throw Exception("Failed to delete category: $e");
    }
  }

  Future<Category> getCategoryById(int id) async {
    try {
      if (!AuthService.isLoggedIn) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Category.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception("Session expired. Please login again.");
      } else {
        throw Exception(
          "Failed to load category (Status code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching category: $e");
      throw Exception("Failed to load category: $e");
    }
  }
}