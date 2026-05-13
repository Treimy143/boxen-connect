import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/colors.dart';
import '../../models/boxer.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

Future<void> _showSetPinDialog(BuildContext context) async {
  final pinCtrl = TextEditingController();
  final pin2Ctrl = TextEditingController();
  final messenger = ScaffoldMessenger.of(context);

  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('PIN setzen'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text(
          'Mit diesem PIN kannst du dich zukünftig ohne QR-Code anmelden.',
          style: TextStyle(color: C.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'PIN (4-6 Stellen)',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: pin2Ctrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'PIN wiederholen',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen')),
        FilledButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Speichern')),
      ],
    ),
  );

  if (ok != true) return;

  if (pinCtrl.text.length < 4) {
    messenger.showSnackBar(const SnackBar(
        content: Text('PIN muss mindestens 4 Stellen haben'), backgroundColor: C.error));
    return;
  }
  if (pinCtrl.text != pin2Ctrl.text) {
    messenger.showSnackBar(const SnackBar(
        content: Text('PINs stimmen nicht überein'), backgroundColor: C.error));
    return;
  }

  try {
    await ApiService().setBoxerPin(pinCtrl.text);
    messenger.showSnackBar(const SnackBar(
        content: Text('PIN gesetzt! Du kannst dich jetzt mit Boxer-ID + PIN anmelden.'),
        backgroundColor: C.success));
  } catch (e) {
    messenger.showSnackBar(SnackBar(
        content: Text('Fehler: $e'), backgroundColor: C.error));
  }
}

class AusweisScreen extends StatelessWidget {
  final Boxer boxer;
  const AusweisScreen({super.key, required this.boxer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar mit Logout
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            title: const Text('Mein Ausweis'),
            actions: [
              IconButton(
                icon: const Icon(Icons.pin_outlined),
                tooltip: 'PIN setzen',
                onPressed: () => _showSetPinDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => context.read<AuthProvider>().logout(),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _IdCard(boxer: boxer),
                const SizedBox(height: 16),
                _StatsCard(boxer: boxer),
                const SizedBox(height: 16),
                _QrCard(boxer: boxer),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdCard extends StatelessWidget {
  final Boxer boxer;
  const _IdCard({required this.boxer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.border, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Header
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: C.red.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('BOXER-AUSWEIS',
                style: TextStyle(color: C.red, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          ),
          const Spacer(),
          Text('${boxer.flagEmoji}  ${boxer.nation}',
              style: const TextStyle(color: C.textMuted, fontSize: 13)),
        ]),

        const SizedBox(height: 20),

        // Foto + Info
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Foto
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: C.red, width: 2),
              gradient: C.gradientBoxer,
            ),
            child: ClipOval(
              child: boxer.photoUrl != null
                  ? CachedNetworkImage(imageUrl: boxer.photoUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.person, color: C.textMuted, size: 44),
            ),
          ),
          const SizedBox(width: 16),

          // Infos
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(boxer.name, style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(boxer.boxerId, style: const TextStyle(
                color: C.textMuted, fontSize: 12, fontFamily: 'monospace')),
            const SizedBox(height: 8),
            Row(children: [
              _Tag(boxer.genderLabel, C.blue),
              const SizedBox(width: 6),
              if (boxer.weightClass != null) _Tag(boxer.weightClass!, C.surface2),
            ]),
          ])),
        ]),

        const SizedBox(height: 20),
        const Divider(color: C.border),
        const SizedBox(height: 12),

        // Stats-Zeile
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _StatBadge('${boxer.totalFights}', 'Kämpfe', C.textMuted),
          _StatBadge('${boxer.won}', 'Siege', C.success),
          _StatBadge('${boxer.lost}', 'Niederlagen', C.error),
          _StatBadge('${boxer.cancelled}', 'Abbrüche', C.warning),
        ]),

        const SizedBox(height: 8),

        // Club
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.groups, size: 13, color: C.textMuted),
          const SizedBox(width: 6),
          Text(boxer.clubName, style: const TextStyle(color: C.textMuted, fontSize: 12)),
        ]),
      ]),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Boxer boxer;
  const _StatsCard({required this.boxer});

  @override
  Widget build(BuildContext context) {
    final winRate = boxer.totalFights > 0
        ? (boxer.won / boxer.totalFights * 100).toStringAsFixed(0)
        : '0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('STATISTIKEN', style: TextStyle(
              color: C.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _BigStat('$winRate%', 'Siegquote', C.gold)),
            Expanded(child: _BigStat('${boxer.totalFights}', 'Gesamt', C.blue)),
            Expanded(child: _BigStat('${boxer.won}', 'Siege', C.success)),
          ]),
          if (boxer.birthdate != null) ...[
            const SizedBox(height: 12),
            const Divider(color: C.border),
            const SizedBox(height: 12),
            _InfoRow(Icons.cake, 'Geburtsdatum', boxer.birthdate!),
          ],
        ]),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  final Boxer boxer;
  const _QrCard({required this.boxer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('QR-CODE', style: TextStyle(
              color: C.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(boxer.boxerId, style: const TextStyle(color: C.textMuted, fontSize: 11)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showFullscreen(context),
            child: Stack(alignment: Alignment.bottomRight, children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: boxer.boxerId, size: 180,
                  backgroundColor: Colors.white,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 14),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          const Text('Tippen zum Vergrößern',
              style: TextStyle(color: C.textMuted, fontSize: 11)),
        ]),
      ),
    );
  }

  void _showFullscreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(boxer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(boxer.boxerId, style: const TextStyle(color: C.textMuted, fontSize: 12)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: QrImageView(data: boxer.boxerId, size: 280, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Schließen')),
          ]),
        ),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBadge(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: C.textMuted, fontSize: 10)),
    ]);
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _BigStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: C.textMuted, fontSize: 11)),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: C.textMuted),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(color: C.textMuted, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    ]);
  }
}
