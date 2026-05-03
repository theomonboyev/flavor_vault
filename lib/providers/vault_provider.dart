import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/storage_service.dart';

// VaultProvider manages the state of our local recipes (favorites & custom recipes).
class VaultProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Recipe> _savedRecipes = [];

  List<Recipe> get savedRecipes => _savedRecipes;

  // Constructor automatically loads the vault data when the app starts
  VaultProvider() {
    loadVault();
  }

  Future<void> loadVault() async {
    _savedRecipes = await _storageService.getVaultRecipes();
    notifyListeners(); // Refresh UI after loading data from device
  }

  // Adds a recipe to storage, then reloads the state
  Future<void> addRecipe(Recipe recipe) async {
    await _storageService.saveRecipe(recipe);
    await loadVault();
  }

  Future<void> removeRecipe(String id) async {
    await _storageService.removeRecipe(id);
    await loadVault();
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    await _storageService.removeRecipe(updatedRecipe.id);
    await _storageService.saveRecipe(updatedRecipe);
    await loadVault();
  }

  bool isSaved(String id) {
    return _savedRecipes.any((recipe) => recipe.id == id);
  }
}
