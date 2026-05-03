import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'dart:io';
import 'package:share_plus/share_plus.dart';

import '../models/recipe.dart';
import '../providers/vault_provider.dart';
import 'add_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VaultProvider>(
      builder: (context, vault, child) {
        // Watch for updates to this specific recipe in the vault
        final currentRecipe = vault.savedRecipes.firstWhere(
          (r) => r.id == recipe.id,
          orElse: () => recipe,
        );

        return Scaffold(
          // CustomScrollView allows us to create advanced scrolling effects 
          // like the collapsing app bar (SliverAppBar).
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true, // keeps the app bar visible when scrolling down
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero widget creates a seamless transition animation between screens 
                      // using the unique recipe ID as the tag
                      Hero(
                        tag: 'recipe_img_${currentRecipe.id}',
                        child: currentRecipe.imageUrl.isNotEmpty
                            ? (currentRecipe.imageUrl.startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: currentRecipe.imageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => _buildPlaceholder(),
                                  )
                                : Image.file(
                                    File(currentRecipe.imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                  ))
                            : _buildPlaceholder(),
                      ),
                      // Dark gradient overlay at the top to make icons readable
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 120,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      Share.share(
                        'Check out this recipe: ${currentRecipe.name}\n\nCategory: ${currentRecipe.category}\n\nInstructions:\n${currentRecipe.instructions}',
                      );
                    },
                  ),
                  if (currentRecipe.isCustom)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddRecipeScreen(editRecipe: currentRecipe),
                          ),
                        );
                      },
                    )
                  else
                    Consumer<VaultProvider>(
                      builder: (context, vaultProvider, child) {
                        final isSaved = vaultProvider.isSaved(currentRecipe.id);
                        return IconButton(
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.red : Colors.white,
                          ),
                          onPressed: () {
                            if (isSaved) {
                              vaultProvider.removeRecipe(currentRecipe.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Removed from Vault')),
                              );
                            } else {
                              vaultProvider.addRecipe(currentRecipe);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saved to Vault')),
                              );
                            }
                          },
                        );
                      },
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentRecipe.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(currentRecipe.category),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(currentRecipe.area),
                            backgroundColor: Colors.grey[200],
                          ),
                          if (currentRecipe.isCustom) ...[
                            const SizedBox(width: 8),
                            const Chip(
                              label: Text('Custom'),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentRecipe.instructions,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.restaurant, size: 60, color: Colors.grey),
      ),
    );
  }
}
