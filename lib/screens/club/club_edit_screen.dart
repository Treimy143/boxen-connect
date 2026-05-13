import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/api_service.dart';

class ClubEditScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  const ClubEditScreen({super.key, required this.club});

  @override
  State<ClubEditScreen> createState() => _ClubEditScreenState();
}

class _ClubEditScreenState extends State<ClubEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _saving = false;

  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _contact;
  late final TextEditingController _phone;
  late final TextEditingController _website;

  @override
  void initState() {
    super.initState();
    final c = widget.club;
    _name    = TextEditingController(text: c['name']?.toString() ?? '');
    _city    = TextEditingController(text: c['city']?.toString() ?? '');
    _contact = TextEditingController(text: c['contact']?.toString() ?? '');
    _phone   = TextEditingController(text: c['phone']?.toString() ?? '');
    _website = TextEditingController(text: c['website']?.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose(); _city.dispose(); _contact.dispose();
    _phone.dispose(); _website.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final nav       = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _api.updateClubMe({
        'name':    _name.text.trim(),
        'city':    _city.text.trim(),
        'contact': _contact.text.trim(),
        'phone':   _phone.text.trim(),
        'website': _website.text.trim(),
      });
      messenger.showSnackBar(const SnackBar(
        content: Text('Vereinsdaten gespeichert'),
        backgroundColor: C.success,
      ));
      nav.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Fehler: $e'), backgroundColor: C.error));
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verein bearbeiten'),
        actions: [
          if (_saving)
            const Padding(padding: EdgeInsets.all(16),
                child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
          else
            TextButton(onPressed: _save,
                child: const Text('Speichern',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_name, 'Vereinsname', Icons.groups, required: true),
            const SizedBox(height: 12),
            _field(_city, 'Stadt', Icons.location_city),
            const SizedBox(height: 12),
            _field(_contact, 'Ansprechpartner', Icons.person_outline),
            const SizedBox(height: 12),
            _field(_phone, 'Telefon', Icons.phone_outlined,
                type: TextInputType.phone),
            const SizedBox(height: 12),
            _field(_website, 'Website', Icons.language,
                type: TextInputType.url),
            const SizedBox(height: 24),
            FilledButton(onPressed: _saving ? null : _save,
                child: const Text('Speichern')),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? type, bool required = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Pflichtfeld' : null
          : null,
    );
  }
}
