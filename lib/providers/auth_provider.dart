import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/boxer.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum AuthState { loading, boxer, club, none }

class AuthProvider extends ChangeNotifier {
  final _api = ApiService();

  AuthState state = AuthState.loading;

  // Aktive Session
  Boxer? boxer;
  Map<String, dynamic>? club;
  String? error;

  // Letzter Boxer für schnellen Wiedereinstieg
  Boxer? lastBoxer;

  Future<void> init() async {
    final boxerToken = await StorageService.getToken(kBoxerToken);
    final clubToken  = await StorageService.getToken(kClubToken);

    if (boxerToken != null) {
      _api.setToken(boxerToken);
      try {
        final data = await _api.getBoxerMe();
        boxer = Boxer.fromJson(data);
        lastBoxer = boxer;
        state = AuthState.boxer;
        notifyListeners();
        return;
      } catch (_) {
        // Token abgelaufen — für "Weiter als" trotzdem lastBoxer aus Cache laden
        _api.clearToken();
        // Token behalten für potenzielle Anzeige des letzten Boxers
      }
    }

    // lastBoxer aus Cache für "Weiter als" Button
    final cachedName = StorageService.get<String>('last_boxer_name');
    final cachedId   = StorageService.get<String>('last_boxer_id');
    if (cachedName != null && cachedId != null) {
      lastBoxer = Boxer(
        id: 0, boxerId: cachedId, name: cachedName,
        gender: 'm', age: 0, nation: '', clubName: '',
        totalFights: 0, won: 0, lost: 0, cancelled: 0,
      );
    }

    if (clubToken != null) {
      _api.setToken(clubToken);
      try {
        club = await _api.getClubMe();
        state = AuthState.club;
        notifyListeners();
        return;
      } catch (_) {
        await StorageService.deleteToken(kClubToken);
        _api.clearToken();
      }
    }

    state = AuthState.none;
    notifyListeners();
  }

  // ── Boxer Login ───────────────────────────────────────────────────────────
  Future<bool> loginBoxerQr(String rawQrValue) async {
    error = null;
    state = AuthState.loading;
    notifyListeners();

    try {
      final token = _extractQrToken(rawQrValue);
      final res   = await _api.boxerLoginQr(token);
      return await _finalizeBoxerLogin(res);
    } on DioException catch (e) {
      error = _dioError(e);
    } catch (e) {
      error = e.toString();
    }
    state = AuthState.none;
    notifyListeners();
    return false;
  }

  Future<bool> loginBoxerPin(String boxerId, String pin) async {
    error = null;
    state = AuthState.loading;
    notifyListeners();

    try {
      final res = await _api.boxerLoginPin(boxerId, pin);
      return await _finalizeBoxerLogin(res);
    } on DioException catch (e) {
      error = _dioError(e);
    } catch (e) {
      error = e.toString();
    }
    state = AuthState.none;
    notifyListeners();
    return false;
  }

  Future<bool> _finalizeBoxerLogin(Map<String, dynamic> data) async {
    final token = data['token'] as String?;
    if (token == null) { error = 'Kein Token erhalten'; return false; }

    await StorageService.saveToken(kBoxerToken, token);
    _api.setToken(token);

    final me = await _api.getBoxerMe();
    boxer = Boxer.fromJson(me);
    lastBoxer = boxer;
    await StorageService.set('last_boxer_name', boxer!.name);
    await StorageService.set('last_boxer_id', boxer!.boxerId);
    state = AuthState.boxer;
    notifyListeners();
    return true;
  }

  Future<void> reloginBoxer() async {
    if (lastBoxer == null) return;
    final token = await StorageService.getToken(kBoxerToken);
    if (token == null) return;
    _api.setToken(token);
    boxer = lastBoxer;
    state = AuthState.boxer;
    notifyListeners();
  }

  // ── Club Login ────────────────────────────────────────────────────────────
  Future<bool> loginClub(String code, String password) async {
    error = null;
    state = AuthState.loading;
    notifyListeners();

    try {
      final res   = await _api.clubLogin(code, password);
      final token = res['token'] as String?;
      if (token == null) { error = 'Kein Token erhalten'; return false; }

      await StorageService.saveToken(kClubToken, token);
      _api.setToken(token);
      club = res['club'] as Map<String, dynamic>? ?? {};
      state = AuthState.club;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      error = _dioError(e);
    } catch (e) {
      error = e.toString();
    }
    state = AuthState.none;
    notifyListeners();
    return false;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    if (state == AuthState.club) {
      await _api.logout();
      await StorageService.deleteToken(kClubToken);
    }
    // Boxer-Token NICHT löschen → ermöglicht "Weiter als [Name]"
    _api.clearToken();
    club  = null;
    boxer = null;
    state = AuthState.none;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _extractQrToken(String raw) {
    try {
      final uri = Uri.parse(raw);
      if (uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last;
        if (last.length > 20 && !last.startsWith('BX-')) return last;
      }
    } catch (_) {}
    return raw;
  }

  String _dioError(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401) return 'Falscher Code/PIN oder Token abgelaufen';
    if (code == 429) return 'Zu viele Versuche — bitte 15 Min warten';
    if (code == 422) return 'Ungültige Eingabe';
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Keine Verbindung zum Server';
    }
    return 'Fehler ${code ?? ""}';
  }
}

