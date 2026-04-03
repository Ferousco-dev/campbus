import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  PinService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _pinHashKey = 'auth_pin_hash';
  static const String _emailKey = 'auth_email';

  static String hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  static Future<void> cachePinHash(String pin) async {
    await _storage.write(key: _pinHashKey, value: hashPin(pin));
  }

  static Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinHashKey);
    if (storedHash == null) return false;
    return storedHash == hashPin(pin);
  }

  static Future<bool> hasPin() async {
    return _storage.containsKey(key: _pinHashKey);
  }

  static Future<void> cacheEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  static Future<String?> readEmail() async {
    return _storage.read(key: _emailKey);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _emailKey);
  }
}
