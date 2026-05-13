import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../core/colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Hero-Header ──────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0A0A), C.bg],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 24, 24, 24),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: C.gradientRed,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: C.red.withValues(alpha: 0.4),
                      blurRadius: 20, offset: const Offset(0, 8),
                    )],
                  ),
                  child: const Icon(Icons.sports_mma, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Boxen', style: TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  )),
                  Text('Connect', style: TextStyle(
                    color: C.red, fontSize: 26, fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  )),
                ]),
              ]),
              const SizedBox(height: 8),
              Text('Dein digitaler Boxing-Begleiter',
                  style: TextStyle(color: C.textMuted, fontSize: 13)),
            ]),
          ),

          // ── Tab-Bar ───────────────────────────────────────────────────────
          Container(
            color: C.bg,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Container(
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.border, width: 0.5),
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                  gradient: C.gradientRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: C.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: '🥊  Boxer'),
                  Tab(text: '🏛  Verein'),
                ],
              ),
            ),
          ),

          // ── Tab-Content ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _BoxerTab(),
                _ClubTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOXER TAB
// ─────────────────────────────────────────────────────────────────────────────

class _BoxerTab extends StatefulWidget {
  const _BoxerTab();

  @override
  State<_BoxerTab> createState() => _BoxerTabState();
}

class _BoxerTabState extends State<_BoxerTab> {
  final _idCtrl  = TextEditingController();
  final _pinCtrl = TextEditingController();

  @override
  void dispose() { _idCtrl.dispose(); _pinCtrl.dispose(); super.dispose(); }

  Future<void> _scanQr() async {
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _QrScanSheet(
        onDetected: (value) async {
          final ok = await auth.loginBoxerQr(value);
          if (ok && nav.canPop()) nav.pop();
          return ok;
        },
      )),
    );
  }

  Future<void> _pinLogin() async {
    if (_idCtrl.text.isEmpty || _pinCtrl.text.isEmpty) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginBoxerPin(_idCtrl.text.trim(), _pinCtrl.text.trim());
    if (!ok && mounted) _showError(auth.error ?? 'Login fehlgeschlagen');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: C.error));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.state == AuthState.loading;

    final last = auth.lastBoxer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 8),

        // Weiter als [Name] — wenn letzter Boxer bekannt
        if (last != null) ...[
          GestureDetector(
            onTap: auth.reloginBoxer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.border),
              ),
              child: Row(children: [
                CircleAvatar(
                  backgroundColor: C.surface2,
                  child: Text(last.name.isNotEmpty ? last.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: C.red, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Weiter als', style: TextStyle(color: C.textMuted, fontSize: 11)),
                  Text(last.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ])),
                const Icon(Icons.arrow_forward_ios, size: 14, color: C.textMuted),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('oder anders anmelden', style: TextStyle(color: C.textMuted, fontSize: 11)),
            ),
            const Expanded(child: Divider()),
          ]),
          const SizedBox(height: 16),
        ],

        // QR-Button
        _BigButton(
          label: 'QR-Code scannen',
          subtitle: 'Halte die Kamera auf deinen Ausweis-QR',
          icon: Icons.qr_code_scanner,
          gradient: C.gradientRed,
          loading: loading,
          onTap: _scanQr,
        ),
        const SizedBox(height: 16),

        // Divider
        Row(children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('oder mit PIN', style: TextStyle(color: C.textMuted, fontSize: 12)),
          ),
          const Expanded(child: Divider()),
        ]),
        const SizedBox(height: 16),

        // PIN-Login
        TextFormField(
          controller: _idCtrl,
          decoration: const InputDecoration(
            labelText: 'Boxer-ID',
            hintText: 'BX-2026-00217',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'PIN',
            prefixIcon: Icon(Icons.lock_outline),
            counterText: '',
          ),
          onFieldSubmitted: (_) => _pinLogin(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: loading ? null : _pinLogin,
            style: FilledButton.styleFrom(backgroundColor: C.surface2,
                foregroundColor: C.text),
            child: const Text('Mit PIN anmelden'),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CLUB TAB
// ─────────────────────────────────────────────────────────────────────────────

class _ClubTab extends StatefulWidget {
  const _ClubTab();

  @override
  State<_ClubTab> createState() => _ClubTabState();
}

class _ClubTabState extends State<_ClubTab> {
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _codeCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (_codeCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginClub(_codeCtrl.text.trim(), _passCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Login fehlgeschlagen'),
        backgroundColor: C.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.state == AuthState.loading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _codeCtrl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Vereinscode',
            hintText: 'z.B. NLS',
            prefixIcon: Icon(Icons.groups_outlined),
            helperText: 'Groß-/Kleinschreibung egal',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passCtrl,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'Passwort',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          onFieldSubmitted: (_) => _login(),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: loading ? null : _login,
            child: loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Als Verein anmelden'),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BigButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final bool loading;
  final VoidCallback onTap;

  const _BigButton({
    required this.label, required this.subtitle, required this.icon,
    required this.gradient, required this.loading, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: C.red.withValues(alpha: 0.3),
            blurRadius: 16, offset: const Offset(0, 6),
          )],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: loading
                ? const Center(child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                : Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            Text(subtitle, style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
          ])),
          Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.6), size: 16),
        ]),
      ),
    );
  }
}

class _QrScanSheet extends StatefulWidget {
  final Future<bool> Function(String) onDetected;
  const _QrScanSheet({required this.onDetected});

  @override
  State<_QrScanSheet> createState() => _QrScanSheetState();
}

class _QrScanSheetState extends State<_QrScanSheet> {
  final _ctrl = MobileScannerController();
  bool _processing = false;
  String? _errorMsg;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final val = capture.barcodes.firstOrNull?.rawValue;
    if (val == null) return;

    setState(() { _processing = true; _errorMsg = null; });
    await _ctrl.stop();

    final success = await widget.onDetected(val);

    if (!mounted) return;

    if (success) return; // Navigator.pop wird vom Aufrufer gemacht

    // Fehler anzeigen, Scanner wieder starten
    setState(() {
      _processing = false;
      _errorMsg = 'Dieser QR-Code ist kein gültiger Login-Token.\n'
          'Bitte über Boxen Connect (Verein) einen Login-QR generieren.';
    });
    await _ctrl.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('QR-Code scannen'),
        actions: [
          IconButton(icon: const Icon(Icons.flash_on),
              onPressed: () => _ctrl.toggleTorch()),
        ],
      ),
      body: Stack(children: [
        MobileScanner(controller: _ctrl, onDetect: _handleDetect),
        Center(
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              border: Border.all(
                  color: _errorMsg != null ? C.error : C.red, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          bottom: 40, left: 16, right: 16,
          child: _processing
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _errorMsg != null
                  ? Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: C.error.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 24),
                        const SizedBox(height: 8),
                        Text(_errorMsg!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() => _errorMsg = null),
                          child: const Text('Erneut versuchen',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                    )
                  : const Text(
                      'QR-Code in den Rahmen halten',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
        ),
      ]),
    );
  }
}
