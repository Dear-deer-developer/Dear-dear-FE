import 'package:dear_deer_demo/service/day_night_service.dart';
import 'package:dear_deer_demo/data/calendar/calendar_season_config.dart';
import 'package:dear_deer_demo/controller/bottom_nav_controller.dart';
import 'package:dear_deer_demo/controller/calendar/schedule_controller.dart';
import 'package:dear_deer_demo/controller/calendar/calendar_rewards_controller.dart';
import 'package:dear_deer_demo/service/calendar/calendar_rewards_service.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:get/get.dart';

class CalendarController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final DayNightService dayNight = Get.find<DayNightService>();
  final ScheduleController _sc = Get.find<ScheduleController>();

  /// ===== 시즌 설정 =====
  static const _season = CalendarSeasonConfig(
    year: 2026,
    startMonth: 1,
    endMonth: 2,
  );

  late final List<DateTime> months = _season.months;

  /// ===== 페이지 =====
  late final PageController pageController;
  Worker? _navWorker;

  /// ===== 선택 날짜 =====
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final Rxn<dynamic> pendingReward = Rxn();

  /// ===== 초기 월 인덱스 =====
  int get initialMonthIndex {
    final today = DateTime.now();
    final index = months.indexWhere(
      (m) => m.year == today.year && m.month == today.month,
    );
    return index == -1 ? 0 : index;
  }

  @override
  void onInit() {
    super.onInit();

    pageController = PageController(initialPage: initialMonthIndex);

    final bnc = Get.find<BottomNavController>();

    _navWorker = ever<int>(bnc.rxIndex, (i) {
      if (Page.values[i] == Page.calendar) {
        onEnteredCalendar();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bnc.currentPage == Page.calendar) {
        onEnteredCalendar();
      }
    });
  }

  @override
  void onClose() {
    _navWorker?.dispose();
    pageController.dispose();
    super.onClose();
  }

  /// ===== 캘린더 진입 =====
  Future<void> onEnteredCalendar() async {
    for (final m in months) {
      await _sc.loadMonthly(m.year, m.month);
    }

    await _sc.loadDaily(selectedDate.value);

    await _handleRewards();
  }

  /// ===== 보상 처리 =====
  Future<void> _handleRewards() async {
    final api = Get.find<ApiService>();

    final rewardsCtrl = Get.isRegistered<CalendarRewardsController>()
        ? Get.find<CalendarRewardsController>()
        : Get.put(
            CalendarRewardsController(
              CalendarRewardsService(api),
            ),
            permanent: true,
          );

    await rewardsCtrl.tryEnterAndShow((reward) async {
      if (Get.find<BottomNavController>().currentPage != Page.calendar) {
        return;
      }

      pendingReward.value = reward; // 👉 여기서 상태만 전달
    });
  }

  /// ===== 날짜 변경 =====
  Future<void> changeDate(DateTime date) async {
    selectedDate.value = date;
    await _sc.loadDaily(selectedDate.value);
  }

  /// ===== 스크롤 =====
  void scrollUp() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeIn,
    );
  }
}
