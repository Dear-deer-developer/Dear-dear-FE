// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';

// class HomeController extends GetxController {
//   final ScrollController scrollController = ScrollController();

//   // 초기 데이터 로딩
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final RxBool isNight = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _recompute(); // 첫 계산
    _scheduleNextTick(); // 다음 경계(06:00/18:00)에 갱신
  }

  void scrollUp() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 700), curve: Curves.easeIn);
  }

  void _recompute() {
    final now = DateTime.now(); // 로컬시간 (한국이면 KST)
    final hour = now.hour; // 0~23
    isNight.value = !(hour >= 6 && hour < 18);
  }

  void _scheduleNextTick() {
    _timer?.cancel();
    final now = DateTime.now();
    final hour = now.hour;

    // 다음 경계시각(06:00 또는 18:00)
    DateTime nextBoundary;
    if (hour < 6) {
      nextBoundary = DateTime(now.year, now.month, now.day, 6);
    } else if (hour < 18) {
      nextBoundary = DateTime(now.year, now.month, now.day, 18);
    } else {
      // 내일 06:00
      final tomorrow = now.add(const Duration(days: 1));
      nextBoundary = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6);
    }

    final diff = nextBoundary.difference(now);
    _timer = Timer(diff, () {
      _recompute();
      _scheduleNextTick(); // 다음 경계도 예약
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
