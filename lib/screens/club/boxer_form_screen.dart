import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/api_service.dart';

class BoxerFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingBoxer;
  const BoxerFormScreen({super.key, this.existingBoxer});

  @override
  State<BoxerFormScreen> createState() => _BoxerFormScreenState();
}

class _BoxerFormScreenState extends State<BoxerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _saving = false;

  late final TextEditingController _name;
  late final TextEditingController _birthdate;
  late final TextEditingController _weight;
  late final TextEditingController _hometown;
  String _gender = 'm';
  String _nation = 'DE';

  bool get _isEdit => widget.existingBoxer != null;

  @override
  void initState() {
    super.initState();
    final b = widget.existingBoxer;
    _name      = TextEditingController(text: b?['name']?.toString() ?? '');
    _birthdate = TextEditingController(text: b?['birthdate']?.toString() ?? '');
    _weight    = TextEditingController(text: b?['weight_kg']?.toString() ?? '');
    _hometown  = TextEditingController(text: b?['hometown']?.toString() ?? '');
    _gender    = b?['gender']?.toString() ?? 'm';
    _nation    = b?['nation']?.toString() ?? 'DE';
  }

  @override
  void dispose() {
    _name.dispose(); _birthdate.dispose();
    _weight.dispose(); _hometown.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final nav       = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'gender': _gender,
      'birthdate': _birthdate.text.trim(),
      'weight_kg': double.tryParse(_weight.text.replaceAll(',', '.')),
      'nation': _nation,
      if (_hometown.text.trim().isNotEmpty) 'hometown': _hometown.text.trim(),
    };

    try {
      if (_isEdit) {
        await _api.updateClubBoxer(widget.existingBoxer!['id'] as int, data);
      } else {
        await _api.createClubBoxer(data);
      }
      nav.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text('Fehler: $e'), backgroundColor: C.error));
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _delete() async {
    final nav       = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Löschen?'),
        content: Text('${_name.text} wirklich löschen?'),
        actions: [
          TextButton(onPressed: () => nav.pop(false), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () => nav.pop(true),
            style: FilledButton.styleFrom(backgroundColor: C.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _api.deleteClubBoxer(widget.existingBoxer!['id'] as int);
      nav.pop(true);
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Fehler: $e'), backgroundColor: C.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Boxer bearbeiten' : 'Neuer Boxer'),
        actions: [
          if (_saving)
            const Padding(padding: EdgeInsets.all(16),
                child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
          else
            TextButton(onPressed: _save,
                child: const Text('Speichern', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            _Label('NAME'),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Vollständiger Name', prefixIcon: Icon(Icons.person)),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Pflichtfeld' : null,
            ),
            const SizedBox(height: 16),

            // Geschlecht
            _Label('GESCHLECHT'),
            SegmentedButton<String>(
              selected: {_gender},
              onSelectionChanged: (s) => setState(() => _gender = s.first),
              segments: const [
                ButtonSegment(value: 'm', label: Text('Männlich')),
                ButtonSegment(value: 'w', label: Text('Weiblich')),
                ButtonSegment(value: 'x', label: Text('Divers')),
              ],
            ),
            const SizedBox(height: 16),

            // Geburtsdatum
            _Label('GEBURTSDATUM'),
            TextFormField(
              controller: _birthdate,
              decoration: const InputDecoration(labelText: 'YYYY-MM-DD', prefixIcon: Icon(Icons.cake)),
              keyboardType: TextInputType.datetime,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Pflichtfeld';
                if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v.trim())) return 'Format: YYYY-MM-DD';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gewicht
            _Label('GEWICHT'),
            TextFormField(
              controller: _weight,
              decoration: const InputDecoration(labelText: 'kg', suffixText: 'kg', prefixIcon: Icon(Icons.scale)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Pflichtfeld';
                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Ungültige Zahl';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nation
            _Label('NATION'),
            DropdownButtonFormField<String>(
              initialValue: _nation,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.flag)),
              items: _nations.map((n) => DropdownMenuItem(
                value: n.$1,
                child: Text('${_flag(n.$1)}  ${n.$2}'),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => _nation = v); },
            ),
            const SizedBox(height: 16),

            // Heimatort (optional)
            _Label('HEIMATORT (OPTIONAL)'),
            TextFormField(
              controller: _hometown,
              decoration: const InputDecoration(labelText: 'Stadt', prefixIcon: Icon(Icons.location_city)),
            ),
            const SizedBox(height: 28),

            FilledButton(onPressed: _saving ? null : _save,
                child: Text(_isEdit ? 'Speichern' : 'Boxer anlegen')),

            if (_isEdit) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: C.error),
                label: const Text('Löschen', style: TextStyle(color: C.error)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: C.error)),
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _flag(String code) {
    if (code.length != 2) return '';
    return code.toUpperCase().runes.map((r) => String.fromCharCode(r + 0x1F1A5)).join();
  }

  static const _nations = [
    ('DE', 'Deutschland'), ('AT', 'Österreich'), ('CH', 'Schweiz'),
    ('TR', 'Türkei'), ('PL', 'Polen'), ('RU', 'Russland'),
    ('UA', 'Ukraine'), ('IT', 'Italien'), ('FR', 'Frankreich'),
    ('NL', 'Niederlande'), ('HR', 'Kroatien'), ('RS', 'Serbien'),
  ];
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}
