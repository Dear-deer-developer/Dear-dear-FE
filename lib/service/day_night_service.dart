import 'dart:async';
import 'package:get/get.dart';

/// 앱 전역에서 사용하는 낮/밤 상태 관리 서비스
///
/// - 한국 시간(KST) 기준으로 계산
/// - 07:00 ~ 17:59 → 낮
/// - 18:00 ~ 06:59 → 밤
/// - 경계 시각에 자동 갱신
/// - GetxService로 등록하여 앱 전체에서 공유
class DayNightService extends GetxService {
  /// 현재 밤/낮 상태 (true = 밤, false = 낮)
  final RxBool isNight = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _recompute(); // 앱 시작 시 첫 계산
    _scheduleNextTick(); // 다음 경계 시각 예약
  }

  /// 현재 시간을 기준으로 밤/낮 상태 계산
  void _recompute() {
    // 한국 시간 기준 (UTC + 9)
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    final hour = now.hour;

    // 07:00 ~ 17:59 → 낮
    // 그 외 → 밤
    isNight.value = (hour < 7 || hour >= 18);
  }

  /// 다음 경계 시각(07:00 또는 18:00)에 맞춰 자동 갱신 예약
  void _scheduleNextTick() {
    _timer?.cancel();

    // 한국 시간 기준
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    final hour = now.hour;

    DateTime nextBoundary;

    if (hour < 7) {
      // 오늘 07:00
      nextBoundary = DateTime(now.year, now.month, now.day, 7);
    } else if (hour < 18) {
      // 오늘 18:00
      nextBoundary = DateTime(now.year, now.month, now.day, 18);
    } else {
      // 내일 07:00
      final tomorrow = now.add(const Duration(days: 1));
      nextBoundary = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 7);
    }

    final diff = nextBoundary.difference(now);

    _timer = Timer(diff, () {
      _recompute();
      _scheduleNextTick(); // 다음 경계 재예약
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
