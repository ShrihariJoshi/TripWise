import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService extends GetConnect {
  late SharedPreferences _prefs;

  final FlutterSecureStorage _store = const FlutterSecureStorage();

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kShort = 'short_lived_token';

  Future<void> saveAccessToken(String token) =>
      _store.write(key: _kAccess, value: token);
  Future<void> saveRefreshToken(String token) =>
      _store.write(key: _kRefresh, value: token);
  Future<void> saveShortLivedToken(String token) =>
      _store.write(key: _kShort, value: token);

  Future<String?> readAccessToken() => _store.read(key: _kAccess);
  Future<String?> readRefreshToken() => _store.read(key: _kRefresh);
  Future<String?> readShortLivedToken() => _store.read(key: _kShort);

  Future<void> clearAll() => _store.deleteAll();

  String? _accessToken;
  String? _refreshToken;
  String? _shortLivedToken;
  bool? _test;

  Future<CacheService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await fetchTokensFromCache();
    _test = _prefs.getBool('test') ?? false;
    return this;
  }

  Future<void> fetchTokensFromCache() async {
    readAccessToken();
    readRefreshToken();
    readShortLivedToken();
    debugPrint(
      'Access: $_accessToken, Refresh: $_refreshToken, ShortLived: $_shortLivedToken',
    );
  }

  Future<void> saveTokensToCache({
    String? accessToken,
    String? refreshToken,
    String? shortLivedToken,
  }) async {
    if (accessToken != null && accessToken.isNotEmpty) {
      await _prefs.setString("accessToken", accessToken);
      _accessToken = accessToken;
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _prefs.setString("refreshToken", refreshToken);
      _refreshToken = refreshToken;
    }
    if (shortLivedToken != null && shortLivedToken.isNotEmpty) {
      await _prefs.setString("shortLivedToken", shortLivedToken);
      _shortLivedToken = shortLivedToken;
    }
    Get.log("Tokens saved to cache");
  }

  Future<bool> clearTokens() async => await _prefs.clear();

  String? get accessToken => _accessToken;

  String? get refreshToken => _refreshToken;

  String? get shortLivedToken => _shortLivedToken;

  bool get isTest => _test ?? false;

  bool get ifNoTokenExists =>
      (_accessToken == null &&
      _refreshToken == null &&
      _shortLivedToken == null);

  bool? fetchBoolFromCache(String key) {
    final res = _prefs.getBool(key);
    Logger().d('get $key = $res ');
    return res;
  }

  String? fetchStringFromCache(String key) {
    final res = _prefs.getString(key);
    Logger().d('get $key = $res ');
    return res;
  }

  List<String>? fetchStringListFromCache(String key) {
    final res = _prefs.getStringList(key);
    Logger().d('get $key = $res ');
    return res;
  }

  int? fetchIntFromCache(String key) {
    final res = _prefs.getInt(key);
    Logger().d('get $key = $res ');
    return res;
  }

  double? fetchDoubleFromCache(String key) {
    final res = _prefs.getDouble(key);
    Logger().d('get $key = $res ');
    return res;
  }

  Future<bool> saveBoolToCache(String key, bool value) async {
    Logger().w("before save: key: $key, value: $value");
    final res = await _prefs.setBool(key, value);
    Logger().d('saved $key = $res ');
    return res;
  }

  Future<bool?> saveStringToCache({
    required String key,
    required String value,
  }) async {
    return await _prefs.setString(key, value);
  }

  Future<bool?> saveStringListToCache({
    required String key,
    required List<String> value,
  }) async {
    return await _prefs.setStringList(key, value);
  }

  Future<bool?> saveIntToCache({
    required String key,
    required int value,
  }) async {
    return await _prefs.setInt(key, value);
  }

  Future<bool?> saveMapToCache({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    String json = jsonEncode(value);
    bool success = await _prefs.setString(key, json);
    if (success) {
      debugPrint("Map saved to cache $key");
    }
    return success;
  }

  Map<String, dynamic>? fetchMapFromCache(String key) {
    String? json = _prefs.getString(key);
    if (json == null) return null;
    return jsonDecode(json);
  }

  Future<bool?> saveDoubleToCache({
    required String key,
    required double value,
  }) async {
    return await _prefs.setDouble(key, value);
  }

  Future<bool> clearValue(String key) async => await _prefs.remove(key);
}
