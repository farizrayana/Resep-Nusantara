import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/favorite_store.dart';
import '../widgets/meal_card.dart';
import '../widgets/state_views.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 5),
          child: Text('Resep Favorit', style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800, color: const Color(0xFF26372B))),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text('Kumpulan menu yang ingin kamu masak nanti.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
        ),
        Expanded(
          child: ValueListenableBuilder<List<Meal>>(
            valueListenable: FavoriteStore.instance.favorites,
            builder: (_, list, __) {
              if (list.isEmpty) {
                return const EmptyView(
                  icon: Icons.favorite_border_rounded,
                  text: 'Belum ada resep favorit.\nTekan ikon hati pada resep yang kamu suka.',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 14,
                  crossAxisSpacing: 14, childAspectRatio: .73,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) => MealCard(meal: list[i]),
              );
            },
          ),
        ),
      ]),
    );
  }
}
