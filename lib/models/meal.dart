/// Model resep. Dipakai untuk data API sekaligus data Local Storage.
class Meal {
  final String id;
  final String name;
  final String thumb;
  final String? category;
  final String? area;
  final String? instructions;
  final List<String> ingredients;

  const Meal({
    required this.id,
    required this.name,
    required this.thumb,
    this.category,
    this.area,
    this.instructions,
    this.ingredients = const [],
  });

  Meal copyWith({String? instructions, List<String>? ingredients}) => Meal(
        id: id,
        name: name,
        thumb: thumb,
        category: category,
        area: area,
        instructions: instructions ?? this.instructions,
        ingredients: ingredients ?? this.ingredients,
      );

  /// Parse JSON dari TheMealDB (endpoint list maupun detail).
  factory Meal.fromApi(Map<String, dynamic> json) {
    final ingredients = <String>[];
    for (var i = 1; i <= 20; i++) {
      final ing = (json['strIngredient$i'] ?? '').toString().trim();
      final measure = (json['strMeasure$i'] ?? '').toString().trim();
      if (ing.isNotEmpty) {
        ingredients.add(measure.isEmpty ? ing : '$measure $ing');
      }
    }
    return Meal(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumb: json['strMealThumb'] as String,
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      ingredients: ingredients,
    );
  }

  /// Format penyimpanan lokal (SharedPreferences).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'thumb': thumb,
        'category': category,
        'area': area,
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'] as String,
        name: json['name'] as String,
        thumb: json['thumb'] as String,
        category: json['category'] as String?,
        area: json['area'] as String?,
      );
}
