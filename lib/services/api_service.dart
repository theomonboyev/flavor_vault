import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Fetch recipes by search query from TheMealDB API
  Future<List<Recipe>> fetchRecipes(String query) async {
    try {
      // Sending an HTTP GET request to the API
      final response = await http.get(Uri.parse('$_baseUrl/search.php?s=$query'));
      
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response body
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['meals'] != null) {
          // Map the JSON objects into our Dart 'Recipe' models
          return (data['meals'] as List)
              .map((json) => Recipe.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Fetch recipes by category
  Future<List<Recipe>> fetchByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/filter.php?c=$category'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['meals'] != null) {
          // Note: filter.php doesn't return full details (like instructions)
          // We map what we have, and we might need to fetch full details later if needed, 
          // or just show the basic info in the list.
          return (data['meals'] as List)
              .map((json) {
                // Ensure category is set since filter.php doesn't return it
                json['strCategory'] = category;
                return Recipe.fromJson(json);
              })
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load recipes by category');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Fetch random recipe
  Future<Recipe?> fetchRandomRecipe() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/random.php'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return Recipe.fromJson(data['meals'][0]);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
