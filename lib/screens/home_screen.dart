// lib/screens/home_screen.dart

import 'package:avivamiento_app/screens/bible_hub_screen.dart';
import 'package:avivamiento_app/screens/donations/donations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/screens/profile/profile_screen.dart';
import 'package:avivamiento_app/screens/feed/feed_screen.dart';
import 'package:avivamiento_app/screens/calendar/calendar_screen.dart';
import 'package:avivamiento_app/screens/radio/radio_screen.dart';
import 'package:avivamiento_app/screens/livestreams/livestreams_screen.dart';
import 'package:avivamiento_app/screens/conferences/conferences_screen.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avivamiento'),
        // Removemos acciones redundantes o las hacemos más sutiles si es necesario
        // Por ahora las mantenemos pero con el estilo del tema
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded), // Iconos redondeados
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            tooltip: 'Donaciones',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const DonationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'La Biblia',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const BibleHubScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: selectedIndex, children: _widgetOptions),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library_rounded),
            label: 'Videos',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Reuniones',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_outlined),
            selectedIcon: Icon(Icons.radio_rounded),
            label: 'Radio',
          ),
        ],
      ),
    );
  }
}
