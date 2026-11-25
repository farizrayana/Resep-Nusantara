import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal.dart';

/// Pengambilan data dari Public REST API TheMealDB.
class MealService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<Map<String, dynamic>> _get(String path) async {
    final res = await http
        .get(Uri.parse('$_base/$path'))
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw Exception('Server error (${res.statusCode})');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  List<Meal> _parseMeals(Map<String, dynamic> data) {
    final list = data['meals'];
    if (list == null) return [];
    return (list as List)
        .map((e) => Meal.fromApi(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchCategories() async {
    final data = await _get('list.php?c=list');
    return (data['meals'] as List)
        .map((e) => e['strCategory'] as String)
        .toList();
  }

  Future<List<Meal>> fetchByCategory(String category) async =>
      _parseMeals(await _get('filter.php?c=${Uri.encodeComponent(category)}'));

  Future<List<Meal>> search(String query) async =>
      _parseMeals(await _get('search.php?s=${Uri.encodeComponent(query)}'));

  Future<Meal?> fetchDetail(String id) async {
    final meals = _parseMeals(await _get('lookup.php?i=$id'));
    return meals.isEmpty ? null : meals.first;
  }
}
