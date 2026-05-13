import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/api_service.dart';

class RegistrationsScreen extends StatefulWidget {
  final String clubName;
  const RegistrationsScreen({super.key, required this.clubName});

  @override
  State<RegistrationsScreen> createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends State<RegistrationsScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _regs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _regs = await _api.getClubRegistrations(); } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _unregister(Map<String, dynamic> reg) async {
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Abmelden?'),
        content: Text('${reg['boxer_name'] ?? 'Boxer'} abmelden?'),
        actions: [
          TextButton(onPressed: () => nav.pop(false), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () => nav.pop(true),
            style: FilledButton.styleFrom(backgroundColor: C.error),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.unregisterBoxer(reg['id'] as int);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: C.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anmeldungen'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _regs.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.assignment_outlined, size: 56, color: C.textMuted),
                  const SizedBox(height: 12),
                  const Text('Keine Anmeldungen', style: TextStyle(color: C.textMuted)),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _regs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final r = _regs[i];
                      final doctorOk = r['doctor_approved'] == 1 || r['doctor_approved'] == true;
                      final hasWeight = r['weight_scale'] != null;

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(r['boxer_name']?.toString() ?? r['name']?.toString() ?? '?',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(
                                '${r['weight_class_name'] ?? ''} · ${r['weight_kg'] ?? '—'} kg',
                                style: const TextStyle(color: C.textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Row(children: [
                                _Dot(doctorOk, Icons.medical_services, C.success),
                                const SizedBox(width: 6),
                                _Dot(hasWeight, Icons.scale, C.info),
                                if (r['tolerance_ok'] == 1) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.check_circle, size: 14, color: C.success),
                                ],
                              ]),
                            ])),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: C.error),
                              onPressed: () => _unregister(r),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  final IconData icon;
  final Color color;
  const _Dot(this.active, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Icon(icon, size: 14,
      color: active ? color : C.textMuted.withValues(alpha: 0.4));
}
