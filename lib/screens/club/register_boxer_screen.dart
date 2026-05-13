import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/api_service.dart';

/// Boxer für ein Turnier anmelden oder aktive Anmeldung verwalten.
class RegisterBoxerScreen extends StatefulWidget {
  final Map<String, dynamic> boxer;
  const RegisterBoxerScreen({super.key, required this.boxer});

  @override
  State<RegisterBoxerScreen> createState() => _RegisterBoxerScreenState();
}

class _RegisterBoxerScreenState extends State<RegisterBoxerScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _tournament;
  List<Map<String, dynamic>> _myRegistrations = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.getActiveTournament(),
        _api.getClubRegistrations(),
      ]);
      _tournament = results[0] as Map<String, dynamic>?;
      final all = results[1] as List<Map<String, dynamic>>;
      _myRegistrations = all.where((r) =>
          r['club_boxer_id'] == widget.boxer['id'] ||
          r['boxer_name']?.toString() == widget.boxer['name']?.toString()
      ).toList();
    } catch (_) {}
    setState(() => _loading = false);
  }

  bool get _isRegisteredForActive {
    if (_tournament == null) return false;
    return _myRegistrations.any((r) => r['tournament_id'] == _tournament!['id']);
  }

  Map<String, dynamic>? get _activeReg {
    if (_tournament == null) return null;
    try {
      return _myRegistrations.firstWhere((r) => r['tournament_id'] == _tournament!['id']);
    } catch (_) { return null; }
  }

  Future<void> _register() async {
    final t = _tournament;
    if (t == null) return;

    final weightCtrl = TextEditingController(
        text: widget.boxer['weight_kg']?.toString() ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${widget.boxer['name']} anmelden'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(t['name']?.toString() ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: weightCtrl,
            decoration: const InputDecoration(
                labelText: 'Kampfgewicht (kg)', suffixText: 'kg'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Anmelden')),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final weight = double.tryParse(weightCtrl.text.replaceAll(',', '.'));
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ungültiges Gewicht'), backgroundColor: C.error));
      return;
    }

    try {
      await _api.registerBoxer(widget.boxer['id'] as int, t['id'] as int, weight);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.boxer['name']} angemeldet'),
        backgroundColor: C.success,
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: C.error));
    }
  }

  Future<void> _unregister(Map<String, dynamic> reg) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Abmelden?'),
        content: Text('${widget.boxer['name']} abmelden?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: C.error),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _api.unregisterBoxer(reg['id'] as int);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Abgemeldet'), backgroundColor: C.warning));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: C.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anmeldung · ${widget.boxer['name']}'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Aktives Turnier
                if (_tournament == null)
                  Card(
                    child: Padding(padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        const Icon(Icons.emoji_events_outlined, size: 40, color: C.textMuted),
                        const SizedBox(height: 8),
                        const Text('Kein aktives Turnier', style: TextStyle(color: C.textMuted)),
                      ])),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Icon(Icons.emoji_events, color: C.gold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_tournament!['name']?.toString() ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        ]),
                        const SizedBox(height: 4),
                        Text(_tournament!['event_date']?.toString() ?? '',
                            style: const TextStyle(color: C.textMuted, fontSize: 12)),
                        const SizedBox(height: 16),
                        if (_isRegisteredForActive) ...[
                          Row(children: [
                            const Icon(Icons.check_circle, color: C.success, size: 18),
                            const SizedBox(width: 8),
                            const Text('Angemeldet', style: TextStyle(
                                color: C.success, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () => _unregister(_activeReg!),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: C.error, side: const BorderSide(color: C.error)),
                              child: const Text('Abmelden'),
                            ),
                          ]),
                          if (_activeReg?['weight_kg'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Gewicht: ${_activeReg!['weight_kg']} kg',
                                  style: const TextStyle(fontSize: 12, color: C.textMuted)),
                            ),
                        ] else
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              icon: const Icon(Icons.assignment_turned_in),
                              label: const Text('Jetzt anmelden'),
                              onPressed: _register,
                            ),
                          ),
                      ]),
                    ),
                  ),

                // Alle Anmeldungen
                if (_myRegistrations.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('ALLE ANMELDUNGEN', style: TextStyle(
                      color: C.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  ..._myRegistrations.map((r) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.emoji_events, color: C.red),
                      title: Text(r['tournament_name']?.toString() ?? ''),
                      subtitle: Text('${r['weight_kg'] ?? '—'} kg · ${r['weight_class_name'] ?? ''}'),
                    ),
                  )),
                ],
              ],
            ),
    );
  }
}
