import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../models/boxer.dart';
import '../../services/api_service.dart';

class UpcomingScreen extends StatefulWidget {
  final Boxer boxer;
  const UpcomingScreen({super.key, required this.boxer});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _upcoming = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _upcoming = await _api.getBoxerUpcoming(); } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nächste Kämpfe'),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _upcoming.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _upcoming.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _FightCard(fight: _upcoming[i]),
                  ),
                ),
    );
  }
}

class _FightCard extends StatelessWidget {
  final Map<String, dynamic> fight;
  const _FightCard({required this.fight});

  @override
  Widget build(BuildContext context) {
    final isRed = fight['my_corner']?.toString() == 'red';
    final cornerColor = isRed ? C.red : C.blue;
    final opponent = fight['opponent_name']?.toString() ?? '?';

    return Container(
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.border, width: 0.5),
        gradient: LinearGradient(
          colors: [cornerColor.withValues(alpha: 0.08), C.surface],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Turnier + Datum
        Row(children: [
          const Icon(Icons.emoji_events, size: 13, color: C.gold),
          const SizedBox(width: 6),
          Expanded(child: Text(fight['tournament_name']?.toString() ?? '',
              style: const TextStyle(color: C.textMuted, fontSize: 12))),
          Text(fight['event_date']?.toString() ?? '',
              style: const TextStyle(color: C.textMuted, fontSize: 11)),
        ]),
        const SizedBox(height: 14),

        // Kämpfer-Duell
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _Corner('Ich', isRed ? 'red' : 'blue'),
          Column(children: [
            const Text('VS', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: C.textMuted)),
            if (fight['weight_class'] != null)
              Text(fight['weight_class'].toString(),
                  style: const TextStyle(color: C.textMuted, fontSize: 10)),
          ]),
          _Corner(opponent, isRed ? 'blue' : 'red'),
        ]),
        const SizedBox(height: 14),

        // Details
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (fight['ring'] != null) ...[
            _Chip('Ring ${fight['ring']}', Icons.location_on),
            const SizedBox(width: 8),
          ],
          if (fight['battle_order'] != null)
            _Chip('Kampf #${fight['battle_order']}', Icons.format_list_numbered),
        ]),
      ]),
    );
  }
}

class _Corner extends StatelessWidget {
  final String name;
  final String corner;
  const _Corner(this.name, this.corner);

  @override
  Widget build(BuildContext context) {
    final color = corner == 'red' ? C.red : C.blue;
    return Column(children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: corner == 'red' ? C.gradientRed : C.gradientBlue,
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 28),
      ),
      const SizedBox(height: 6),
      SizedBox(width: 90, child: Text(name, textAlign: TextAlign.center,
          maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      Text(corner == 'red' ? '🔴 Rot' : '🔵 Blau',
          style: TextStyle(color: color, fontSize: 10)),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: C.textMuted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: C.textMuted, fontSize: 11)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: C.surface, shape: BoxShape.circle,
            border: Border.all(color: C.border)),
        child: const Icon(Icons.sports_mma, size: 40, color: C.textMuted),
      ),
      const SizedBox(height: 16),
      const Text('Kein geplanter Kampf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 4),
      const Text('Du bist aktuell für keinen Kampf eingeteilt.',
          style: TextStyle(color: C.textMuted)),
    ]));
  }
}
