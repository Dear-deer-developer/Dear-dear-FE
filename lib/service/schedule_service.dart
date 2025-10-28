// lib/service/schedule_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/schedule.dart';
import '../main.dart' show SharedPreferencesKeys;
import 'package:dear_deer_demo/util/logger.dart';
import 'package:dear_deer_demo/util/mem_cache.dart';
import 'package:dear_deer_demo/service/auth_service.dart';

String get _apiBase =>
    (dotenv.env['API_BASE_URL'] ?? '').trim(); // ex) https://dearxmas.com
String get _apiPrefix =>
    (dotenv.env['API_PREFIX'] ?? '').trim(); // ex) "", "/api"

String _u(String path) {
  final base = _apiBase.replaceAll(RegExp(r'/*$'), '');
  final prefix =
      _apiPrefix.replaceAll(RegExp(r'^/+'), '').replaceAll(RegExp(r'/*$'), '');
  final p = path.replaceAll(RegExp(r'^/+'), '');
  return [base, if (prefix.isNotEmpty) prefix, p].join('/');
}

Future<String?> _currentAccessToken() async {
  // 1️⃣ 메모리 캐시 (로그인 직후 최신 토큰)
  final mem = MemCache.get(MemCacheKey.jwtAccessToken);
  if (mem is String && mem.isNotEmpty) return mem;

  // 2️⃣ SharedPreferences (앱 재시작 시 복구용)
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

String _yyyyMmDd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class ScheduleService extends GetxService {
  final GetConnect _api;
  ScheduleService(this._api);

  // ───────────── 로그 유틸 ─────────────
  void _logReq({
    required String tag,
    required String method,
    required String url,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Object? body,
  }) {
    debugPrint(
        '[$tag] ➡️ $method $url${query == null ? '' : '  query=${jsonEncode(query)}'}');
    if (headers != null) {
      final safe = Map<String, String>.from(headers);
      final auth = safe['Authorization'];
      if (auth != null && auth.length > 20) {
        safe['Authorization'] =
            '${auth.substring(0, 10)}...${auth.substring(auth.length - 6)}';
      }
      debugPrint('[$tag] 🔐 headers=$safe');
    }
    if (body != null) debugPrint('[$tag] 📤 body=${jsonEncode(body)}');
  }

  void _logRes(
      {required String tag, required String url, required Response res}) {
    debugPrint(
        '[$tag] ⬅️ status=${res.statusCode} url=$url hasError=${res.hasError}');
    final st = res.statusText?.trim();
    if (st != null && st.isNotEmpty) debugPrint('[$tag] statusText=$st');
    final bs = res.bodyString;
    if (bs != null && bs.isNotEmpty) {
      debugPrint(
          '[$tag] 📥 body=${bs.length > 800 ? bs.substring(0, 800) + '...(trunc)' : bs}');
    }
  }

  Never _throwHttp(Response res, String url) {
    final code = res.statusCode;
    final body = res.bodyString ?? res.body?.toString() ?? '';
    throw 'API $url → $code $body';
  }

  // ───────────── 공통: 401→리프레시→재시도 ─────────────
  Future<Response<T>> _getWithRetry<T>(String url,
      {Map<String, dynamic>? query}) async {
    var headers = await _authHeaders();
    _logReq(
        tag: 'retry', method: 'GET', url: url, query: query, headers: headers);
    var res = await _api.get<T>(url, query: query, headers: headers);
    _logRes(tag: 'retry', url: url, res: res);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders(); // 새 토큰으로 헤더 갱신
        _logReq(
            tag: 'retry2',
            method: 'GET',
            url: url,
            query: query,
            headers: headers);
        res = await _api.get<T>(url, query: query, headers: headers);
        _logRes(tag: 'retry2', url: url, res: res);
      }
    }
    return res;
  }

  Future<Response<T>> _postWithRetry<T>(String url, Object body) async {
    var headers = await _authHeaders();
    _logReq(
        tag: 'retry', method: 'POST', url: url, headers: headers, body: body);
    var res = await _api.post<T>(url, body, headers: headers);
    _logRes(tag: 'retry', url: url, res: res);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        _logReq(
            tag: 'retry2',
            method: 'POST',
            url: url,
            headers: headers,
            body: body);
        res = await _api.post<T>(url, body, headers: headers);
        _logRes(tag: 'retry2', url: url, res: res);
      }
    }
    return res;
  }

  Future<Response<T>> _putWithRetry<T>(String url, Object body) async {
    var headers = await _authHeaders();
    logger.i('[update] ➡️ PUT $url');
    logger.i('[update] 📤 body=${jsonEncode(body)}');
    var res = await _api.put<T>(url, body, headers: headers);
    logger.i('[update] ⬅️ status=${res.statusCode} body=${res.bodyString}');

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        logger.i('[update:retry] ➡️ PUT $url');
        res = await _api.put<T>(url, body, headers: headers);
        logger.i(
            '[update:retry] ⬅️ status=${res.statusCode} body=${res.bodyString}');
      }
    }
    return res;
  }

  Future<Response<T>> _deleteWithRetry<T>(String url) async {
    var headers = await _authHeaders();
    _logReq(tag: 'retry', method: 'DELETE', url: url, headers: headers);
    var res = await _api.delete<T>(url, headers: headers);
    _logRes(tag: 'retry', url: url, res: res);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        _logReq(tag: 'retry2', method: 'DELETE', url: url, headers: headers);
        res = await _api.delete<T>(url, headers: headers);
        _logRes(tag: 'retry2', url: url, res: res);
      }
    }
    return res;
  }

  // ───────────── JSON 안전 파서 ─────────────
  dynamic _asJson(Response res) {
    if (res.body != null) return res.body;
    final s = res.bodyString;
    if (s == null || s.isEmpty) return null;
    try {
      return jsonDecode(s);
    } catch (_) {
      return s;
    }
  }

  List _unwrapList(dynamic body) {
    if (body is List) return body;
    if (body is String && body.isNotEmpty) {
      final decoded = jsonDecode(body);
      return _unwrapList(decoded);
    }
    if (body is Map) {
      for (final k in const [
        'data',
        'list',
        'items',
        'result',
        'results',
        'records',
        'schedules'
      ]) {
        final v = body[k];
        if (v is List) return v;
      }
      for (final v in body.values) {
        if (v is List) return v;
      }
      throw 'Unexpected map shape: keys=${body.keys}';
    }
    throw 'Unexpected body type: ${body.runtimeType}';
  }

  // ───────────── API ─────────────
  Future<List<Schedule>> fetchMonthly(int year, int month) async {
    final url = _u('/schedules/monthly');
    final query = {'year': '$year', 'month': '$month'};

    final res = await _getWithRetry(url, query: query);
    if (res.statusCode != 200) _throwHttp(res, url);

    final list = _unwrapList(_asJson(res));
    return list.map<Schedule>((e) {
      final m = (e as Map);
      return Schedule(
        id: (m['id'] as num).toInt(),
        title: (m['title'] ?? '') as String,
        memo: (m['memo'] ?? '') as String,
        category: catFromApi(m['category'] as String? ?? 'ETC'),
        date: DateTime.parse(m['date'] as String),
      );
    }).toList();
  }

  Future<List<Schedule>> fetchDaily(DateTime day) async {
    final url = _u('/schedules/daily');
    final query = {'date': _yyyyMmDd(day)};

    final res = await _getWithRetry(url, query: query);
    if (res.statusCode != 200) _throwHttp(res, url);

    final list = _unwrapList(_asJson(res));
    return list
        .map<Schedule>(
            (e) => Schedule.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<Schedule> create(Schedule draft, {bool asDateOnly = true}) async {
    final url = _u('/schedules');
    final body = draft.toBody(asDateOnly: asDateOnly);

    final res = await _postWithRetry(url, body);
    if (res.statusCode != 201 && res.statusCode != 200) _throwHttp(res, url);

    final json = _asJson(res);
    final map = (json is Map) ? json : (jsonDecode(res.bodyString!) as Map);
    final obj = (map['data'] is Map) ? map['data'] : map;
    return Schedule.fromJson((obj as Map).cast<String, dynamic>());
  }

  Future<Schedule> update(int id, Schedule changed,
      {bool asDateOnly = true}) async {
    final url = _u('/schedules/$id');
    final body = changed.toBody(asDateOnly: asDateOnly);

    final res = await _putWithRetry(url, body);
    if (res.statusCode != 200) _throwHttp(res, url);

    final json = _asJson(res);
    final map = (json is Map) ? json : (jsonDecode(res.bodyString!) as Map);
    final obj = (map['data'] is Map) ? map['data'] : map;
    return Schedule.fromJson((obj as Map).cast<String, dynamic>());
  }

  Future<void> delete(int id) async {
    final url = _u('/schedules/$id');
    final res = await _deleteWithRetry(url);
    if (res.statusCode != 204 && res.statusCode != 200) _throwHttp(res, url);
  }

  // 원문 확인용(필요할 때만 호출)
  Future<void> debugFetchDailyRaw(String yyyyMmDd) async {
    final url = _u('/schedules/daily');
    final headers = await _authHeaders();
    final query = {'date': yyyyMmDd};
    _logReq(
        tag: 'debug', method: 'GET', url: url, query: query, headers: headers);
    final res = await _api.get(url, query: query, headers: headers);
    _logRes(tag: 'debug', url: url, res: res);
  }
}
