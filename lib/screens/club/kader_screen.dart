import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/api_service.dart';
import 'boxer_form_screen.dart';
import 'register_boxer_screen.dart';
import 'qr_token_screen.dart';

class KaderScreen extends StatefulWidget {
  final String clubName;
  const KaderScreen({super.key, required this.clubName});

  @override
  State<KaderScreen> createState() => _KaderScreenState();
}

class _KaderScreenState extends State<KaderScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _boxers = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _boxers = await _api.getClubBoxers(); } catch (_) {}
    setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _boxers;
    final q = _search.toLowerCase();
    return _boxers.where((b) =>
        (b['name']?.toString() ?? '').toLowerCase().contains(q)).toList();
  }

  Future<void> _openForm({Map<String, dynamic>? boxer}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BoxerFormScreen(existingBoxer: boxer)),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final boxers = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kader · ${widget.clubName}'),
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: () => _openForm()),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Boxer suchen…',
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: EdgeInsets.zero,
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 16),
                        onPressed: () => setState(() => _search = ''))
                    : null,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.person_add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : boxers.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.people_outline, size: 56, color: C.textMuted),
                  const SizedBox(height: 12),
                  Text(_search.isEmpty ? 'Noch keine Boxer' : 'Kein Treffer',
                      style: const TextStyle(color: C.textMuted)),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: boxers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _BoxerCard(
                      boxer: boxers[i],
                      onEdit: () => _openForm(boxer: boxers[i]),
                      onRegister: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => RegisterBoxerScreen(boxer: boxers[i]))),
                      onQr: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => QrTokenScreen(boxer: boxers[i]))),
                    ),
                  ),
                ),
    );
  }
}

class _BoxerCard extends StatelessWidget {
  final Map<String, dynamic> boxer;
  final VoidCallback onEdit;
  final VoidCallback onRegister;
  final VoidCallback onQr;
  const _BoxerCard({required this.boxer, required this.onEdit, required this.onRegister, required this.onQr});

  @override
  Widget build(BuildContext context) {
    final photo = boxer['photo_url']?.toString();
    final doctorOk = boxer['doctor_approved'] == 1 || boxer['doctor_approved'] == true;
    final hasWeight = boxer['weight_scale'] != null;
    final name = boxer['name']?.toString() ?? '?';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: C.surface2,
              backgroundImage: photo != null ? CachedNetworkImageProvider(photo) : null,
              child: photo == null
                  ? Text(name[0].toUpperCase(),
                      style: const TextStyle(color: C.red, fontWeight: FontWeight.bold, fontSize: 16))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                '${boxer['birthdate'] ?? '—'}  ·  ${boxer['weight_kg'] ?? '—'} kg',
                style: const TextStyle(color: C.textMuted, fontSize: 12),
              ),
            ])),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _StatusDot(doctorOk, Icons.medical_services, 'Arzt-Freigabe'),
              const SizedBox(width: 6),
              _StatusDot(hasWeight, Icons.scale, 'Gewogen'),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: C.textMuted),
                onSelected: (v) {
                  if (v == 'edit') { onEdit(); }
                  else if (v == 'register') { onRegister(); }
                  else if (v == 'qr') { onQr(); }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: ListTile(
                      leading: Icon(Icons.edit), title: Text('Bearbeiten'), dense: true)),
                  PopupMenuItem(value: 'register', child: ListTile(
                      leading: Icon(Icons.assignment_turned_in), title: Text('Anmelden'), dense: true)),
                  PopupMenuItem(value: 'qr', child: ListTile(
                      leading: Icon(Icons.qr_code), title: Text('QR-Login'), dense: true)),
                ],
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String tooltip;
  const _StatusDot(this.active, this.icon, this.tooltip);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 15,
          color: active ? C.success : C.textMuted.withValues(alpha: 0.5)),
    );
  }
}
