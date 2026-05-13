import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'ausweis_screen.dart';
import 'history_screen.dart';
import 'upcoming_screen.dart';

class BoxerShell extends StatefulWidget {
  const BoxerShell({super.key});

  @override
  State<BoxerShell> createState() => _BoxerShellState();
}

class _BoxerShellState extends State<BoxerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final boxer = auth.boxer!;

    final screens = [
      AusweisScreen(boxer: boxer),
      UpcomingScreen(boxer: boxer),
      HistoryScreen(boxer: boxer),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Ausweis',
          ),
          NavigationDestination(
            icon: Icon(Icons.upcoming_outlined),
            selectedIcon: Icon(Icons.upcoming),
            label: 'Nächster Kampf',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historie',
          ),
        ],
      ),
    );
  }
}
