// lib/controller/calendar/calendar_rewards_controller.dart
import 'package:get/get.dart';
import 'package:dear_deer_demo/model/calendar/calendar_reward.dart';
import 'package:dear_deer_demo/service/calendar/calendar_rewards_service.dart';
import 'package:dear_deer_demo/data/debug_flags.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:dear_deer_demo/data/calendar/daily_gift_schedule.dart';

typedef ShowRewardDialog = Future<void> Function(CalendarReward reward);

class CalendarRewardsController extends GetxController {
  CalendarRewardsController(this._svc);
  final CalendarRewardsService _svc;

  Future<void> tryEnterAndShow(ShowRewardDialog showDialog) async {
    debugPrint('🎄 tryEnterAndShow() start (force=$kDebugForceRewardPopup)');
    try {
      CalendarReward r = await _svc.enter();
      debugPrint(
          '🎁 서버 응답: awarded=${r.awarded}, giftName=${r.giftName}, localDate=${r.localDate}');

      // 디버그 강제 팝업
      if (kDebugForceRewardPopup) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        r = r.copyWith(
          awarded: true,
          giftName: r.giftName ?? giftNameForDate(DateTime.now()),
          localDate: r.localDate.isNotEmpty ? r.localDate : today,
        );
        debugPrint('⚠️ DEBUG 강제팝업 적용 -> '
            'awarded=${r.awarded}, giftName=${r.giftName}, localDate=${r.localDate}');
      }

      if (!r.awarded) {
        debugPrint('🚫 awarded=false → 팝업 스킵');
        return;
      }

      // 서버가 giftName/localDate를 안 주는 경우, 규칙으로 보완
      String localDate = r.localDate;
      if (localDate.isEmpty) {
        localDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      }
      String? name = r.giftName;
      if (name == null || name.isEmpty) {
        // YYYY-MM-DD → MM-dd 로 변환해서 매핑
        final dt = DateTime.tryParse(localDate) ?? DateTime.now();
        name = giftNameForDate(dt);
      }
      final fixed = r.copyWith(localDate: localDate, giftName: name);

      debugPrint('✅ 팝업 호출 (fixed giftName=${fixed.giftName})');
      await showDialog(fixed);
    } catch (e, st) {
      debugPrint('❌ tryEnterAndShow 예외: $e');
      debugPrint('$st');
    }
  }
}
