import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/category.dart';

class Services {
  String baseUrl = "http://localhost:8080/api/categories";

  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);

        List<Category> categories = jsonList
            .map((jsonItem) => Category.fromJson(jsonItem))
            .toList();

        return categories;
      } else {
        throw Exception(
          "Failed to load categories (Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      throw Exception("Failed to load categories: $e");

    }
  }
}
