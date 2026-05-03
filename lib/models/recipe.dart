class Recipe {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String imageUrl;
  final bool isCustom;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.imageUrl,
    this.isCustom = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json, {bool isCustom = false}) {
    return Recipe(
      id: json['idMeal'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['strMeal'] ?? json['name'] ?? 'Unknown Recipe',
      category: json['strCategory'] ?? json['category'] ?? 'Miscellaneous',
      area: json['strArea'] ?? json['area'] ?? 'Unknown',
      instructions: json['strInstructions'] ?? json['instructions'] ?? 'No instructions provided.',
      imageUrl: json['strMealThumb'] ?? json['imageUrl'] ?? '',
      isCustom: json['isCustom'] ?? isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'area': area,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'isCustom': isCustom,
    };
  }
}
