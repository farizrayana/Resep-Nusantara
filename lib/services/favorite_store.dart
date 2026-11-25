import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';

/// Penyimpanan favorit di Local Storage (SharedPreferences).
/// Daftar resep disimpan sebagai list string JSON pada key [_key].
class FavoriteStore {
  FavoriteStore._();
  static final FavoriteStore instance = FavoriteStore._();

  static const _key = 'favorite_meals';

  /// Dipantau UI agar halaman Favorit & ikon hati ikut berubah otomatis.
  final ValueNotifier<List<Meal>> favorites = ValueNotifier([]);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    favorites.value = raw
        .map((s) => Meal.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  bool isFavorite(String id) => favorites.value.any((m) => m.id == id);

  Future<void> toggle(Meal meal) async {
    final list = List<Meal>.from(favorites.value);
    if (isFavorite(meal.id)) {
      list.removeWhere((m) => m.id == meal.id);
    } else {
      list.insert(0, meal);
    }
    favorites.value = list;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, list.map((m) => jsonEncode(m.toJson())).toList());
  }
}
