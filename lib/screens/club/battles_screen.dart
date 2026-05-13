import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/api_service.dart';

class ClubBattlesScreen extends StatefulWidget {
  final String clubName;
  const ClubBattlesScreen({super.key, required this.clubName});

  @override
  State<ClubBattlesScreen> createState() => _ClubBattlesScreenState();
}

class _ClubBattlesScreenState extends State<ClubBattlesScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _battles = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _battles = await _api.getClubBattles(); } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsere Kämpfe'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _battles.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.sports_mma, size: 56, color: C.textMuted),
                  const SizedBox(height: 12),
                  const Text('Keine Kämpfe', style: TextStyle(color: C.textMuted)),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _battles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _BattleCard(battle: _battles[i]),
                  ),
                ),
    );
  }
}

class _BattleCard extends StatelessWidget {
  final Map<String, dynamic> battle;
  const _BattleCard({required this.battle});

  @override
  Widget build(BuildContext context) {
    final status = battle['battle_status']?.toString() ?? '';
    final statusColor = switch (status) {
      'laufend'    => C.success,
      'beendet'    => C.blue,
      'abgebrochen'=> C.error,
      _            => C.textMuted,
    };

    // Unser Boxer ist entweder fighter1 oder fighter2
    final ourBoxer    = battle['our_boxer']?.toString() ??
                        battle['fighter1_name']?.toString() ?? '?';
    final opponent    = battle['opponent_name']?.toString() ??
                        battle['fighter2_name']?.toString() ?? '?';
    final myCorner    = battle['my_corner']?.toString() ?? 'red';
    final cornerColor = myCorner == 'red' ? C.red : C.blue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Status + Gewichtsklasse
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(_statusLabel(status),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(battle['weight_class']?.toString() ?? '',
                style: const TextStyle(color: C.textMuted, fontSize: 12))),
            if (battle['battle_order'] != null)
              Text('Kampf #${battle['battle_order']}',
                  style: const TextStyle(color: C.textMuted, fontSize: 11)),
          ]),
          const SizedBox(height: 12),

          // Kämpfer
          Row(children: [
            Container(
              width: 4, height: 48,
              decoration: BoxDecoration(
                  color: cornerColor, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ourBoxer,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cornerColor)),
              Text('vs. $opponent', style: const TextStyle(color: C.textMuted, fontSize: 13)),
            ])),
            // Ergebnis
            if (battle['outcome_title'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: C.surface2, borderRadius: BorderRadius.circular(8)),
                child: Text(battle['outcome_title'].toString(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
          ]),
        ]),
      ),
    );
  }

  String _statusLabel(String s) => switch (s) {
    'geplant'     => 'Geplant',
    'laufend'     => '● Läuft',
    'beendet'     => 'Beendet',
    'abgebrochen' => 'Abbruch',
    _             => s,
  };
}
