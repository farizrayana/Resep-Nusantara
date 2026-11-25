import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/state_views.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = MealService();
  final _searchCtrl = TextEditingController();
  List<String> _categories = [];
  bool _loadingCategories = true;
  String _selected = 'Seafood';
  String? _activeQuery;
  late Future<List<Meal>> _meals;

  @override
  void initState() {
    super.initState();
    _meals = _service.fetchByCategory(_selected);
    _loadCategories();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final categories = await _service.fetchCategories();
      if (mounted) setState(() => _categories = categories);
    } catch (_) {
      // Kategori tetap opsional; daftar resep memiliki penanganan error sendiri.
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  void _selectCategory(String category) {
    FocusScope.of(context).unfocus();
    _searchCtrl.clear();
    setState(() {
      _selected = category;
      _activeQuery = null;
      _meals = _service.fetchByCategory(category);
    });
  }

  void _search([String? value]) {
    final query = (value ?? _searchCtrl.text).trim();
    FocusScope.of(context).unfocus();
    if (query.isEmpty) {
      _selectCategory(_selected);
      return;
    }
    setState(() {
      _activeQuery = query;
      _meals = _service.search(query);
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _meals = _activeQuery == null
          ? _service.fetchByCategory(_selected)
          : _service.search(_activeQuery!);
    });
    try { await _meals; } catch (_) { /* Ditampilkan oleh FutureBuilder. */ }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7EFE7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.restaurant_menu_rounded,
                              color: Color(0xFF315C45)),
                        ),
                        const SizedBox(width: 11),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('RESEP NUSANTARA', style: theme.textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.2, fontWeight: FontWeight.w800,
                            color: const Color(0xFF315C45))),
                          Text('Inspirasi masak setiap hari', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                        ]),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF315C45), Color(0xFF527A5D)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Halo, pencinta kuliner! 👋',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text('Temukan resep lezat dan buat momen makan lebih istimewa.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(.88), height: 1.4)),
                          ],
                        )),
                        const SizedBox(width: 8),
                        const Icon(Icons.soup_kitchen_rounded, size: 58, color: Color(0xFFFFD59B)),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Expanded(child: TextField(
                        controller: _searchCtrl,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _search,
                        decoration: InputDecoration(
                          hintText: 'Cari nama resep...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchCtrl.text.isEmpty ? null : IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: () { _searchCtrl.clear(); _selectCategory(_selected); },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      )),
                      const SizedBox(width: 9),
                      Material(
                        color: const Color(0xFFE99A4A),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _search,
                          child: const SizedBox(width: 52, height: 52,
                            child: Icon(Icons.search_rounded, color: Colors.white)),
                        ),
                      ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 23, 20, 10),
                    child: Row(children: [
                      Text('Kategori', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const Spacer(),
                      if (_activeQuery != null)
                        TextButton(onPressed: () => _selectCategory(_selected), child: const Text('Reset')),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 42,
                    child: _categories.isEmpty
                        ? Center(
                            child: _loadingCategories
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : TextButton.icon(
                                    onPressed: _loadCategories,
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: const Text('Muat ulang kategori'),
                                  ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final category = _categories[i];
                              final selected = _activeQuery == null && category == _selected;
                              return ChoiceChip(
                                label: Text(category), selected: selected,
                                showCheckmark: false,
                                labelStyle: TextStyle(fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : const Color(0xFF45564A)),
                                backgroundColor: Colors.white,
                                selectedColor: const Color(0xFF315C45),
                                side: BorderSide.none,
                                onSelected: (_) => _selectCategory(category),
                              );
                            },
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 23, 20, 12),
                    child: Row(children: [
                      Expanded(child: Text(_activeQuery == null ? 'Rekomendasi resep' : 'Hasil pencarian',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                      if (_activeQuery != null)
                        Text('"$_activeQuery"', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: FutureBuilder<List<Meal>>(
                      future: _meals,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const SizedBox(height: 220, child: LoadingView());
                        }
                        if (snap.hasError) {
                          return SizedBox(height: 260, child: ErrorView(
                            message: 'Periksa koneksi internet lalu coba kembali.',
                            onRetry: _refresh,
                          ));
                        }
                        final meals = snap.data ?? [];
                        if (meals.isEmpty) {
                          return const SizedBox(height: 250, child: EmptyView(
                            icon: Icons.search_off_rounded,
                            text: 'Resep tidak ditemukan. Coba kata kunci lain.',
                          ));
                        }
                        return LayoutBuilder(builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 650 ? 3 : 2;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: meals.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: .73,
                            ),
                            itemBuilder: (_, i) => MealCard(meal: meals[i]),
                          );
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
