import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/favorite_store.dart';
import '../services/meal_service.dart';
import '../services/translation_service.dart';
import '../widgets/state_views.dart';

class DetailPage extends StatefulWidget {
  final Meal meal;
  const DetailPage({super.key, required this.meal});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Meal?> _detail;

  @override
  void initState() {
    super.initState();
    _detail = _load();
  }

  /// Ambil detail dari API, lalu terjemahkan ke Bahasa Indonesia.
  Future<Meal?> _load() async {
    final detail = await MealService().fetchDetail(widget.meal.id);
    if (detail == null) return null;
    return TranslationService.instance.translateMeal(detail);
  }

  void _reload() => setState(() => _detail = _load());

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 310,
          pinned: true,
          backgroundColor: const Color(0xFF315C45),
          foregroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ValueListenableBuilder<List<Meal>>(
                valueListenable: FavoriteStore.instance.favorites,
                builder: (_, __, ___) {
                  final isFav = FavoriteStore.instance.isFavorite(meal.id);
                  return IconButton.filledTonal(
                    tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(.92)),
                    onPressed: () => FavoriteStore.instance.toggle(meal),
                    icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? const Color(0xFFE45C5C) : const Color(0xFF315C45)),
                  );
                },
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 65, 18),
            title: Text(meal.name, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                color: Colors.white, shadows: [Shadow(blurRadius: 8, color: Colors.black87)])),
            background: Stack(fit: StackFit.expand, children: [
              Hero(tag: 'meal-${meal.id}', child: Image.network(meal.thumb,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFECEFE8),
                  child: const Icon(Icons.restaurant, size: 64, color: Colors.grey)))),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
                stops: [0.48, 1],
              ))),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: FutureBuilder<Meal?>(
            future: _detail,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(height: 360, child: LoadingView());
              }
              if (snap.hasError || snap.data == null) {
                return SizedBox(height: 360, child: ErrorView(
                  message: 'Detail resep tidak berhasil diambil. Periksa koneksi internet.',
                  onRetry: _reload,
                ));
              }
              final detail = snap.data!;
              final steps = (detail.instructions ?? '')
                  .split(RegExp(r'\r?\n+'))
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    if (detail.category != null && detail.category!.isNotEmpty)
                      _InfoPill(icon: Icons.restaurant_menu_rounded, text: detail.category!),
                    if (detail.area != null && detail.area!.isNotEmpty)
                      _InfoPill(icon: Icons.public_rounded, text: detail.area!),
                  ]),
                  const SizedBox(height: 26),
                  Row(children: [
                    const Icon(Icons.shopping_basket_outlined, color: Color(0xFF315C45)),
                    const SizedBox(width: 9),
                    Text('Bahan-bahan', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800, color: const Color(0xFF26372B))),
                    const Spacer(),
                    Text('${detail.ingredients.length} bahan',
                      style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ]),
                  const SizedBox(height: 12),
                  if (detail.ingredients.isEmpty)
                    const Text('Informasi bahan belum tersedia.', style: TextStyle(color: Colors.black54))
                  else
                    ...detail.ingredients.asMap().entries.map((entry) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(13)),
                      child: Row(children: [
                        const Icon(Icons.check_circle_outline_rounded,
                          size: 19, color: Color(0xFF66816D)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(entry.value,
                          style: const TextStyle(fontWeight: FontWeight.w500))),
                      ]),
                    )),
                  const SizedBox(height: 22),
                  Row(children: [
                    const Icon(Icons.menu_book_rounded, color: Color(0xFF315C45)),
                    const SizedBox(width: 9),
                    Text('Cara membuat', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800, color: const Color(0xFF26372B))),
                  ]),
                  const SizedBox(height: 12),
                  if (steps.isEmpty)
                    const Text('Langkah memasak belum tersedia.', style: TextStyle(color: Colors.black54))
                  else
                    ...steps.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 30, height: 30,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: Color(0xFFE7EFE7), shape: BoxShape.circle),
                          child: Text('${entry.key + 1}', style: const TextStyle(
                            color: Color(0xFF315C45), fontWeight: FontWeight.w800))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.value,
                          style: const TextStyle(height: 1.55, color: Color(0xFF39463C)))),
                      ]),
                    )),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFFE7EFE7),
      borderRadius: BorderRadius.circular(30)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: const Color(0xFF315C45)),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
        color: Color(0xFF315C45))),
    ]),
  );
}
