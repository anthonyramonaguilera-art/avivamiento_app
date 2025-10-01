// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/screens/profile/profile_screen.dart';
import 'package:avivamiento_app/screens/feed/feed_screen.dart';
import 'package:avivamiento_app/screens/calendar/calendar_screen.dart';
import 'package:avivamiento_app/screens/donations/donations_screen.dart';
import 'package:avivamiento_app/screens/radio/radio_screen.dart'; // [NUEVO]

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // [CAMBIO] Añadimos la RadioScreen a la lista
  static const List<Widget> _widgetOptions = <Widget>[
    FeedScreen(),
    CalendarScreen(),
    DonationsScreen(),
    RadioScreen(), // [NUEVO]
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
        // [CAMBIO] Añadimos el nuevo item para la Radio
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.radio), label: 'Radio'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor:
            Colors.grey, // Importante para que se vean los items
        type: BottomNavigationBarType.fixed, // Importante para más de 3 items
        onTap: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
