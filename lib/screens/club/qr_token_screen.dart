import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/colors.dart';
import '../../services/api_service.dart';

class QrTokenScreen extends StatefulWidget {
  final Map<String, dynamic> boxer;
  const QrTokenScreen({super.key, required this.boxer});

  @override
  State<QrTokenScreen> createState() => _QrTokenScreenState();
}

class _QrTokenScreenState extends State<QrTokenScreen> {
  final _api = ApiService();
  String? _token;
  String? _qrData;
  bool _loading = false;
  int _ttl = 24;

  Future<void> _generate() async {
    setState(() { _loading = true; _token = null; _qrData = null; });
    try {
      final res = await _api.generateQrToken(widget.boxer['id'] as int, ttlHours: _ttl);
      setState(() {
        _token  = res['token']?.toString();
        _qrData = res['qr_url']?.toString() ?? _token;
        _loading = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: C.error));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR-Login · ${widget.boxer['name']}')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.info.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: C.info, size: 18),
              const SizedBox(width: 10),
              const Expanded(child: Text(
                'Generiere einen QR-Code für den Boxer-Login in Boxen Connect.',
                style: TextStyle(fontSize: 13, height: 1.4),
              )),
            ]),
          ),
          const SizedBox(height: 20),

          // TTL
          const Text('GÜLTIGKEITSDAUER', style: TextStyle(
              color: C.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            selected: {_ttl},
            onSelectionChanged: (s) => setState(() => _ttl = s.first),
            segments: const [
              ButtonSegment(value: 24,   label: Text('24h')),
              ButtonSegment(value: 168,  label: Text('7 Tage')),
              ButtonSegment(value: 720,  label: Text('30 Tage')),
              ButtonSegment(value: 8760, label: Text('1 Jahr')),
            ],
          ),
          const SizedBox(height: 20),

          FilledButton.icon(
            icon: _loading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.qr_code),
            label: const Text('QR-Token generieren'),
            onPressed: _loading ? null : _generate,
          ),

          if (_qrData != null) ...[
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Text(widget.boxer['name']?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(data: _qrData!, size: 220, backgroundColor: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text('Gültig $_ttl Stunden',
                      style: const TextStyle(color: C.textMuted, fontSize: 12)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Token kopieren'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _token ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kopiert!')));
                    },
                  ),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
