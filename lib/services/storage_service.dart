import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Sicherer Token-Speicher + Hive-Cache
class StorageService {
  static const _storage = FlutterSecureStorage();

  // ── Tokens ────────────────────────────────────────────────────────────────
  static Future<void> saveToken(String key, String token) =>
      _storage.write(key: key, value: token);

  static Future<String?> getToken(String key) => _storage.read(key: key);

  static Future<void> deleteToken(String key) => _storage.delete(key: key);

  static Future<void> clearAll() => _storage.deleteAll();

  // ── Hive Cache ────────────────────────────────────────────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('cache');
  }

  static Future<void> set(String key, dynamic value) =>
      Hive.box('cache').put(key, value);

  static T? get<T>(String key) => Hive.box('cache').get(key) as T?;

  static Future<void> clearCache() => Hive.box('cache').clear();
}

// Token-Schlüssel
const kBoxerToken = 'boxer_token';
const kClubToken  = 'club_token';
