import 'package:get/get.dart';
import 'package:dear_deer_demo/model/schedule.dart' as sch;
import 'calendar_api.dart';

class CalendarService extends GetxService {
  final CalendarApi _api;
  CalendarService(this._api);

  Future<List<sch.Schedule>> fetchMonthly(int year, int month) async {
    final res = await _api
        .get('/schedules/monthly', query: {'year': '$year', 'month': '$month'});
    if (res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'GET /schedules/monthly → $code $body';
    }

    final list = _api.unwrapList(_api.asJson(res));
    return list.map<sch.Schedule>((e) {
      final m = (e as Map);
      final localDate = _api.toLocalDateOnly(m['date'] as String);
      return sch.Schedule(
        id: (m['id'] as num).toInt(),
        title: (m['title'] ?? '') as String,
        memo: (m['memo'] ?? '') as String,
        category: sch.catFromApi(m['category'] as String? ?? 'ETC'),
        date: localDate,
      );
    }).toList();
  }

  Future<List<sch.Schedule>> fetchDaily(DateTime day) async {
    final res =
        await _api.get('/schedules/daily', query: {'date': _api.yyyyMmDd(day)});
    if (res.statusCode != 200) {
      final code = res.statusCode;
      final body = res.bodyString ?? res.body?.toString() ?? '';
      throw 'GET /schedules/daily → $code $body';
    }

    final list = _api.unwrapList(_api.asJson(res));
    return list.map<sch.Schedule>((e) {
      final m = (e as Map).cast<String, dynamic>();
      final normalized = {
        ...m,
        'date': _api.toLocalDateOnly(m['date'] as String).toIso8601String(),
      };
      return sch.Schedule.fromJson(normalized);
    }).toList();
  }

  Future<sch.Schedule> create(sch.Schedule draft,
      {bool asDateOnly = true}) async {
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

    final created = sch.Schedule.fromJson((obj as Map).cast<String, dynamic>());
    final d = created.date;
    return sch.Schedule(
      id: created.id,
      title: created.title,
      memo: created.memo,
      category: created.category,
      date: DateTime(d.year, d.month, d.day),
    );
  }

  Future<sch.Schedule> update(int id, sch.Schedule changed,
      {bool asDateOnly = true}) async {
    final body = changed.toBody(asDateOnly: false); // ✅ ISO-UTC
    final res = await _api.patch<Map<String, dynamic>>('/schedules/$id', body);
    if (res.statusCode != 200) {
      final code = res.statusCode;
      final text = res.bodyString ?? res.body?.toString() ?? '';
      throw 'PATCH /schedules/$id → $code $text';
    }

    final raw = _api.asJson(res);
    final map = (raw is Map) ? raw : {};
    final obj = (map['data'] is Map) ? map['data'] : map;

    final updated =
        sch.Schedule.fromJson(Map<String, dynamic>.from(obj as Map));
    final d = updated.date;
    return sch.Schedule(
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
