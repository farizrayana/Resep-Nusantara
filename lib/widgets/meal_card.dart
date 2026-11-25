import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../pages/detail_page.dart';
import '../services/favorite_store.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailPage(meal: meal))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: Stack(fit: StackFit.expand, children: [
                Hero(
                  tag: 'meal-${meal.id}',
                  child: Image.network(
                    meal.thumb, fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : Container(color: const Color(0xFFECEFE8),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFECEFE8),
                      child: const Icon(Icons.restaurant_rounded, size: 42, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 9, right: 9,
                  child: ValueListenableBuilder(
                    valueListenable: FavoriteStore.instance.favorites,
                    builder: (_, __, ___) {
                      final isFav = FavoriteStore.instance.isFavorite(meal.id);
                      return Material(
                        color: Colors.white.withOpacity(.94),
                        shape: const CircleBorder(),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                          onPressed: () => FavoriteStore.instance.toggle(meal),
                          icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? const Color(0xFFE45C5C) : const Color(0xFF315C45), size: 21),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (meal.category != null && meal.category!.isNotEmpty)
                      Text(meal.category!.toUpperCase(), maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, letterSpacing: .8,
                          color: Color(0xFF66816D), fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Expanded(child: Text(meal.name, maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.2,
                        fontWeight: FontWeight.w700, color: Color(0xFF26372B)))),
                    const Row(children: [
                      Icon(Icons.arrow_forward_rounded, size: 15, color: Color(0xFFE99A4A)),
                      SizedBox(width: 4),
                      Text('Lihat resep', style: TextStyle(fontSize: 10,
                        color: Color(0xFF66816D), fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
