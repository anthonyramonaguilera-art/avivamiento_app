// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/screens/profile/profile_screen.dart';
import 'package:avivamiento_app/screens/feed/feed_screen.dart';
import 'package:avivamiento_app/screens/calendar/calendar_screen.dart';
import 'package:avivamiento_app/screens/donations/donations_screen.dart';
import 'package:avivamiento_app/screens/radio/radio_screen.dart';
import 'package:avivamiento_app/screens/livestreams/livestreams_screen.dart';
import 'package:avivamiento_app/screens/conferences/conferences_screen.dart'; // [NUEVO]

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // [CAMBIO] Añadimos la ConferencesScreen a la lista
  static const List<Widget> _widgetOptions = <Widget>[
    FeedScreen(),
    CalendarScreen(),
    LivestreamsScreen(),
    ConferencesScreen(), // [NUEVO]
    RadioScreen(),
    // Hemos movido Donaciones al menú de perfil para hacer espacio
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
            // [NUEVO]
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
