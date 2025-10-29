// lib/service/calendar/calendar_api.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/util/mem_cache.dart';
import 'package:dear_deer_demo/main.dart' show SharedPreferencesKeys;

class CalendarApi extends GetxService {
  final GetConnect _api;
  CalendarApi(this._api);

  // ---- ENV / URL ----
  String get _apiBase => (dotenv.env['API_BASE_URL'] ?? '').trim();
  String get _apiPrefix => (dotenv.env['API_PREFIX'] ?? '').trim();

  String url(String path) {
    final base = _apiBase.replaceAll(RegExp(r'/*$'), '');
    final prefix = _apiPrefix
        .replaceAll(RegExp(r'^/+'), '')
        .replaceAll(RegExp(r'/*$'), '');
    final p = path.replaceAll(RegExp(r'^/+'), '');
    return [base, if (prefix.isNotEmpty) prefix, p].join('/');
  }

  // ---- AUTH HEADERS ----
  Future<String?> _currentAccessToken() async {
    final mem = MemCache.get(MemCacheKey.jwtAccessToken);
    if (mem is String && mem.isNotEmpty) return mem;

    final prefs = await SharedPreferences.getInstance();
    final sp = prefs.getString(SharedPreferencesKeys.accessToken);
    if (sp != null && sp.isNotEmpty) return sp;

    return null;
  }

  Future<Map<String, String>> _authHeaders([Map<String, String>? extra]) async {
    final at = await _currentAccessToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (at != null && at.isNotEmpty) 'Authorization': 'Bearer $at',
    };
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  // ---- RETRY GET/POST/PUT/DELETE (401→refresh) ----
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    final u = url(path);
    var headers = await _authHeaders();
    var res = await _api.get<T>(u, query: query, headers: headers);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        res = await _api.get<T>(u, query: query, headers: headers);
      }
    }
    return res;
  }

  Future<Response<T>> post<T>(String path, Object body) async {
    final u = url(path);
    var headers = await _authHeaders();
    var res = await _api.post<T>(u, body, headers: headers);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        res = await _api.post<T>(u, body, headers: headers);
      }
    }
    return res;
  }

  Future<Response<T>> put<T>(String path, Object body) async {
    final u = url(path);
    var headers = await _authHeaders();
    var res = await _api.put<T>(u, body, headers: headers);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        res = await _api.put<T>(u, body, headers: headers);
      }
    }
    return res;
  }

  Future<Response<T>> delete<T>(String path) async {
    final u = url(path);
    var headers = await _authHeaders();
    var res = await _api.delete<T>(u, headers: headers);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        res = await _api.delete<T>(u, headers: headers);
      }
    }
    return res;
  }

  // ---- JSON HELPERS ----
  dynamic asJson(Response res) {
    if (res.body != null) return res.body;
    final s = res.bodyString;
    return (s == null || s.isEmpty) ? null : jsonDecode(s);
  }

  List unwrapList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      for (final k in const [
        'data',
        'list',
        'items',
        'result',
        'results',
        'records',
        'schedules',
      ]) {
        final v = body[k];
        if (v is List) return v;
      }
      for (final v in body.values) {
        if (v is List) return v;
      }
      throw 'Unexpected map shape: keys=${body.keys}';
    }
    if (body is String && body.isNotEmpty) return unwrapList(jsonDecode(body));
    throw 'Unexpected body type: ${body.runtimeType}';
  }

  DateTime toLocalDateOnly(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    return DateTime(dt.year, dt.month, dt.day);
  }

  String yyyyMmDd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
