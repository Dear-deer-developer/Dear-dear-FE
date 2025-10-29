// lib/service/schedule_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/schedule.dart';
import '../../main.dart' show SharedPreferencesKeys;
import 'package:dear_deer_demo/util/mem_cache.dart';
import 'package:dear_deer_demo/service/auth_service.dart';

String get _apiBase =>
    (dotenv.env['API_BASE_URL'] ?? '').trim(); // e.g. https://dearxmas.com
String get _apiPrefix =>
    (dotenv.env['API_PREFIX'] ?? '').trim(); // e.g. "", "/api"

String _u(String path) {
  final base = _apiBase.replaceAll(RegExp(r'/*$'), '');
  final prefix =
      _apiPrefix.replaceAll(RegExp(r'^/+'), '').replaceAll(RegExp(r'/*$'), '');
  final p = path.replaceAll(RegExp(r'^/+'), '');
  return [base, if (prefix.isNotEmpty) prefix, p].join('/');
}

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

String _yyyyMmDd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ---- 공통: 401 → refresh → 재시도 ----
class ScheduleService extends GetxService {
  final GetConnect _api;
  ScheduleService(this._api);

  Future<Response<T>> _getWithRetry<T>(String url,
      {Map<String, dynamic>? query}) async {
    var headers = await _authHeaders();
    var res = await _api.get<T>(url, query: query, headers: headers);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        res = await _api.get<T>(url, query: query, headers: headers);
      }
    }
    return res;
  }

  Future<Response<T>> _postWithRetry<T>(String url, Object body) async {
    var headers = await _authHeaders();
    var res = await _api.post<T>(url, body, headers: headers);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        res = await _api.post<T>(url, body, headers: headers);
      }
    }
    return res;
  }

  Future<Response<T>> _putWithRetry<T>(String url, Object body) async {
    var headers = await _authHeaders();
    var res = await _api.put<T>(url, body, headers: headers);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        res = await _api.put<T>(url, body, headers: headers);
      }
    }
    return res;
  }

  Future<Response<T>> _deleteWithRetry<T>(String url) async {
    var headers = await _authHeaders();
    var res = await _api.delete<T>(url, headers: headers);

    if (res.statusCode == 401 && Get.isRegistered<AuthService>()) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        headers = await _authHeaders();
        res = await _api.delete<T>(url, headers: headers);
      }
    }
    return res;
  }

  dynamic _asJson(Response res) {
    if (res.body != null) return res.body;
    final s = res.bodyString;
    return (s == null || s.isEmpty) ? null : jsonDecode(s);
  }

  List _unwrapList(dynamic body) {
    if (body is List) return body;
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
    if (body is String && body.isNotEmpty) return _unwrapList(jsonDecode(body));
    throw 'Unexpected body type: ${body.runtimeType}';
  }

  // === 핵심: UTC → 로컬자정 정규화 ===
  DateTime _toLocalDateOnly(String iso) {
    final dtLocal = DateTime.parse(iso).toLocal(); // UTC → Local
    return DateTime(dtLocal.year, dtLocal.month, dtLocal.day); // 자정 고정
  }

  // ---- API ----
  Future<List<Schedule>> fetchMonthly(int year, int month) async {
    final url = _u('/schedules/monthly');
    final res =
        await _getWithRetry(url, query: {'year': '$year', 'month': '$month'});
    if (res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'API $url → $code $body';
    }

    final list = _unwrapList(_asJson(res));
    return list.map<Schedule>((e) {
      final m = (e as Map);
      // 서버는 월 API에서 title/memo가 없을 수도 있으니 기본값 처리
      final localDateOnly = _toLocalDateOnly(m['date'] as String);
      return Schedule(
        id: (m['id'] as num).toInt(),
        title: (m['title'] ?? '') as String,
        memo: (m['memo'] ?? '') as String,
        category: catFromApi(m['category'] as String? ?? 'ETC'),
        date: localDateOnly, // ✅ 로컬 자정으로 저장
      );
    }).toList();
  }

  Future<List<Schedule>> fetchDaily(DateTime day) async {
    final url = _u('/schedules/daily');
    final res = await _getWithRetry(url, query: {'date': _yyyyMmDd(day)});
    if (res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'API $url → $code $body';
    }

    final list = _unwrapList(_asJson(res));
    return list.map<Schedule>((e) {
      final m = (e as Map).cast<String, dynamic>();
      // 일 API는 전체 필드가 오므로 date도 정규화
      final normalized = {
        ...m,
        'date': _toLocalDateOnly(m['date'] as String).toIso8601String(),
      };
      return Schedule.fromJson(normalized);
    }).toList();
  }

  Future<Schedule> create(Schedule draft, {bool asDateOnly = true}) async {
    final url = _u('/schedules');
    final res = await _postWithRetry(url, draft.toBody(asDateOnly: asDateOnly));
    if (res.statusCode != 201 && res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'API $url → $code $body';
    }

    final raw = _asJson(res);
    final map = (raw is Map) ? raw : jsonDecode(res.bodyString!) as Map;
    final obj = (map['data'] is Map) ? map['data'] : map;

    final created = Schedule.fromJson((obj as Map).cast<String, dynamic>());
    final d = created.date;
    return Schedule(
      id: created.id,
      title: created.title,
      memo: created.memo,
      category: created.category,
      date: DateTime(d.year, d.month, d.day),
    );
  }

  Future<Schedule> update(int id, Schedule changed,
      {bool asDateOnly = true}) async {
    final url = _u('/schedules/$id');
    final res =
        await _putWithRetry(url, changed.toBody(asDateOnly: asDateOnly));
    if (res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'API $url → $code $body';
    }

    final raw = _asJson(res);
    final map = (raw is Map) ? raw : jsonDecode(res.bodyString!) as Map;
    final obj = (map['data'] is Map) ? map['data'] : map;

    final updated = Schedule.fromJson((obj as Map).cast<String, dynamic>());
    final d = updated.date;
    return Schedule(
      id: updated.id,
      title: updated.title,
      memo: updated.memo,
      category: updated.category,
      date: DateTime(d.year, d.month, d.day),
    );
  }

  Future<void> delete(int id) async {
    final url = _u('/schedules/$id');
    final res = await _deleteWithRetry(url);
    if (res.statusCode != 204 && res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'API $url → $code $body';
    }
  }
}
