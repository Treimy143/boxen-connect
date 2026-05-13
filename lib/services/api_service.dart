import 'package:dio/dio.dart';
import '../core/api.dart';
import '../core/secrets.dart';

/// Basis-API-Service mit Bearer-Token-Interceptor.
/// Token wird dynamisch gesetzt — kein State hier drin.
class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  String? _token;

  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: kApiBase,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (err, handler) {
        // Weiterleiten — Fehlerbehandlung erfolgt im Feature-Code
        handler.next(err);
      },
    ));
  }

  factory ApiService() => _instance ??= ApiService._();

  void setToken(String? token) => _token = token;
  void clearToken() => _token = null;
  bool get hasToken => _token != null;

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> boxerLoginQr(String token) async {
    final res = await _dio.post('/auth/boxer-login', data: {
      'token': token,
      'device_name': 'Boxen Connect',
    });
    return _data(res);
  }

  Future<Map<String, dynamic>> boxerLoginPin(String boxerId, String pin) async {
    final res = await _dio.post('/auth/boxer-login', data: {
      'boxer_id': boxerId.toUpperCase(),
      'pin': pin,
      'device_name': 'Boxen Connect',
    });
    return _data(res);
  }

  Future<Map<String, dynamic>> clubLogin(String code, String password) async {
    final res = await _dio.post('/auth/club-login', data: {
      'code': code.toUpperCase(),
      'password': password,
      'device_name': 'Boxen Connect',
    });
    return _data(res);
  }

  Future<void> logout() async {
    try { await _dio.post('/auth/logout'); } catch (_) {}
    clearToken();
  }

  // ── Boxer ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getBoxerMe() async {
    final res = await _dio.get('/boxer/me');
    return _data(res);
  }

  Future<List<Map<String, dynamic>>> getBoxerUpcoming() async {
    final res = await _dio.get('/boxer/upcoming');
    return _list(res);
  }

  Future<List<Map<String, dynamic>>> getBoxerHistory() async {
    final res = await _dio.get('/boxer/history');
    return _list(res);
  }

  Future<List<Map<String, dynamic>>> getBoxerRegistrations() async {
    final res = await _dio.get('/boxer/registrations');
    return _list(res);
  }

  Future<void> setBoxerPin(String pin) async {
    await _dio.post('/boxer/pin', data: {'pin': pin});
  }

  // ── Verein ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getClubMe() async {
    final res = await _dio.get('/club/me');
    return _data(res);
  }

  Future<void> updateClubMe(Map<String, dynamic> data) async {
    await _dio.post('/club/me', data: data);
  }

  Future<List<Map<String, dynamic>>> getClubBoxers() async {
    final res = await _dio.get('/club/boxers');
    return _list(res);
  }

  Future<Map<String, dynamic>> createClubBoxer(Map<String, dynamic> data) async {
    final res = await _dio.post('/club/boxers', data: data);
    return _data(res);
  }

  Future<void> updateClubBoxer(int id, Map<String, dynamic> data) async {
    await _dio.post('/club/boxers/$id', data: data);
  }

  Future<void> deleteClubBoxer(int id) async {
    await _dio.post('/club/boxers/$id/delete');
  }

  Future<Map<String, dynamic>> generateQrToken(int id, {int ttlHours = 24}) async {
    final res = await _dio.post('/club/boxers/$id/qr-token', data: {'ttl_hours': ttlHours});
    return _data(res);
  }

  Future<List<Map<String, dynamic>>> getClubRegistrations({int? tournamentId}) async {
    final res = await _dio.get('/club/registrations',
        queryParameters: tournamentId != null ? {'tournament_id': tournamentId} : null);
    return _list(res);
  }

  Future<void> registerBoxer(int clubBoxerId, int tournamentId, double weightKg) async {
    await _dio.post('/club/registrations', data: {
      'club_boxer_id': clubBoxerId,
      'tournament_id': tournamentId,
      'weight_kg': weightKg,
    });
  }

  Future<void> updateRegistrationWeight(int regId, double weightKg) async {
    await _dio.post('/club/registrations/$regId', data: {'weight_kg': weightKg});
  }

  Future<void> unregisterBoxer(int regId) async {
    await _dio.post('/club/registrations/$regId/delete');
  }

  Future<List<Map<String, dynamic>>> getClubBattles({int? tournamentId}) async {
    final res = await _dio.get('/club/battles',
        queryParameters: tournamentId != null ? {'tournament_id': tournamentId} : null);
    return _list(res);
  }

  // ── Public ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getActiveTournament() async {
    try {
      final res = await Dio(BaseOptions(baseUrl: kApiBase,
        headers: {'Authorization': 'Bearer $kPublicToken'}))
          .get('/tournaments/active');
      if (res.data['success'] != true) return null;
      return res.data['data'] as Map<String, dynamic>?;
    } catch (_) { return null; }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Map<String, dynamic> _data(Response res) {
    final body = res.data as Map<String, dynamic>;
    if (body['success'] == false) throw body['error'] ?? 'Unbekannter Fehler';
    return body['data'] as Map<String, dynamic>? ?? body;
  }

  List<Map<String, dynamic>> _list(Response res) {
    final body = res.data as Map<String, dynamic>;
    if (body['success'] == false) throw body['error'] ?? 'Unbekannter Fehler';
    final list = body['data'] as List? ?? [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
