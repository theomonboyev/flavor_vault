import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

// RecipeProvider manages the state of the API data.
// By extending ChangeNotifier, we can alert the UI when our data changes.
class RecipeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Private state variables
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Public getters to allow UI to read state safely without modifying it directly
  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Initialize with some default data
  Future<void> fetchDefaultRecipes() async {
    await searchRecipes('chicken'); // Load chicken recipes by default
  }

  Future<void> searchRecipes(String query) async {
    // Before fetching, set loading to true and notify the UI to show a spinner
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _recipes = await _apiService.fetchRecipes(query);
      if (_recipes.isEmpty) {
        _errorMessage = 'No recipes found for "$query".';
      }
    } catch (e) {
      _errorMessage = 'Error fetching recipes. Please check your connection.';
    } finally {
      // Regardless of success or failure, we stop loading and notify the UI again
      _isLoading = false;
      notifyListeners();
    }
  }
}
