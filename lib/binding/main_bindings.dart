// lib/binding/main_bindings.dart
import 'package:get/get.dart';

// 기존
import 'package:dear_deer_demo/controller/app_start_controller.dart';
import 'package:dear_deer_demo/controller/bottom_nav_controller.dart';
import 'package:dear_deer_demo/controller/calendar/calendar_controller.dart';
import 'package:dear_deer_demo/controller/contents/contents_controller.dart';
import 'package:dear_deer_demo/controller/home/alarm_controller.dart';
import 'package:dear_deer_demo/controller/home/bg_music_controller.dart';
import 'package:dear_deer_demo/controller/home/gift_controller.dart';
import 'package:dear_deer_demo/controller/home/home_controller.dart';
import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/controller/post/post_controller.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/service/auth_service.dart';

// 일정 연동 (등록만 추가)
import 'package:dear_deer_demo/util/custom_get_connect.dart';
import 'package:dear_deer_demo/service/schedule_service.dart';
import 'package:dear_deer_demo/controller/schedule_controller.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    // ── 공용 서비스
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<BgMusicController>(BgMusicController(), permanent: true);
    Get.put<AppStartController>(AppStartController(), permanent: true);

    // ── 일정 API 의존성 체인 등록 (파일 내용은 안 건드림)
    Get.put<CustomGetConnect>(CustomGetConnect(), permanent: true);
    Get.put<ScheduleService>(ScheduleService(Get.find<CustomGetConnect>()),
        permanent: true);
    Get.put<ScheduleController>(ScheduleController(Get.find<ScheduleService>()),
        permanent: true);

    // ── 네비/탭
    Get.put(BottomNavController(), permanent: true);

    // ── 페이지 컨트롤러
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => PostController());
    Get.lazyPut(() => CalendarController());
    Get.lazyPut(() => ContentsController());
    Get.lazyPut(() => GiftController());
    Get.lazyPut<AlarmController>(() => AlarmController(), fenix: true);
  }
}
