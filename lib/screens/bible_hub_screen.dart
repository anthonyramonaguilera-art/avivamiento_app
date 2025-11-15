// lib/screens/bible_hub_screen.dart
import 'package:flutter/material.dart';
import 'bible_search_screen.dart';
import 'bible_books_screen.dart';

class BibleHubScreen extends StatelessWidget {
  const BibleHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Santa Biblia (RVR09)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: 'Navegar'),
              Tab(icon: Icon(Icons.search), text: 'Buscar'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Pestaña 1: La nueva lista de libros
            BibleBooksScreen(),

            // Pestaña 2: Tu pantalla de búsqueda reutilizada
            BibleSearchScreen(),
          ],
        ),
      ),
    );
  }
}
