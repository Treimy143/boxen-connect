import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../models/boxer.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final Boxer boxer;
  const HistoryScreen({super.key, required this.boxer});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _history = await _api.getBoxerHistory(); } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kampfhistorie'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.history, size: 48, color: C.textMuted),
                  const SizedBox(height: 12),
                  const Text('Noch keine Kämpfe', style: TextStyle(color: C.textMuted)),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _HistoryCard(fight: _history[i]),
                  ),
                ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> fight;
  const _HistoryCard({required this.fight});

  @override
  Widget build(BuildContext context) {
    final result = fight['my_result']?.toString().toLowerCase() ?? '';
    final resultColor = switch (result) {
      'won'  => C.success,
      'lost' => C.error,
      _      => C.textMuted,
    };
    final resultLabel = switch (result) {
      'won'       => 'SIEG',
      'lost'      => 'NIEDERLAGE',
      'cancelled' => 'ABBRUCH',
      _           => fight['outcome_title']?.toString() ?? result.toUpperCase(),
    };
    final isRed = fight['my_corner']?.toString() == 'red';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          // Ergebnis-Balken
          Container(
            width: 4, height: 60,
            decoration: BoxDecoration(
              color: resultColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),

          // Infos
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fight['tournament_name']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text('vs. ${fight['opponent_name'] ?? '?'}',
                style: const TextStyle(color: C.textMuted, fontSize: 13)),
            const SizedBox(height: 2),
            Row(children: [
              Text(fight['event_date']?.toString() ?? '',
                  style: const TextStyle(color: C.textMuted, fontSize: 11)),
              const SizedBox(width: 8),
              Text(isRed ? '🔴 Rot' : '🔵 Blau',
                  style: const TextStyle(fontSize: 11)),
            ]),
          ])),

          // Ergebnis-Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: resultColor.withValues(alpha: 0.3)),
            ),
            child: Text(resultLabel,
                style: TextStyle(color: resultColor, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
