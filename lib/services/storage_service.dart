import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class StorageService {
  static const String _vaultKey = 'flavor_vault_recipes';

  // Save a recipe to the vault (Local Storage)
  Future<void> saveRecipe(Recipe recipe) async {
    // Get the instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Fetch currently saved recipes first
    List<Recipe> currentVault = await getVaultRecipes();
    
    // Check if it already exists to prevent duplicates
    if (!currentVault.any((r) => r.id == recipe.id)) {
      currentVault.add(recipe);
      
      // We must encode our list of Recipe objects into a JSON string 
      // because SharedPreferences only supports basic data types (String, int, etc.)
      final String encodedData = json.encode(
        currentVault.map((r) => r.toJson()).toList(),
      );
      
      // Save the string to storage
      await prefs.setString(_vaultKey, encodedData);
    }
  }

  // Remove a recipe from the vault
  Future<void> removeRecipe(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<Recipe> currentVault = await getVaultRecipes();
    
    currentVault.removeWhere((recipe) => recipe.id == id);
    
    final String encodedData = json.encode(
      currentVault.map((r) => r.toJson()).toList(),
    );
    await prefs.setString(_vaultKey, encodedData);
  }

  // Get all saved recipes from local storage
  Future<List<Recipe>> getVaultRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Read the string from storage using our unique key
    final String? vaultString = prefs.getString(_vaultKey);
    
    // If we have saved data, decode the JSON string back into a List of Recipe objects
    if (vaultString != null) {
      final List<dynamic> decodedData = json.decode(vaultString);
      return decodedData.map((json) => Recipe.fromJson(json)).toList();
    }
    
    // Return empty list if nothing is saved yet
    return [];
  }
}
