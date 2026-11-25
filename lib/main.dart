import 'package:flutter/material.dart';

import 'pages/favorites_page.dart';
import 'pages/home_page.dart';
import 'services/favorite_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoriteStore.instance.load();
  runApp(const ResepApp());
}

class ResepApp extends StatelessWidget {
  const ResepApp({super.key});

  @override
  Widget build(BuildContext context) {
    const forest = Color(0xFF315C45);
    const cream = Color(0xFFFAF8F1);
    return MaterialApp(
      title: 'Resep Nusantara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: forest,
          primary: forest,
          secondary: const Color(0xFFE99A4A),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: Color(0xFF24372B),
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: forest.withOpacity(.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700 : FontWeight.w500,
          )),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomePage(), FavoritesPage()],
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorit',
          ),
        ],
      ),
    );
  }
}
