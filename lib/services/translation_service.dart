import 'package:translator/translator.dart';

import '../models/meal.dart';

/// Menerjemahkan isi resep (bahan & langkah) dari Inggris ke Indonesia.
/// Jika penerjemahan gagal, teks asli tetap ditampilkan.
class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  final _translator = GoogleTranslator();
  final Map<String, String> _cache = {};

  Future<String> _one(String text) async {
    final key = text.trim();
    if (key.isEmpty) return text;
    final cached = _cache[key];
    if (cached != null) return cached;
    try {
      final r = await _translator
          .translate(key, from: 'en', to: 'id')
          .timeout(const Duration(seconds: 10));
      _cache[key] = r.text;
      return r.text;
    } catch (_) {
      return text; // fallback: tampilkan teks asli
    }
  }

  Future<Meal> translateMeal(Meal meal) async {
    final steps = (meal.instructions ?? '')
        .split(RegExp(r'\r?\n+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final results = await Future.wait([
      Future.wait(meal.ingredients.map(_one)),
      Future.wait(steps.map(_one)),
    ]);

    return meal.copyWith(
      ingredients: results[0],
      instructions: results[1].join('\n'),
    );
  }
}
