import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/boxer/boxer_shell.dart';
import 'screens/club/club_shell.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const BoxenConnectApp());
}

class BoxenConnectApp extends StatelessWidget {
  const BoxenConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..init(),
      child: MaterialApp(
        title: 'Boxen Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return switch (auth.state) {
      AuthState.loading => const Scaffold(body: Center(child: CircularProgressIndicator())),
      AuthState.boxer   => const BoxerShell(),
      AuthState.club    => const ClubShell(),
      AuthState.none    => const LoginScreen(),
    };
  }
}
