import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/auth_provider.dart';
import 'battles_screen.dart';
import 'club_edit_screen.dart';
import 'kader_screen.dart';
import 'registrations_screen.dart';

class ClubShell extends StatefulWidget {
  const ClubShell({super.key});

  @override
  State<ClubShell> createState() => _ClubShellState();
}

class _ClubShellState extends State<ClubShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final club = auth.club ?? {};
    final clubName = club['name']?.toString() ?? 'Verein';

    final screens = [
      KaderScreen(clubName: clubName),
      RegistrationsScreen(clubName: clubName),
      ClubBattlesScreen(clubName: clubName),
      _InfoScreen(club: club),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Kader',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Anmeldungen',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_mma_outlined),
            selectedIcon: Icon(Icons.sports_mma),
            label: 'Kämpfe',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Verein',
          ),
        ],
      ),
    );
  }
}

class _InfoScreen extends StatelessWidget {
  final Map<String, dynamic> club;
  const _InfoScreen({required this.club});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vereinsdaten'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Bearbeiten',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ClubEditScreen(club: club))),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: C.border, width: 0.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: C.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: C.red.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.groups, color: C.red),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(club['name']?.toString() ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Code: ${club['code'] ?? ''}',
                      style: const TextStyle(color: C.textMuted, fontSize: 12)),
                ])),
              ]),
              if (club['city']?.toString().isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Row(children: [
                  const Icon(Icons.location_on, size: 14, color: C.textMuted),
                  const SizedBox(width: 6),
                  Text(club['city'].toString(), style: const TextStyle(color: C.textMuted)),
                ]),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}
