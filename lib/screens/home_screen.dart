// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/screens/profile/profile_screen.dart';
import 'package:avivamiento_app/screens/feed/feed_screen.dart';
import 'package:avivamiento_app/screens/calendar/calendar_screen.dart';
import 'package:avivamiento_app/screens/donations/donations_screen.dart';
import 'package:avivamiento_app/screens/radio/radio_screen.dart';
import 'package:avivamiento_app/screens/livestreams/livestreams_screen.dart';
import 'package:avivamiento_app/screens/conferences/conferences_screen.dart';
import 'package:avivamiento_app/screens/bible_search_screen.dart'; 


final selectedIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _widgetOptions = <Widget>[
    FeedScreen(),
    CalendarScreen(),
    LivestreamsScreen(),
    ConferencesScreen(),
    RadioScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avivamiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.monetization_on_outlined),
            tooltip: 'Donaciones',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DonationsScreen()),
              );
            },
          ),
          
          // === INICIO DEL CAMBIO: ACCESO A LA BIBLIA ===
          IconButton(
            // El icono ya es un libro, lo mantendremos.
            icon: const Icon(Icons.menu_book, color: Color.fromARGB(255, 0, 47, 255)),
            // 1. Cambia el tooltip a "La Biblia"
            tooltip: 'La Biblia',
            onPressed: () {
              // 2. Navega a la nueva pantalla de búsqueda usando su ruta nombrada
              Navigator.of(context).pushNamed(BibleSearchScreen.routeName);
            },
          ),
          // === FIN DEL CAMBIO ===
        ],
      ),
      body: IndexedStack(index: selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Reuniones',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.radio), label: 'Radio'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}