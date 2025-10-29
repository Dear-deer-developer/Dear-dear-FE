// lib/service/calendar/calendar_service.dart
import 'package:get/get.dart';

import 'package:dear_deer_demo/model/schedule.dart';
import 'calendar_api.dart';

class CalendarService extends GetxService {
  final CalendarApi _api;
  CalendarService(this._api);

  // 월별 요약(점/반원에 사용). 서버가 title/memo를 안 줄 수 있으므로 기본값 처리.
  Future<List<Schedule>> fetchMonthly(int year, int month) async {
    final res = await _api.get('/schedules/monthly', query: {
      'year': '$year',
      'month': '$month',
    });
    if (res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'GET /schedules/monthly → $code $body';
    }

    final list = _api.unwrapList(_api.asJson(res));
    return list.map<Schedule>((e) {
      final m = (e as Map);
      final localDate = _api.toLocalDateOnly(m['date'] as String);
      return Schedule(
        id: (m['id'] as num).toInt(),
        title: (m['title'] ?? '') as String,
        memo: (m['memo'] ?? '') as String,
        category: catFromApi(m['category'] as String? ?? 'ETC'),
        date: localDate,
      );
    }).toList();
  }

  // 일별 상세(바텀시트에 사용)
  Future<List<Schedule>> fetchDaily(DateTime day) async {
    final res =
        await _api.get('/schedules/daily', query: {'date': _api.yyyyMmDd(day)});
    if (res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'GET /schedules/daily → $code $body';
    }

    final list = _api.unwrapList(_api.asJson(res));
    return list.map<Schedule>((e) {
      final m = (e as Map).cast<String, dynamic>();
      final normalized = {
        ...m,
        'date': _api.toLocalDateOnly(m['date'] as String).toIso8601String(),
      };
      return Schedule.fromJson(normalized);
    }).toList();
  }

  Future<Schedule> create(Schedule draft, {bool asDateOnly = true}) async {
    final res =
        await _api.post('/schedules', draft.toBody(asDateOnly: asDateOnly));
    if (res.statusCode != 201 && res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'POST /schedules → $code $body';
    }

    final raw = _api.asJson(res);
    final map = (raw is Map) ? raw : {};
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
    final res = await _api.put(
        '/schedules/$id', changed.toBody(asDateOnly: asDateOnly));
    if (res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'PUT /schedules/$id → $code $body';
    }

    final raw = _api.asJson(res);
    final map = (raw is Map) ? raw : {};
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
    final res = await _api.delete('/schedules/$id');
    if (res.statusCode != 204 && res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'DELETE /schedules/$id → $code $body';
    }
  }
}
